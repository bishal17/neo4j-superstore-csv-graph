# CSV to Neo4j Graph with VS Code and MCP

This project demonstrates importing the **Sample Superstore CSV** into a local Neo4j database, then exploring the resulting graph with Cypher and AI tools in VS Code.

It is based on the [Neo4j MCP Workspace Template](https://github.com/neo4j-field/neo4j-mcp-workspace-template). The original template supports additional tools and PDF workflows; this project walkthrough focuses on the CSV workflow.

## What I did

- Set up a local Neo4j database using Neo4j Desktop.
- Connected the project’s MCP servers to Neo4j from VS Code.
- Imported 9,994 rows from `Sample - Superstore.csv`.
- Queried the graph using Neo4j Browser and VS Code Copilot Agent.

The reported graph counts after import were:

| Node label | Count |
|---|---:|
| `Customer` | 793 |
| `Order` | 5,009 |
| `Product` | 1,862 |
| `OrderLine` | 9,994 |

| Relationship type | Count |
|---|---:|
| `PLACED` | 5,009 |
| `HAS_LINE` | 9,994 |
| `FOR_PRODUCT` | 9,994 |

## Graph structure

The imported graph represents customers, their orders, the line items in each order, and the products on those line items:

```text
(Customer)-[:PLACED]->(Order)
(Order)-[:HAS_LINE]->(OrderLine)
(OrderLine)-[:FOR_PRODUCT]->(Product)
```plaintext

## Tools used

- **Neo4j Desktop** — runs the local Neo4j database.
- **VS Code with GitHub Copilot Agent** — lets me ask questions in natural language and use the configured MCP tools.
- **Neo4j Ingest MCP server** — imports the CSV.
- **Neo4j GraphRAG MCP server** — queries the graph using Cypher.
- **Neo4j Data Modeling MCP server** — provides graph-model examples and modeling support.

The template also includes PDF-related MCP servers. They are not used in this CSV demonstration.

## Prerequisites

- Windows
- [Git for Windows](https://git-scm.com/download/win), which includes Git Bash
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- [Neo4j Desktop](https://neo4j.com/download/)
- VS Code with GitHub Copilot Chat

## Setup

1. Create and start a local database in Neo4j Desktop.
2. Open the project folder in Git Bash.
3. If setting up a fresh copy, run:

   ```bash
   bash ./setup.sh
   ```

4. Enter the Neo4j connection details when prompted. The database name is usually `neo4j`; use the password you set in Neo4j Desktop.
5. The setup script may ask for an OpenAI API key. CSV import and ordinary Cypher queries do not use the PDF embedding/entity-extraction features, so those features are not part of this demo.
6. Open the project folder in VS Code. The VS Code MCP configuration is `.vscode/mcp.json`.
7. In VS Code, use **MCP: List Servers** from the Command Palette to check that the needed servers are running.

If a server fails to start on Windows, check that its `--directory` value in `.vscode/mcp.json` uses a Windows path, for example:

```text
C:/Users/your-name/neo4j-mcp-workspace-template/mcp-neo4j-ingest
```plaintext

Do not publish local configuration containing your computer’s paths or credentials.

## Importing the CSV

Use the Neo4j Ingest MCP tool, `ingest_csv_into_neo4j`, from VS Code Copilot Chat in **Agent** mode. Provide the CSV’s absolute path and review the proposed import before approving a database write.

Example request:

> Inspect `Sample - Superstore.csv`, explain the proposed graph import, and wait for my approval before writing anything to Neo4j.

## Example Cypher queries

Run these in **Neo4j Browser**. The Browser query box expects Cypher, not plain English.

### Count nodes by label

```cypher
MATCH (n)
RETURN labels(n) AS labels, count(*) AS count
ORDER BY count DESC;
```plaintext

### View connected customer, order, line-item, and product records

```cypher
MATCH (c:Customer)-[:PLACED]->(o:Order)
      -[:HAS_LINE]->(line:OrderLine)
      -[:FOR_PRODUCT]->(p:Product)
RETURN c, o, line, p
LIMIT 10;
```plaintext

### Find customers with the most orders

```cypher
MATCH (c:Customer)-[:PLACED]->(o:Order)
RETURN properties(c) AS customer, count(o) AS orderCount
ORDER BY orderCount DESC
LIMIT 10;
```plaintext

You can also ask questions in English in **VS Code Copilot Chat**, with Agent mode selected. For example:

> Using the Neo4j MCP tools, show the 10 customers with the most orders. Use read-only queries and show me the Cypher query you ran.

## Data and credentials

- Keep `.env` private. It may contain your Neo4j password or API keys.
- Do not commit `.env`, `.venv/`, Neo4j database files, or local MCP configuration with machine-specific paths.
- Check the dataset’s source and usage terms before publishing the CSV itself. If you cannot redistribute it, document where it came from and how to obtain it instead.
- Check the original repository’s license and preserve any required notices or attribution.

## Credits

This project uses the [Neo4j MCP Workspace Template](https://github.com/neo4j-field/neo4j-mcp-workspace-template). The setup and MCP server framework come from that template; the project description and results above reflect my local CSV import and exploration.
`