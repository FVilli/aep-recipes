# Guida Code Reviewer — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard: qui trovi solo controlli specifici di
questo **stack**, non regole di prodotto.

## Controlli specifici

- **Confini**: il diff tocca solo l'app del task; nessun import tra app, nessun file alla
  radice del repository, nessuna modifica a `android/`, `ios/` o `capacitor.config.ts` non
  dichiarata.
- **Regole locali**: il diff rispetta l'`AGENTS.md` dell'app; una violazione esplicita (altra
  libreria UI, selettori profondi nello shadow DOM, colori o spaziature cablati nelle pagine
  invece dei token) è un finding, non un dettaglio di stile.
- **File generati**: niente `www/`, `dist/`, `.angular/`, né modifiche a file di stamp di
  revisione o build-info prodotte da script di build.
- **Angular**: componenti standalone che importano solo ciò che usano; nel codice nuovo
  `inject()` e `@if`/`@for`; route nuove lazy con `loadComponent`.
- **Accessibilità e responsive**: focus, `aria-*`, semantica HTML, touch target e layout
  split-pane/tab bar preservati.
- **Firebase**: nessun segreto nel diff; nuovi servizi Firebase solo se dichiarati; accesso ai
  dati tramite servizi iniettabili.
- **Test**: se il task chiedeva verifiche, test Vitest `*.spec.ts` presenti e significativi;
  nessun nuovo framework di test.
