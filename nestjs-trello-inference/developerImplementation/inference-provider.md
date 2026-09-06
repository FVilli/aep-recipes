# Provider di inferenza — riferimento di implementazione

Riferimento completo per `InferenceModule`/`InferenceService`. I service di dominio (skill,
gestori di AI Request, ecc.) dipendono sempre dall'interfaccia astratta `InferenceService`,
mai da un provider concreto — questo è ciò che permette di cambiare modello/provider senza
toccare la logica di prodotto.

## Interfaccia astratta

`InferenceService` supporta il **tool calling**: il chiamante può passare un elenco di tool
che il modello può decidere di invocare durante il completamento (es. leggere altre card,
cercare sul web, interrogare una knowledge base). `InferenceService` non sa cosa fa un tool
— esegue solo il loop richiesto dal provider (chiama il modello, se risponde con una tool
call esegue `execute` e rimanda il risultato, ripete finché arriva una risposta testuale) —
mentre la *semantica* dei tool (quali esistono, cosa fanno) è decisa e passata dal service di
dominio chiamante, mai hardcoded qui dentro.

```ts
// inference.interface.ts
export interface ToolDefinition {
  name: string;
  description: string;
  /** JSON Schema dei parametri di input, nel formato richiesto dalla tool-calling API del provider. */
  parameters: Record<string, unknown>;
  /**
   * Non deve lanciare: un fallimento del tool va sempre restituito come risultato
   * (es. `{ error: '...' }`) così il modello lo vede e può decidere come proseguire.
   */
  execute(args: Record<string, unknown>): Promise<unknown>;
}

export interface InferenceRequest {
  systemPrompt: string;
  prompt: string;
  /** Facoltativo: usato dalle skill Watch per confrontare con l'analisi precedente. */
  previousResponse?: string;
  /** Facoltativo: tool che il modello può invocare durante questo completamento. */
  tools?: ToolDefinition[];
}

export interface InferenceResponse {
  text: string;
  usage?: { inputTokens: number; outputTokens: number };
}

export abstract class InferenceService {
  abstract complete(request: InferenceRequest): Promise<InferenceResponse>;
}
```

Nota: `InferenceService` è astratta (non un'interfaccia TS pura) così NestJS può usarla
come token di dependency injection senza bisogno di un token stringa separato. Nota anche
che `InferenceResponse` non cambia con i tool: il chiamante riceve solo il testo finale, mai
le tool call intermedie — quelle sono un dettaglio del loop, interno a questo modulo.

## Configurazione

```ts
// inference.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('inference', () => ({
  apiKey: process.env.INFERENCE_API_KEY,
  baseUrl: process.env.INFERENCE_BASE_URL ?? 'https://api.openai.com/v1',
  model: process.env.INFERENCE_MODEL ?? 'gpt-4.1-mini',
}));
```

## Implementazione concreta (API compatibile OpenAI chat completions)

```ts
// openai-inference.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { ConfigType } from '@nestjs/config';
import inferenceConfig from './inference.config';
import {
  InferenceRequest,
  InferenceResponse,
  InferenceService,
  ToolDefinition,
} from './inference.interface';

export class InferenceProviderError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = 'InferenceProviderError';
  }
}

const REQUEST_TIMEOUT_MS = 30_000;
const MAX_TOOL_ITERATIONS = 5;

@Injectable()
export class OpenAiInferenceService implements InferenceService {
  private readonly logger = new Logger(OpenAiInferenceService.name);

  constructor(
    private readonly config: ConfigType<typeof inferenceConfig>,
  ) {}

  async complete(request: InferenceRequest): Promise<InferenceResponse> {
    const tools = request.tools ?? [];
    const toolsByName = new Map(tools.map((t) => [t.name, t]));

    const messages: Array<Record<string, unknown>> = [
      { role: 'system', content: request.systemPrompt },
      { role: 'user', content: request.prompt },
    ];

    for (let iteration = 0; iteration <= MAX_TOOL_ITERATIONS; iteration++) {
      const payload = await this.callProvider(messages, tools);
      const message = payload.choices[0].message;

      if (!message.tool_calls?.length) {
        return {
          text: message.content,
          usage: payload.usage && {
            inputTokens: payload.usage.prompt_tokens,
            outputTokens: payload.usage.completion_tokens,
          },
        };
      }

      if (iteration === MAX_TOOL_ITERATIONS) {
        throw new InferenceProviderError(
          `Superato il limite di ${MAX_TOOL_ITERATIONS} iterazioni di tool calling`,
          500,
        );
      }

      messages.push(message);
      for (const call of message.tool_calls) {
        const tool = toolsByName.get(call.function.name);
        const result = tool
          ? await tool.execute(JSON.parse(call.function.arguments))
          : { error: `tool sconosciuto: ${call.function.name}` };

        messages.push({
          role: 'tool',
          tool_call_id: call.id,
          content: JSON.stringify(result),
        });
      }
    }

    // irraggiungibile: il for esce sempre via return o throw
    throw new InferenceProviderError('tool loop terminato in stato inatteso', 500);
  }

  private async callProvider(
    messages: Array<Record<string, unknown>>,
    tools: ToolDefinition[],
  ): Promise<any> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

    try {
      const response = await fetch(`${this.config.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.config.apiKey}`,
        },
        body: JSON.stringify({
          model: this.config.model,
          messages,
          tools: tools.length
            ? tools.map((t) => ({
                type: 'function',
                function: { name: t.name, description: t.description, parameters: t.parameters },
              }))
            : undefined,
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        const body = await response.text();
        this.logger.error(`Inference provider error: ${response.status} ${body}`);
        throw new InferenceProviderError(body, response.status);
      }

      return response.json();
    } finally {
      clearTimeout(timeout);
    }
  }
}
```

## Wiring del modulo

```ts
// inference.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import inferenceConfig from './inference.config';
import { InferenceService } from './inference.interface';
import { OpenAiInferenceService } from './openai-inference.service';

@Module({
  imports: [ConfigModule.forFeature(inferenceConfig)],
  providers: [{ provide: InferenceService, useClass: OpenAiInferenceService }],
  exports: [InferenceService],
})
export class InferenceModule {}
```

## Chi costruisce il prompt e chi sceglie i tool

`InferenceService` non sa nulla di Trello, card, skill o board: riceve solo
`systemPrompt`/`prompt` già pronti e, se servono, i `tools` da offrire al modello per
*questa* chiamata. La costruzione del contesto (quali campi della card, quali commenti,
quale storico) **e** la scelta di quali tool passare sono responsabilità del service di
dominio che chiama `InferenceService`, mai di questo modulo — coerente con "MyTrello deve
essere responsabile della costruzione del contesto, il modello non decide autonomamente
quali dati recuperare, solo come esplorarli tramite i tool che gli vengono offerti". Gli
adapter concreti dei tool (Trello, web search, knowledge base) sono in `inference-tools.md`.

## Cosa NON fare

- non istanziare un client del provider LLM fuori da questo modulo;
- non lasciare che un service di dominio scelga il modello o l'URL del provider: sono
  configurazione, non logica di prodotto;
- non ignorare il timeout — un provider di inferenza lento non deve bloccare indefinitamente
  la richiesta che lo ha invocato;
- non lasciare che un tool lanci un'eccezione nel loop: un `execute()` che fallisce deve
  restituire un risultato d'errore al modello, mai propagare e interrompere l'intera
  richiesta di inferenza;
- non lasciare il loop di tool calling senza un limite di iterazioni: un modello che continua
  a richiedere tool in ciclo deve fallire in modo esplicito, non bloccare la richiesta
  all'infinito.
