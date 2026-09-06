# aep-recipes

Catalogo pubblico delle recipe per [AEP (Agentic Engineering Protocol)](https://github.com/FVilli/aep).

Una recipe insegna agli agenti di AEP le convenzioni di uno stack tecnologico specifico
(es. "come si chiama un'API esterna in questo progetto NestJS", "che pattern di modulo usare")
— non le regole di prodotto della milestone, quelle vengono sempre dalla richiesta umana.

## Struttura

Ogni ricetta è una cartella a livello radice:

```
<nome-ricetta>/
├── recipe.yaml              # layer deterministico: requiredPaths, checks
├── architect/_index.md
├── developerDeclaration/_index.md
├── planReviewer/_index.md
├── developerImplementation/
│   ├── _index.md
│   └── <file di riferimento aggiuntivi, es. trello-client.md>
├── codeReviewer/_index.md
└── milestoneReviewer/_index.md
```

Le sei sottocartelle corrispondono esattamente ai sei ruoli del protocollo AEP. Solo
`_index.md` viene iniettato nel prompt di sistema del ruolo corrispondente; gli altri file
in `developerImplementation/` sono un manuale che l'agente esplora da sé con i propri
strumenti, solo se `_index.md` lo suggerisce.

## Come un'istanza AEP consulta questo repository

Un'istanza AEP **non clona mai questo repository per intero**. Durante l'onboarding di un
nuovo progetto:

1. Legge solo [`index.md`](index.md) (via `git sparse-checkout`) per conoscere nome e
   descrizione di ogni ricetta disponibile — un solo file, indipendentemente da quante
   ricette esistano.
2. Un umano sceglie una ricetta.
3. Solo a quel punto il contenuto completo di quella cartella viene scaricato ed effettivamente
   copiato nel progetto target.

Le altre ricette non vengono mai scaricate.

## Aggiungere una nuova ricetta

1. Crea la cartella con la struttura sopra.
2. **Aggiungi una voce in [`index.md`](index.md)** (nome + descrizione, nel blocco YAML in
   cima al file). Questo è l'unico posto da cui un'istanza AEP scopre che la ricetta esiste —
   una cartella senza voce in `index.md` è invisibile a qualunque catalogo, anche se il suo
   contenuto è perfettamente valido.
3. Commit e push su `main`.

La descrizione vive **solo** in `index.md`, non in `recipe.yaml` — un solo posto da tenere
aggiornato, niente rischio che le due descrizioni finiscano per dire cose diverse.
