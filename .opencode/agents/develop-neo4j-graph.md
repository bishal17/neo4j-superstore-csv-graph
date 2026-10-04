---
name: develop-neo4j-graph
description: Build and query Neo4j graphs from CSV data. Use when inspecting CSV files, designing a graph model, importing CSV data into Neo4j, or analyzing the resulting graph with Cypher.
---

# CSV-to-Neo4j workflow

Use this skill for CSV-based graph projects only. Do not start PDF parsing, embedding, or entity-extraction workflows.

1. Inspect the CSV headers and a small sample of rows.
2. Explain the proposed graph model: node labels, properties, relationship types, and identifier fields.
3. Before importing, explain what the import will create or update. Ask for confirmation before running any operation that writes to the database.
4. Use the Neo4j Ingest MCP tools for CSV imports. Use an absolute file path.
5. Verify the import with read-only queries using the Neo4j GraphRAG MCP tools.
6. For user questions, inspect the graph schema and property names first, then run suitable read-only Cypher queries and explain the results.

## Safety and credentials

- Never read, print, or ask the user to share `.env` contents, passwords, or API keys.
- Do not expose credentials in responses, logs, or generated files.
- Do not run write queries unless the user has approved the specific operation.
- Do not delete or overwrite existing graph data unless the user explicitly requests it.