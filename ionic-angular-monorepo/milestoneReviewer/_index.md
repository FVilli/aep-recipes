# Guida Milestone Reviewer — ionic-angular-monorepo

Questo documento integra il tuo ruolo AEP standard: qui trovi solo criteri specifici di questo
**stack** per giudicare il diff complessivo del branch.

## Cosa verificare in particolare

- **Perimetro delle app**: il branch modifica solo le app che la richiesta nomina; modifiche ad
  altre app o alla radice del repository sono un finding anche se ogni task era stato approvato.
- **Coerenza del tema**: più task che hanno ciascuno ritoccato localmente colori, spaziature o
  raggi invece di convergere sui design token dell'app sono un segnale da riportare.
- **Dipendenze e servizi**: nuove dipendenze npm o nuovi servizi Firebase devono essere
  motivati dalla richiesta.
- **Regole locali**: il risultato complessivo rispetta l'`AGENTS.md` dell'app (identità Ionic,
  responsive, accessibilità).
