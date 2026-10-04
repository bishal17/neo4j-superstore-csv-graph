#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check required tools
for tool in uv git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: $tool is not installed or not on PATH."
    exit 1
  fi
done

echo "Found $(uv --version)"

# Create .env only if it doesn't already exist.
# This CSV workflow doesn't require an LLM API key.
ENV_FILE="$WORKSPACE_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Enter your local Neo4j connection details."
  read -r -p "Neo4j URI [neo4j://127.0.0.1:7687]: " NEO4J_URI
  NEO4J_URI="${NEO4J_URI:-neo4j://127.0.0.1:7687}"

  read -r -p "Neo4j username [neo4j]: " NEO4J_USERNAME
  NEO4J_USERNAME="${NEO4J_USERNAME:-neo4j}"

  read -r -s -p "Neo4j password: " NEO4J_PASSWORD
  echo
  if [ -z "$NEO4J_PASSWORD" ]; then
    echo "Error: Neo4j password cannot be empty."
    exit 1
  fi

  read -r -p "Neo4j database [neo4j]: " NEO4J_DATABASE
  NEO4J_DATABASE="${NEO4J_DATABASE:-neo4j}"

  # Quote values so special characters in the password are less likely
  # to break the .env file. The MCP servers read this file themselves.
  quote_env_value() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\'/\\\'}"
    printf "'%s'" "$value"
  }

  {
    echo "# Local Neo4j connection; do not commit this file."
    printf 'NEO4J_URI=%s\n' "$(quote_env_value "$NEO4J_URI")"
    printf 'NEO4J_USERNAME=%s\n' "$(quote_env_value "$NEO4J_USERNAME")"
    printf 'NEO4J_PASSWORD=%s\n' "$(quote_env_value "$NEO4J_PASSWORD")"
    printf 'NEO4J_DATABASE=%s\n' "$(quote_env_value "$NEO4J_DATABASE")"
  } > "$ENV_FILE"

  echo "Created .env"
else
  echo ".env already exists; leaving it unchanged."
fi

# Clone GraphRAG if it isn't already present.
GRAPHRAG_DIR="$WORKSPACE_DIR/mcp-neo4j-graphrag"

if [ ! -d "$GRAPHRAG_DIR" ]; then
  echo "Cloning the Neo4j GraphRAG MCP server..."
  git clone --depth 1 \
    https://github.com/neo4j-field/mcp-neo4j-graphrag \
    "$GRAPHRAG_DIR"

  # Use Python 3.12 for this server.
  echo "3.12" > "$GRAPHRAG_DIR/.python-version"
else
  echo "GraphRAG server folder already exists."
fi

# Install dependencies only for the CSV workflow's local servers.
for server in mcp-neo4j-ingest mcp-neo4j-graphrag; do
  if [ ! -d "$WORKSPACE_DIR/$server" ]; then
    echo "Error: expected folder not found: $server"
    exit 1
  fi

  echo "Installing dependencies for $server..."
  uv sync --directory "$WORKSPACE_DIR/$server"
done

# Use Windows-style paths in VS Code config when running from Git Bash.
CONFIG_WORKSPACE_DIR="$WORKSPACE_DIR"
if command -v cygpath >/dev/null 2>&1; then
  CONFIG_WORKSPACE_DIR="$(cygpath -m "$WORKSPACE_DIR")"
fi

# Generate VS Code MCP configuration for CSV work only.
mkdir -p "$WORKSPACE_DIR/.vscode"

cat > "$WORKSPACE_DIR/.vscode/mcp.json" << EOF
{
  "servers": {
    "neo4j-data-modeling": {
      "command": "uvx",
      "args": [
        "mcp-neo4j-data-modeling@0.8.2",
        "--transport",
        "stdio"
      ]
    },
    "neo4j-ingest": {
      "command": "uv",
      "args": [
        "--directory",
        "${CONFIG_WORKSPACE_DIR}/mcp-neo4j-ingest",
        "run",
        "mcp-neo4j-ingest"
      ]
    },
    "neo4j-graphrag": {
      "command": "uv",
      "args": [
        "--directory",
        "${CONFIG_WORKSPACE_DIR}/mcp-neo4j-graphrag",
        "run",
        "mcp-neo4j-graphrag"
      ]
    }
  }
}
EOF

echo
echo "Setup complete for the CSV workflow."
echo "Restart VS Code and check MCP: List Servers."
echo "Keep .env and .vscode/mcp.json out of GitHub."