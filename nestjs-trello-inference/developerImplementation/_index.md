# Guida Developer Implementation — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard: qui trovi le convenzioni tecniche di
**questo stack** (NestJS + Trello + inferenza), non le regole di prodotto della milestone
(quelle vengono dalla richiesta/task, non da qui).

## Building block riusabili

Prima di scrivere una nuova integrazione verso Trello o verso il modello di inferenza,
verifica se esiste già nel repository. Se non esiste ancora, questi sono i riferimenti di
implementazione da seguire:

- **Client Trello** → `trello-client.md` (autenticazione, lettura/scrittura, verifica firma
  webhook).
- **Provider di inferenza** → `inference-provider.md` (astrazione verso il modello LLM
  configurato, indipendente dal provider concreto, con supporto a tool calling).
- **Tool per l'inferenza** → `inference-tools.md` (adapter riusabili che espongono lettura
  Trello, web search e knowledge base come tool invocabili dal modello).

## Convenzioni generali di modulo

- ogni integrazione esterna (Trello, inferenza) vive nel proprio modulo NestJS dedicato
  (`TrelloModule`, `InferenceModule`), mai chiamate HTTP dirette sparse nei service di
  dominio;
- i service di dominio dipendono dall'interfaccia astratta (`TrelloClientService`,
  `InferenceService`), mai dai dettagli del provider concreto;
- le credenziali (API key Trello, token, secret webhook, API key del provider LLM) arrivano
  sempre da variabili d'ambiente lette tramite un `ConfigService` dedicato, mai hardcoded né
  lette direttamente da `process.env` nei service di dominio;
- ogni chiamata HTTP verso un servizio esterno ha un timeout esplicito e un errore tipizzato
  in caso di fallimento — non lasciare che un errore di rete propaghi come eccezione generica
  fino al chiamante.

## Testing delle integrazioni esterne

Trello e il provider di inferenza non vengono mai chiamati per davvero nei test: entrambi i
service espongono un'interfaccia astratta proprio per permettere un'implementazione fake
iniettabile al posto di quella reale. Lo stesso vale per i tool (`WebSearchProvider`,
`KnowledgeBaseProvider`): nei test si passano `execute` fake, mai chiamate reali verso un
motore di ricerca o una knowledge base.
