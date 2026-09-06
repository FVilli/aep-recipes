# Client Trello — riferimento di implementazione

Riferimento completo per `TrelloModule`/`TrelloClientService`. Adatta i metodi esposti al
task reale (non serve implementare tutta l'API Trello in un colpo solo), ma segui questa
struttura: config dedicata, service unico, errori tipizzati, verifica firma webhook fatta
qui e non altrove.

## Configurazione

```ts
// trello.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('trello', () => ({
  apiKey: process.env.TRELLO_API_KEY,
  token: process.env.TRELLO_TOKEN,
  webhookSecret: process.env.TRELLO_WEBHOOK_SECRET,
  baseUrl: 'https://api.trello.com/1',
}));
```

## Errori tipizzati

```ts
// trello.errors.ts
export class TrelloApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly endpoint: string,
  ) {
    super(message);
    this.name = 'TrelloApiError';
  }
}
```

## Service

```ts
// trello-client.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { ConfigType } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'node:crypto';
import trelloConfig from './trello.config';
import { TrelloApiError } from './trello.errors';

export interface TrelloCard {
  id: string;
  name: string;
  desc: string;
  idList: string;
  idBoard: string;
  idMembers: string[];
  labels: { id: string; name: string }[];
  due: string | null;
}

const REQUEST_TIMEOUT_MS = 10_000;

@Injectable()
export class TrelloClientService {
  private readonly logger = new Logger(TrelloClientService.name);

  constructor(
    private readonly config: ConfigType<typeof trelloConfig>,
  ) {}

  async getCard(cardId: string): Promise<TrelloCard> {
    return this.request<TrelloCard>('GET', `/cards/${cardId}`, {
      fields: 'name,desc,idList,idBoard,idMembers,labels,due',
    });
  }

  async addComment(cardId: string, text: string): Promise<void> {
    await this.request('POST', `/cards/${cardId}/actions/comments`, { text });
  }

  async moveCard(cardId: string, targetListId: string): Promise<void> {
    await this.request('PUT', `/cards/${cardId}`, { idList: targetListId });
  }

  async removeLabel(cardId: string, labelId: string): Promise<void> {
    await this.request('DELETE', `/cards/${cardId}/idLabels/${labelId}`, {});
  }

  async listCardsInList(listId: string): Promise<TrelloCard[]> {
    return this.request<TrelloCard[]>('GET', `/lists/${listId}/cards`, {
      fields: 'name,desc,idList,idBoard,idMembers,labels,due',
    });
  }

  /**
   * Trello firma ogni webhook con HMAC-SHA1(secret, body + callbackURL),
   * inviato nell'header `x-trello-webhook`. La callbackURL è quella
   * registrata alla creazione del webhook, non l'URL della request in arrivo.
   */
  verifyWebhookSignature(
    rawBody: string,
    callbackUrl: string,
    signatureHeader: string,
  ): boolean {
    const expected = createHmac('sha1', this.config.webhookSecret)
      .update(rawBody + callbackUrl)
      .digest('base64');

    const expectedBuffer = Buffer.from(expected);
    const receivedBuffer = Buffer.from(signatureHeader);

    return (
      expectedBuffer.length === receivedBuffer.length &&
      timingSafeEqual(expectedBuffer, receivedBuffer)
    );
  }

  private async request<T>(
    method: 'GET' | 'POST' | 'PUT' | 'DELETE',
    path: string,
    params: Record<string, string>,
  ): Promise<T> {
    const url = new URL(`${this.config.baseUrl}${path}`);
    url.searchParams.set('key', this.config.apiKey);
    url.searchParams.set('token', this.config.token);

    const isBodyMethod = method === 'POST' || method === 'PUT';
    if (!isBodyMethod) {
      for (const [key, value] of Object.entries(params)) {
        url.searchParams.set(key, value);
      }
    }

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

    try {
      const response = await fetch(url, {
        method,
        headers: isBodyMethod ? { 'Content-Type': 'application/json' } : {},
        body: isBodyMethod ? JSON.stringify(params) : undefined,
        signal: controller.signal,
      });

      if (!response.ok) {
        const body = await response.text();
        this.logger.error(`Trello API error on ${path}: ${response.status} ${body}`);
        throw new TrelloApiError(body, response.status, path);
      }

      return (await response.json()) as T;
    } finally {
      clearTimeout(timeout);
    }
  }
}
```

## Cosa NON fare

- non chiamare `fetch` verso `api.trello.com` da nessun'altra parte del codice: ogni accesso
  passa da `TrelloClientService`;
- non fidarti di un webhook che non passa `verifyWebhookSignature` — scartalo con `403`,
  non processarlo "per sicurezza dopo";
- non introdurre polling delle board se il webhook è disponibile: il webhook è la sorgente di
  eventi, il polling è solo un fallback esplicito se dichiarato dalla milestone.
