# phpIPAM v1.7.3 - Script de Instalação

## 👤 Autor
**Daniel Selbach**
[LinkedIn](https://www.linkedin.com/in/danielselbachoficial/)


## 🔗 Descrição

Este script automatiza a instalação completa do **phpIPAM v1.7.3** nos sistemas operacionais:

* Debian 12
* Ubuntu Server 22.04 LTS
* Ubuntu Server 24.04 LTS

Inclui configuração do ambiente LAMP/LEMP, banco de dados MariaDB, PHP 8.x e deployment da aplicação.

## 🚀 Funcionalidades

* ✅ Instalação automática do phpIPAM v1.7.3
* ✅ Configuração de Apache ou Nginx como servidor web
* ✅ Configuração segura do MariaDB
* ✅ Instalação de dependências PHP
* ✅ Deploy do código-fonte oficial
* ✅ Configuração de VirtualHost (Apache) ou Server Block (Nginx)
* ✅ Suporte a PHP 8.3

## 💻 Requisitos do Sistema

* Sistema operacional: Debian 12, Ubuntu 22.04 LTS ou Ubuntu 24.04 LTS
* Acesso root
* Conexão com a internet
* Recursos mínimos: 2GB RAM, 2 vCPU

## 📦 Componentes Instalados

* **Servidor Web**: Apache 2.4.x ou Nginx 1.18+
* **Banco de Dados**: MariaDB 10.6+
* **PHP**: PHP 8.1+ com módulos necessários
* **Outros**: git, curl, wget, unzip

## ⚙️ Como Usar

1. **Baixe o script:**

```bash
wget https://github.com/danielselbachoficial/scripts-shellscript/blob/main/phpIPAM-v1.7.3%20%20/install-phpIPAM-v1.7.3.sh
chmod +x install-phpIPAM-v1.7.3.sh
ls -l install-phpIPAM-v1.7.3.sh
```

2. **Execute o script como root:**

```bash
sudo ./install-phpIPAM-v1.7.3.sh
```

3. **Escolha o servidor web:**

* Digite `1` para Apache
* Digite `2` para Nginx

4. **Acesse a interface web:**

```
http://<SEU_IP>/phpipam
```

## 🔑 Credenciais Padrão do Banco de Dados

| Parâmetro | Valor        |
| --------- | ------------ |
| Database  | phpipam      |
| User      | phpipam      |
| Password  | phpipamadmin |
| Host      | 127.0.0.1    |
| Porta     | 3306         |

> **Atenção**: Altere a senha padrão após a instalação.

## 🔁 Novidades da Versão 1.7.3

* ✅ Suporte a autenticação por Passkeys
* ✅ Atualização de bibliotecas: jQuery 3.7.1, Bootstrap 3.4.1
* ✅ Correção de vulnerabilidades de segurança (XSS)
* ✅ Melhorias na API e na interface

## ⚠️ Notas de Segurança

* Alterar imediatamente as credenciais padrão.
* Restringir o acesso ao banco de dados.
* Configurar SSL/TLS para o servidor web.

## 📚 Documentação Oficial

* [phpIPAM Documentation](https://phpipam.net/documents/)
* [Changelog v1.7.3](https://github.com/phpipam/phpipam/releases)

## 👥 Contribuição

Pull Requests são bem-vindos! Para sugestões, abra uma **issue**.

## 🔖 Licença

Este script é distribuído sob a Licença MIT.
