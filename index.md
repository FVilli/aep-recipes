---
recipes:
  - name: nestjs-trello-inference
    description: >-
      Backend NestJS che integra Trello (board/card, webhook) con un provider di
      inferenza LLM con supporto tool calling (lettura card/board, web search,
      knowledge base). Adatto a progetti che combinano questi stessi tre elementi:
      NestJS, API Trello, un modello LLM invocato in modo agentico.
    stack:
      - nestjs
      - trello-api
      - llm-inference
  - name: ionic-angular-monorepo
    description: >-
      Monorepo di app Ionic standalone: ogni cartella alla radice è un'app Angular
      (componenti standalone) + Ionic + Capacitor indipendente, pubblicata con Firebase
      Hosting; Auth e Firestore tramite AngularFire solo se una milestone li introduce.
      Nessun progetto alla radice. Check: build e test unitari Vitest di ogni app.
    stack:
      - angular
      - ionic
      - capacitor
      - firebase-hosting
      - vitest
      - monorepo
---

# Catalogo ricette AEP

Questo file è l'unica fonte di verità che un'istanza AEP legge per sapere quali ricette
esistono in questo repository, senza mai scaricarlo per intero (vedi `README.md` per il
meccanismo). Ogni nuova ricetta va aggiunta qui, nel blocco YAML sopra, oltre che come
cartella reale — una cartella senza voce qui non comparirà mai in nessun catalogo.

`stack` è l'elenco delle tecnologie che la ricetta assume (framework, ORM, database,
integrazioni principali) — è il campo che l'agente di matching usa per confrontare lo stack
reale di un progetto con quello di ciascuna ricetta, anche quando il confronto non è netto
(es. stesso framework ma ORM diverso): usa tag brevi in kebab-case, uno per ogni tecnologia
rilevante, non frasi.

| Ricetta | Descrizione | Stack |
|---|---|---|
| [nestjs-trello-inference](nestjs-trello-inference/) | Backend NestJS che integra Trello (board/card, webhook) con un provider di inferenza LLM con supporto tool calling (lettura card/board, web search, knowledge base). Adatto a progetti che combinano questi stessi tre elementi: NestJS, API Trello, un modello LLM invocato in modo agentico. | nestjs, trello-api, llm-inference |
| [ionic-angular-monorepo](ionic-angular-monorepo/) | Monorepo di app Ionic standalone (Angular + Ionic + Capacitor) pubblicate con Firebase Hosting, una cartella per app alla radice. | angular, ionic, capacitor, firebase-hosting, vitest, monorepo |
