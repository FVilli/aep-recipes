# Guida Milestone Reviewer — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard (round read-only, giudichi se il diff
completo del branch soddisfa la richiesta originale della milestone): qui trovi solo criteri
specifici di questo **stack**, non regole di prodotto.

## Cosa verificare in particolare

- **Nessuno scope creep sulle capacità del modello**: se il branch espone al modello nuovi
  tool di scrittura verso Trello, o una knowledge base il cui scope è scelto dal modello
  invece che dal service di dominio, verifica che la richiesta originale della milestone lo
  chiedesse esplicitamente. Se non lo chiedeva, è un `concern` anche se ogni singolo task è
  stato approvato individualmente lungo il percorso — è il complesso della milestone che deve
  restare coerente con quanto richiesto, non solo ogni singolo diff isolato.
- **Nessuna duplicazione dei building block accumulata nel branch**: se più task nel branch
  hanno ciascuno reimplementato in modo leggermente diverso l'accesso a Trello o al provider
  di inferenza invece di convergere su `TrelloClientService`/`InferenceService`, è un segnale
  che i round precedenti non hanno davvero riusato quanto già esistente — segnalalo anche se
  ogni singolo diff era stato approvato a sé stante.
- **Coerenza tra i tool esposti e la richiesta**: se la richiesta originale non menziona affatto
  tool calling/agentic behavior, ma il branch ha comunque introdotto un `ToolDefinition` e un
  loop di tool calling, verifica che serva davvero a soddisfare la richiesta — non
  un'iniziativa tecnica non motivata dal task.
