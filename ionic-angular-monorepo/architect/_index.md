# Guida Architect — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard: qui trovi solo cosa questo **stack**
mette a disposizione, non le regole di prodotto della milestone (quelle sono nella richiesta).

## Forma del repository

Il repository è un monorepo di **app Ionic standalone**: ogni cartella alla radice che
contiene `ionic.config.json` e `package.json` è un'app Angular + Ionic + Capacitor completa e
indipendente, con le proprie dipendenze, il proprio `angular.json` e il proprio
`firebase.json`. Non esiste un progetto alla radice né codice condiviso tra le app.

- Ogni task deve dire esplicitamente **in quale app** lavora (cartella), e restare dentro di
  essa. Una milestone che riguarda più app produce task separati per app.
- Non pianificare librerie condivise, workspace npm alla radice o import tra app diverse a
  meno che la milestone lo chieda esplicitamente.
- Una nuova app è una nuova cartella alla radice con la stessa forma delle esistenti (scaffold
  Ionic/Angular standalone): pianificala solo se la milestone lo chiede.

## Convenzioni locali

Ogni app può avere un proprio `AGENTS.md` e altri documenti (per esempio `DESIGN-SYSTEM.md`)
con regole specifiche: sono vincoli del repository e prevalgono sulle preferenze generiche.
Leggili prima di decomporre e cita nei task quelli pertinenti.

## Struttura tipica di un'app

- `src/app/app.routes.ts` — route lazy con `loadComponent`;
- `src/app/pages/<nome>/` — una cartella per pagina (`*.page.ts/html/scss`);
- `src/app/core/` — servizi applicativi; `src/app/shared/` — piccoli componenti riusabili;
- `src/theme/` e `src/global.scss` — design token e skin dei componenti Ionic;
- `android/`, `ios/` — progetti nativi Capacitor;
- `firebase.json` — Firebase Hosting della build in `www/`.

## Verifica

I check deterministici della recipe sono build e test unitari (Vitest tramite `ng test`) di
ogni app. Quando la milestone chiede verifiche, pianifica test unitari `*.spec.ts` accanto al
codice con quel toolchain; non introdurre altri framework di test. I test e2e Playwright, se
un'app li ha, non fanno parte dei check di AEP.

## Cosa resta compito tuo

Comportamento, contenuti e regole di business vengono dalla richiesta della milestone. La
recipe ti dice con cosa costruire, non cosa.
