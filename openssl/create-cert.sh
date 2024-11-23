#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachredes/                              #
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
read -p "Digite o IP para SAN (ex: 199.1.1.2): " IP_SAN

# Criar o arquivo de configuração do OpenSSL
cat > "$CERT_DIR/server.cnf" <<EOL
[req]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = v3_req
prompt = no

[req_distinguished_name]
countryName            = $COUNTRY
stateOrProvinceName    = $STATE
localityName           = $CITY
organizationName       = $ORGANIZATION
organizationalUnitName = $ORG_UNIT
commonName             = $COMMON_NAME

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP_SAN
EOL

# Gerar a chave privada e o CSR
openssl req -new -newkey rsa:2048 -nodes -keyout "$KEY_FILE" -out "$CSR_FILE" -config "$CERT_DIR/server.cnf"

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
openssl x509 -req -in "$CSR_FILE" -CA "$CA_FILE" -CAkey "$CA_KEY_FILE" -CAcreateserial -out "$CERT_FILE" -days 365 -sha256

if [ $? -ne 0 ]; then
    echo "Erro ao assinar o CSR e gerar o certificado. Verifique os arquivos de CA."
    exit 1
fi

# Limpar o arquivo de configuração
rm "$CERT_DIR/server.cnf"

echo "Certificado gerado com sucesso: $CERT_FILE"
