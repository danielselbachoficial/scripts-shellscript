#!/bin/bash

GRAFANA_URL="http://localhost:3000"

# Pergunta o admin
read -p "👤 Usuário admin do Grafana: " ADMIN_USER
read -s -p "🔐 Senha do admin do Grafana: " ADMIN_PASS
echo ""

# Pergunta os dados do novo usuário
read -p "👤 Login do novo usuário: " NEW_USER_LOGIN
read -p "📛 Nome completo do novo usuário: " NEW_USER_NAME
read -s -p "🔑 Senha do novo usuário: " NEW_USER_PASSWORD
echo ""

# 1. Cria o usuário
curl -s -X POST "$GRAFANA_URL/api/admin/users" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d "{
        \"name\": \"$NEW_USER_NAME\",
        \"login\": \"$NEW_USER_LOGIN\",
        \"password\": \"$NEW_USER_PASSWORD\"
      }" | jq .

# 2. Obtém o ID do novo usuário
USER_ID=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" \
  "$GRAFANA_URL/api/users/lookup?loginOrEmail=$NEW_USER_LOGIN" | jq -r .id)

if [[ "$USER_ID" == "null" || -z "$USER_ID" ]]; then
  echo "❌ Não foi possível obter o ID do usuário."
  exit 1
fi

# 3. Lista todas as organizações
ORG_IDS=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" \
  "$GRAFANA_URL/api/orgs" | jq -r '.[].id')

# 4. Adiciona o novo usuário como Admin em todas as orgs
for ORG_ID in $ORG_IDS; do
  echo "🔁 Adicionando '$NEW_USER_LOGIN' como Admin na organização ID $ORG_ID"

  curl -s -X POST "$GRAFANA_URL/api/orgs/$ORG_ID/users" \
    -u "$ADMIN_USER:$ADMIN_PASS" \
    -H "Content-Type: application/json" \
    -d "{
          \"loginOrEmail\": \"$NEW_USER_LOGIN\",
          \"role\": \"Admin\"
        }" | jq .
done

echo "✅ Finalizado! '$NEW_USER_LOGIN' agora é Admin em todas as organizações."
