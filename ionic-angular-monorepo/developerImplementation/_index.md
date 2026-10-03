# Guida Developer Implementation — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard: qui trovi le convenzioni tecniche di
**questo stack** (monorepo di app Ionic standalone con Angular, Capacitor e Firebase Hosting),
non le regole di prodotto della milestone.

## Confini

- Lavora solo nella cartella dell'app del task; nessun import tra app diverse.
- Rispetta l'`AGENTS.md` dell'app e i documenti che cita: sono le regole del repository.
- Non modificare i progetti nativi `android/`/`ios/` né `capacitor.config.ts` se il task non
  lo chiede; non eseguire `cap sync`, `firebase deploy` o altri comandi di rilascio.
- Non usare gli script npm dell'app che aggiornano file tracciati (per esempio stamp di
  revisione o generazione di build-info): per compilare usa `npx ng build` dentro l'app.
- Non committare output di build (`www/`, `dist/`, `.angular/`).

## Angular e Ionic

- Componenti standalone; route lazy con `loadComponent` in `src/app/app.routes.ts`.
- Segui lo stile di import dei componenti Ionic già usato dall'app (per esempio i singoli
  `Ion*` da `@ionic/angular`), importando solo quelli usati.
- Nel codice nuovo preferisci `inject()` all'iniezione nel costruttore e il control flow
  `@if`/`@for` alle direttive `*ngIf`/`*ngFor`; non riscrivere codice esistente non toccato
  dal task solo per questo.
- Stile: design token e CSS custom properties, `::part()` per i componenti Ionic; niente
  selettori profondi nello shadow DOM né valori di colore, spaziatura o raggio cablati nelle
  pagine.
- Preserva responsive, safe area, focus, attributi `aria-*` e dimensioni dei touch target.

## Firebase

Vedi `firebase.md`: Hosting è parte dello stack; Auth, Firestore e altri servizi si
introducono solo se la milestone lo chiede.

## Test

Test unitari Vitest `*.spec.ts` accanto al codice, eseguiti con `ng test` (builder
`@angular/build:unit-test`). Servizi e logica si testano senza browser e senza rete; per
Firebase usa fake o i servizi resi iniettabili, mai progetti Firebase reali.
