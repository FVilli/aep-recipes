# Tool per l'inferenza — riferimento di implementazione

Adapter concreti che implementano `ToolDefinition` (vedi `inference-provider.md`) per dare
al modello la possibilità di esplorare dati durante un'inferenza, invece di ricevere solo un
contesto già impacchettato dal service di dominio. Ogni tool qui sotto è un pattern di
**stack** (come si espone una capacità esistente al modello in questo progetto), non una
scelta di prodotto: quali tool offrire in una specifica skill/AI Request è deciso dal service
di dominio chiamante, guidato dalla milestone.

## Tool di lettura Trello (wrappano `TrelloClientService`, vedi `trello-client.md`)

```ts
// trello.tools.ts
import { ToolDefinition } from './inference.interface';
import { TrelloApiError } from './trello.errors';
import { TrelloClientService } from './trello-client.service';

export function buildTrelloReadTools(trello: TrelloClientService): ToolDefinition[] {
  return [
    {
      name: 'get_trello_card',
      description: 'Legge i dettagli di una card Trello dato il suo id.',
      parameters: {
        type: 'object',
        properties: { cardId: { type: 'string' } },
        required: ['cardId'],
      },
      execute: async ({ cardId }) => {
        try {
          return await trello.getCard(cardId as string);
        } catch (error) {
          if (error instanceof TrelloApiError) return { error: error.message };
          throw error;
        }
      },
    },
    {
      name: 'list_trello_cards_in_list',
      description: 'Elenca tutte le card presenti in una lista Trello, dato l\'id della lista.',
      parameters: {
        type: 'object',
        properties: { listId: { type: 'string' } },
        required: ['listId'],
      },
      execute: async ({ listId }) => {
        try {
          return await trello.listCardsInList(listId as string);
        } catch (error) {
          if (error instanceof TrelloApiError) return { error: error.message };
          throw error;
        }
      },
    },
  ];
}
```

Nota: solo tool di **lettura**. Nessuna azione che scrive su Trello (`addComment`, `moveCard`,
`removeLabel`) va esposta come tool al modello — quelle restano scritture deterministiche
decise ed eseguite dal service di dominio dopo aver letto la risposta del modello, mai
decise autonomamente dal modello durante l'inferenza. Se una milestone richiede esplicitamente
di rendere autonoma anche una scrittura, è una scelta di prodotto da dichiarare nel task, non
il default di questa recipe.

## Tool di web search

Il provider di ricerca concreto (quale servizio, quale API key) è una scelta della milestone,
non di questa recipe — qui è definita solo l'interfaccia e come si aggancia a
`InferenceService` come tool.

```ts
// web-search.interface.ts
export interface WebSearchResult {
  title: string;
  url: string;
  snippet: string;
}

export abstract class WebSearchProvider {
  abstract search(query: string): Promise<WebSearchResult[]>;
}
```

```ts
// web-search.tool.ts
import { ToolDefinition } from './inference.interface';
import { WebSearchProvider } from './web-search.interface';

export function buildWebSearchTool(provider: WebSearchProvider): ToolDefinition {
  return {
    name: 'web_search',
    description: 'Cerca informazioni aggiornate sul web dato un testo di ricerca.',
    parameters: {
      type: 'object',
      properties: { query: { type: 'string' } },
      required: ['query'],
    },
    execute: async ({ query }) => {
      try {
        return await provider.search(query as string);
      } catch (error) {
        return { error: error instanceof Error ? error.message : 'web search fallita' };
      }
    },
  };
}
```

## Tool di knowledge base (globale e/o per board)

Anche qui il backend concreto (vector store, ricerca full-text, ecc.) è scelta della
milestone. Lo scope — globale o legato a una board specifica — è invece un concetto di
prodotto che vale la pena rendere esplicito nel contratto, perché ricorre in ogni milestone
di questo stack che usa una knowledge base.

```ts
// knowledge-base.interface.ts
export type KnowledgeBaseScope = { kind: 'global' } | { kind: 'board'; boardId: string };

export interface KnowledgeBaseEntry {
  text: string;
  source?: string;
}

export abstract class KnowledgeBaseProvider {
  abstract query(scope: KnowledgeBaseScope, question: string): Promise<KnowledgeBaseEntry[]>;
}
```

```ts
// knowledge-base.tool.ts
import { ToolDefinition } from './inference.interface';
import { KnowledgeBaseProvider, KnowledgeBaseScope } from './knowledge-base.interface';

export function buildKnowledgeBaseTool(
  provider: KnowledgeBaseProvider,
  scope: KnowledgeBaseScope,
): ToolDefinition {
  return {
    name: 'query_knowledge_base',
    description:
      scope.kind === 'global'
        ? 'Interroga la knowledge base globale.'
        : `Interroga la knowledge base specifica della board ${scope.boardId}.`,
    parameters: {
      type: 'object',
      properties: { question: { type: 'string' } },
      required: ['question'],
    },
    execute: async ({ question }) => {
      try {
        return await provider.query(scope, question as string);
      } catch (error) {
        return { error: error instanceof Error ? error.message : 'query knowledge base fallita' };
      }
    },
  };
}
```

Nota: lo `scope` è deciso e chiuso dal service di dominio **prima** di costruire il tool (qui
tramite closure sui parametri di `buildKnowledgeBaseTool`), non lasciato scegliere al modello
tramite un parametro del tool — altrimenti una board potrebbe leggere la knowledge base di
un'altra semplicemente perché il modello lo ha "deciso" nella tool call.

## Cosa NON fare

- non esporre come tool un'operazione di scrittura verso Trello (vedi sopra);
- non lasciare che un tool lanci un'eccezione non gestita — sempre un risultato `{ error }`,
  mai una propagazione fino al loop di `InferenceService`;
- non lasciare che lo scope di un tool (es. quale board) sia un parametro scelto dal modello
  se il contesto chiamante lo conosce già: chiudilo per closure quando costruisci il tool.
