# Agent instructions — CSV to Neo4j

This project imports CSV data into Neo4j and queries it with Cypher.

## Workflow
1. Inspect the CSV headers and a few sample rows.
2. Explain the proposed nodes, relationships, and identifier fields before importing.
3. Use the Neo4j Ingest MCP tool for CSV imports. Use an absolute file path.
4. Before any database write, explain what will change and ask for confirmation.
5. Use Neo4j GraphRAG tools to verify imports and answer questions with Cypher.
6. Prefer read-only queries unless the user approves a specific change.

## Credentials and files
- Never read, print, or ask the user to share `.env` contents, passwords, or API keys.
- Never commit `.env`, local database files, or machine-specific MCP configuration.
- Do not run `uv sync` from the workspace root; server dependencies are managed in their own folders.