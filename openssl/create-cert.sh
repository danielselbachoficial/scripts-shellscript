#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachtech/                              #
# SCRIPT V.: 1.0 - OpenSSL                                                              #
#########################################################################################

# Definir diretório para os certificados
CERT_DIR="/etc/docker/certs"
mkdir -p "$CERT_DIR"

# Nome dos arquivos
KEY_FILE="$CERT_DIR/server-key.pem"
CSR_FILE="$CERT_DIR/server.csr"
CERT_FILE="$CERT_DIR/server-cert.pem"
CA_FILE="$CERT_DIR/ca.pem"
CA_KEY_FILE="$CERT_DIR/ca-key.pem"

# Perguntar informações ao usuário
read -p "Digite o nome comum (ex: www.exemplo.com): " COMMON_NAME
read -p "Digite o nome da organização: " ORGANIZATION
read -p "Digite o nome da unidade organizacional: " ORG_UNIT
read -p "Digite a cidade: " CITY
read -p "Digite o estado/província: " STATE
read -p "Digite o país (ex: BR): " COUNTRY
read -p "Digite o endereço de e-mail: " EMAIL

# Gerar a chave privada e o CSR
openssl req -new -newkey rsa:2048 -nodes -keyout "$KEY_FILE" -out "$CSR_FILE" \
    -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

if [ $? -ne 0 ]; then
    echo "Erro ao criar a chave ou CSR. Verifique as permissões e o OpenSSL."
    exit 1
fi

echo "Chave privada e CSR criados com sucesso!"

# Verificar se os arquivos CA existem
if [[ ! -f "$CA_FILE" || ! -f "$CA_KEY_FILE" ]]; then
    echo "Os arquivos de CA (ca.pem e ca-key.pem) não foram encontrados. Certifique-se de que estão no diretório $CERT_DIR."
    exit 1
fi

# Assinar o CSR com o certificado CA
openssl x509 -req -in "$CSR_FILE" -CA "$CA_FILE" -CAkey "$CA_KEY_FILE" -CAcreateserial \
    -out "$CERT_FILE" -days 365 -sha256

if [ $? -ne 0 ]; then
    echo "Erro ao assinar o CSR e gerar o certificado. Verifique os arquivos de CA."
    exit 1
fi

echo "Certificado gerado com sucesso: $CERT_FILE"
