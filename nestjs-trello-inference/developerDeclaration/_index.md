# Guida Developer Declaration — nestjs-trello-inference

Questo documento integra il tuo ruolo AEP standard (round read-only, output JSON secondo lo
schema `Declaration`): qui trovi solo cosa questo **stack** mette già a disposizione, non le
regole di prodotto della milestone.

## Prima di dichiarare "serve costruire X", verifica se esiste già

Questa recipe presuppone che, se il progetto le usa già, esistano:

- un client Trello (`TrelloClientService`, vedi `developerImplementation/trello-client.md`);
- un provider di inferenza con supporto tool calling (`InferenceService`, vedi
  `developerImplementation/inference-provider.md`);
- adapter di tool riusabili per l'inferenza (lettura Trello, web search, knowledge base, vedi
  `developerImplementation/inference-tools.md`).

Esplora il repository prima di scrivere `similarCode`/`conventions`: se uno di questi blocchi
esiste già, la tua `declaration` deve trattarlo come dato riusabile (va in `evidence`/
`similarCode`), non come lavoro da pianificare in `expectedFiles`.

## Cosa segnalare in `architectureFlags`

Segnala esplicitamente in `architectureFlags` (non lasciarlo implicito in `understanding`) se
il task che stai dichiarando richiede una qualsiasi di queste deviazioni dal default di
questa recipe, così il Plan Reviewer le vede subito:

- esporre come tool per il modello un'operazione di **scrittura** Trello (`addComment`,
  `moveCard`, `removeLabel`) invece che solo lettura;
- modificare il contratto stesso di `InferenceService`/`ToolDefinition` invece di aggiungere
  un nuovo file di tool adapter;
- una knowledge base il cui scope (globale/per-board) non è deciso dal service di dominio ma
  lasciato scegliere al modello.

Nessuna di queste è vietata — sono scelte legittime se la milestone le richiede
esplicitamente — ma non sono il default silenzioso di questo stack, quindi vanno rese
visibili, non implementate senza flag.
