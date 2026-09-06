# Guida Plan Reviewer — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard (round read-only, giudichi evidence, scope,
convenzioni e blast radius di una Developer Declaration): qui trovi solo criteri specifici di
questo **stack** per valutare `blastRadius` e `concerns`, non regole di prodotto.

## Come calibrare il blast radius in questo stack

- una Declaration che tocca solo un nuovo file di tool adapter (es. un nuovo file accanto a
  quelli in `inference-tools.md`) o la logica applicativa di una skill: blast radius basso —
  è esattamente il lavoro che questa recipe si aspetta;
- una Declaration che modifica `InferenceService`, `ToolDefinition`, `TrelloClientService` o il
  loop di tool calling stesso: blast radius alto — quei contratti sono condivisi da ogni skill
  esistente che li usa, un cambiamento lì è di fatto una modifica architetturale, non
  applicativa;
- una Declaration che introduce una chiamata `fetch` diretta verso Trello o verso il provider
  LLM fuori da `TrelloClientService`/`InferenceService`: è una violazione di convenzione da
  segnalare in `concerns`, non solo un dettaglio di stile.

## Cosa verificare in particolare

- se la Declaration espone un tool di **scrittura** verso Trello (non solo lettura) o lascia
  lo scope di una knowledge base scegliere al modello: verifica che sia esplicitamente
  richiesto dal task originale, non un'iniziativa non richiesta dell'agente — se non è
  giustificato dal task, è un `REJECTED` o quantomeno un `concern` esplicito, non un dettaglio
  da approvare in silenzio;
- se `expectedFiles`/`allowedScope` include la ricostruzione di un client Trello o di un
  provider di inferenza già esistenti nel repository (verificabile in sola lettura): è un
  segnale che la Declaration non ha esplorato correttamente il repo prima di dichiarare.
