# Guida Architect — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard: qui trovi solo cosa questo **stack**
mette già a disposizione, non le regole di prodotto della milestone (quelle sono nella
richiesta e nei task, non qui).

## Building block già previsti da questo stack

Questa recipe presuppone due integrazioni tecniche riusabili, descritte in dettaglio nella
guida di `developerImplementation`:

- un client Trello (autenticazione, lettura/scrittura board/card, verifica firma webhook);
- un provider di inferenza (astrazione verso il modello LLM configurato).

Quando decomponi una milestone che usa Trello o l'inferenza, **non creare un task per
"costruire il client Trello" o "integrare l'LLM" a meno che la milestone non lo richieda
esplicitamente per la prima volta**: se l'integrazione esiste già (verificalo esplorando il
repo), i task riguardano solo la logica applicativa che la usa.

## Layout tipico dei moduli in questo stack

Non scrivi codice, ma referenziare correttamente moduli e file esistenti nei task che scrivi
evita ambiguità agli agenti a valle. In questo stack ogni integrazione tecnica vive in una
propria cartella con lo stesso pattern di file (config dedicata, errori tipizzati, service,
modulo NestJS):

- `src/trello/` — `trello.config.ts`, `trello.errors.ts`, `trello-client.service.ts`,
  `trello.module.ts`; esporta `TrelloClientService`.
- `src/inference/` — `inference.config.ts`, `inference.interface.ts`
  (`InferenceService`/`ToolDefinition`), `openai-inference.service.ts`, `inference.module.ts`,
  più gli adapter tool in file dedicati (es. `trello.tools.ts`, `web-search.tool.ts`,
  `knowledge-base.tool.ts`); esporta `InferenceService`.
- i service di dominio (skill, gestori di AI Request, ecc.) vivono ciascuno nel proprio
  modulo NestJS di dominio e dipendono da `TrelloClientService`/`InferenceService` solo
  tramite dependency injection, mai importando i moduli tecnici per intero nella business
  logic.

Se un task richiede una nuova capacità del modello durante l'inferenza (es. "il modello deve
poter leggere altre card"), il task è "aggiungi/usa un tool in `src/inference/`", non
"modifica `InferenceService`" — l'astrazione resta stabile, cambiano solo i tool passati.

## Cosa resta compito tuo, non della recipe

Tutto ciò che riguarda comportamento, regole di business, meccanismi di interazione,
policy di pubblicazione: viene dalla richiesta della milestone. La recipe non ti dice cosa
deve fare il prodotto, solo con cosa puoi costruirlo.
