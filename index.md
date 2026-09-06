---
recipes:
  - name: nestjs-trello-inference
    description: >-
      Backend NestJS che integra Trello (board/card, webhook) con un provider di
      inferenza LLM con supporto tool calling (lettura card/board, web search,
      knowledge base). Adatto a progetti che combinano questi stessi tre elementi:
      NestJS, API Trello, un modello LLM invocato in modo agentico.
---

# Catalogo ricette AEP

Questo file è l'unica fonte di verità che un'istanza AEP legge per sapere quali ricette
esistono in questo repository, senza mai scaricarlo per intero (vedi `README.md` per il
meccanismo). Ogni nuova ricetta va aggiunta qui, nel blocco YAML sopra, oltre che come
cartella reale — una cartella senza voce qui non comparirà mai in nessun catalogo.

| Ricetta | Descrizione |
|---|---|
| [nestjs-trello-inference](nestjs-trello-inference/) | Backend NestJS che integra Trello (board/card, webhook) con un provider di inferenza LLM con supporto tool calling (lettura card/board, web search, knowledge base). Adatto a progetti che combinano questi stessi tre elementi: NestJS, API Trello, un modello LLM invocato in modo agentico. |
