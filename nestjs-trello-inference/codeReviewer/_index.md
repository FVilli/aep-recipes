# Guida Code Reviewer — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard (round read-only, giudichi semanticamente
il diff reale rispetto alla Developer Declaration): qui trovi solo controlli specifici di
questo **stack**, non regole di prodotto.

## Controlli specifici di questo stack

- **Nessuna chiamata esterna senza timeout**: ogni `fetch` verso Trello o verso il provider
  LLM deve avere un `AbortController`/timeout esplicito, come in `trello-client.md` e
  `inference-provider.md`. Un `fetch` senza timeout è un `concern` a prescindere da cos'altro
  fa il diff.
- **Nessun tool che lancia**: se il diff introduce un tool per `InferenceService` (vedi
  `inference-tools.md`), il suo `execute()` deve intercettare i propri errori e restituire un
  risultato `{ error }`, mai propagare un'eccezione nel loop di tool calling.
- **Nessun tool di scrittura Trello non dichiarato**: se il diff espone `addComment`,
  `moveCard` o `removeLabel` come tool invocabile dal modello, verifica che la Developer
  Declaration lo dichiarasse esplicitamente in `architectureFlags` — se non c'era, è un
  `concern` anche se il codice in sé è corretto, perché è una deviazione silenziosa dal
  default della recipe (solo tool di lettura).
- **Scope della knowledge base chiuso per closure**: se il diff introduce un tool basato su
  `KnowledgeBaseProvider`, lo `scope` (`global` o board specifica) deve essere fissato quando
  il tool viene costruito dal service di dominio, non esposto come parametro che il modello
  può scegliere nella tool call.
- **Loop di tool calling con limite di iterazioni**: se il diff tocca il loop dentro
  `OpenAiInferenceService` (o un provider equivalente), verifica che resti un limite esplicito
  di iterazioni — un loop senza limite è un rischio di blocco indefinito, non solo uno stile.
- **Niente duplicazione dei building block**: se il diff reimplementa una chiamata Trello o
  al provider LLM invece di usare `TrelloClientService`/`InferenceService` già esistenti, è un
  `concern` di coerenza con le convenzioni del progetto, non solo di stile.
