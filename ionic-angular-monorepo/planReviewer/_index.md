# Guida Plan Reviewer — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard: qui trovi solo criteri specifici di questo
**stack** per valutare scope, convenzioni e blast radius di una Developer Declaration.

## Blast radius in questo stack

- una pagina o un componente di una sola app: basso;
- design token o layer di tema di un'app (`src/theme/`, `src/global.scss`): alto, perché
  cambia l'aspetto di tutte le pagine dell'app — legittimo quando la richiesta è globale, ma
  va dichiarato;
- servizi `core/` usati da molte pagine, routing e shell dell'app (`app.component.*`): medio-alto;
- file di più app, progetti nativi, nuove dipendenze o servizi Firebase: alto, e deve essere
  segnalato in `architectureFlags`.

## Cosa verificare in particolare

- la Declaration rispetta l'`AGENTS.md` dell'app (per esempio: niente altre librerie UI,
  token prima delle modifiche locali, solo CSS custom properties e `::part()`);
- `expectedFiles` e `allowedScope` restano nell'app del task;
- i test previsti, se richiesti, usano Vitest `*.spec.ts` e non nuovi framework;
- la Declaration non prevede di usare gli script npm dell'app che modificano file tracciati
  (stamp di revisione o build-info) né comandi di deploy.
