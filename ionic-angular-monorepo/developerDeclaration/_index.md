# Guida Developer Declaration — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard (round read-only, output JSON secondo lo
schema `Declaration`): qui trovi solo cosa questo **stack** si aspetta.

## Prima di dichiarare

- Individua l'app del task (cartella alla radice con `ionic.config.json`) e leggi il suo
  `AGENTS.md` e gli eventuali documenti di design: le loro regole entrano in `conventions`.
- Cerca nell'app pagine, componenti `shared/` e servizi `core/` simili da riusare e citali in
  `similarCode`; un componente mancante è di solito un uso diverso di un `ion-*` esistente o
  una piccola composizione di componenti esistenti.
- `expectedFiles` e `allowedScope` devono stare dentro la cartella dell'app del task.

## Cosa segnalare in `architectureFlags`

Rendi esplicito, invece di lasciarlo implicito, se il task richiede:

- modifiche fuori dall'app del task o a più app;
- nuove dipendenze npm;
- un'altra libreria UI o di stile al posto o accanto a Ionic;
- modifiche ai progetti nativi `android/` o `ios/` o a `capacitor.config.ts`;
- l'introduzione di servizi Firebase oltre all'Hosting (Auth, Firestore, Functions…);
- modifiche all'ordine o alla struttura del layer di tema (`src/global.scss`, `src/theme/`).

Nessuna è vietata se la milestone la chiede, ma non sono il default di questo stack.

## Test

Se il task richiede verifiche, prevedi test unitari Vitest `*.spec.ts` accanto ai file
toccati, eseguiti con `ng test`. Non dichiarare altri framework di test.
