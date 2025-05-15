#!/bin/bash

GRAFANA_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="admin123"

# Loop para criar 20 organizações
for i in $(seq 1 20); do
  ORG_NAME="Org-Exemplo-$i"

  echo "🛠️ Criando organização: $ORG_NAME"

  curl -s -X POST "$GRAFANA_URL/api/orgs" \
    -u "$ADMIN_USER:$ADMIN_PASS" \
    -H "Content-Type: application/json" \
    -d "{
          \"name\": \"$ORG_NAME\"
        }" | jq .
done

echo "✅ Criação de organizações concluída!"
