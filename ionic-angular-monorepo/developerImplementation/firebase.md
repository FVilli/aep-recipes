# Firebase in questo stack

## Hosting (sempre presente)

Ogni app ha il proprio `firebase.json`. Configurazione attesa per una SPA Angular/Ionic con
service worker:

- `"public": "www"` (cartella di output della build);
- rewrite di ogni percorso su `/index.html`;
- header `Cache-Control: no-cache` per `ngsw-worker.js`, `ngsw.json` e
  `manifest.webmanifest`, così gli aggiornamenti del service worker non restano in cache.

AEP non esegue deploy: il rilascio su Hosting resta un'azione umana.

## Altri servizi (solo se la milestone lo chiede)

Se una milestone introduce Auth, Firestore, Storage o Functions:

- usa `@angular/fire` con i provider standalone registrati nella configurazione
  dell'applicazione (`provideFirebaseApp`, `provideAuth`, `provideFirestore`…);
- la configurazione web di Firebase va nei file `src/environments/`; non è un segreto, ma
  credenziali di service account, chiavi private o token non entrano mai nel repository;
- incapsula l'accesso ai dati in servizi `core/` iniettabili, così pagine e test non dipendono
  direttamente dall'SDK;
- regole di sicurezza (`firestore.rules`, `storage.rules`) e indici sono parte della modifica
  e vanno versionati accanto a `firebase.json` dell'app;
- segnala sempre in `architectureFlags` l'introduzione di un nuovo servizio Firebase.
