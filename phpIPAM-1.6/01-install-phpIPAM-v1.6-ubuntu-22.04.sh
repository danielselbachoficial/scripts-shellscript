#!/bin/bash

#########################################################################################
# DANIEL SELBACH FIGUEIRÓ                                                               #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachoficial/                           #
# SCRIPT V.: 1.1 - phpIPAM v1.6                                                         #
#########################################################################################

# Atualizar repositórios de sistema
sudo apt update
apt list --upgradable

# Instalar atualizações de sistema disponíveis
sudo apt upgrade -y

# Instalar os pacotes necessários
sudo apt install curl wget zip git -y

# Instalar o Apache e MySQL
sudo apt install apache2 mariadb-server mariadb-client -y

# Instalar os componentes PHP
sudo apt install php7.4 php7.4-curl php7.4-common php7.4-gmp php7.4-mbstring php7.4-gd php7.4-xml php7.4-mysql php7.4-ldap php-pear php-gd-y

# Configurar a base de dados do MySQL
sudo mysql_secure_installation <<EOF
n
y
your_password_here
y
y
y
y
EOF

# Cria o banco de dados e usuário para o PHP IPAM
sudo mysql -u root -p <<EOF
CREATE DATABASE php_ipam;
GRANT ALL ON php_ipam.* to 'phpipam'@'localhost' IDENTIFIED BY 'phpipamadmin';
FLUSH PRIVILEGES;
EXIT;
EOF

# Baixa o PHP IPAM
sudo git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam

cd /var/www/html/phpipam || exit

sudo git checkout "$(git tag --sort=v:tag | tail -n1)"

# Ajusta permissões
sudo chown -R www-data:www-data /var/www/html/phpipam

# Fazer uma cópia do arquivo "config.dist.php"
sudo cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php

# Editar o arquivo "config.php"
sudo bash -c "cat > /var/www/html/phpipam/config.php" <<EOF
<?php
\$db['host'] = '127.0.0.1';
\$db['user'] = 'phpipam';
\$db['pass'] = 'phpipamadmin';
\$db['name'] = 'php_ipam';
\$db['port'] = 3306;

define('BASE' , '/phpipam/');
EOF

# Habilitar o mod_rewrite
sudo a2enmod rewrite

# Reiniciar o serviço apache2
sudo systemctl restart apache2
