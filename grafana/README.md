# 📊 Scripts de Automação para Grafana

Este repositório é dedicado a **scripts em Shell/Bash para automatizar tarefas administrativas no Grafana**, voltado especialmente para profissionais de DevOps, SREs e administradores de infraestrutura que buscam **mais eficiência e padronização** na gestão do Grafana.

---

## 🚀 O que você vai encontrar aqui

Scripts para automatizar:

- ✅ Criação de múltiplas organizações
- ✅ Criação de usuários via API
- ✅ Atribuição de usuários como **Admin** em todas as organizações
- ✅ Exemplos de integração com `curl` e `jq` para chamadas à API REST do Grafana

Tudo com foco em:

- **Economia de tempo**
- **Padronização de ambientes**
- **Facilidade de uso**

---

## 🛠️ Pré-requisitos

- Shell Script (Bash)
- `nano e/ou vim` instalado
- `curl` instalado
- `jq` instalado (`sudo apt install jq`)

---

## 📎 Exemplos disponíveis

- `criar_usuario_admin_em_todas_orgs.sh`: script interativo que cria um usuário e o adiciona como Admin em todas as orgs existentes.
- `criar.orgs.sh`: cria 20 organizações de exemplo no Grafana, ideal para ambientes de testes ou labs.

---

## 📥 Como usar

```bash
# Criar o arquivo com editor de texto "nano" ou "vim".
nano ou vim

# Dê permissão de execução
chmod +x nome_do_script.sh

# Execute o script
./nome_do_script.sh
