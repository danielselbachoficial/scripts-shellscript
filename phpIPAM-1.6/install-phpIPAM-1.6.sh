#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachtech/                              #
# SCRIPT V.: 1.1 - phpIPAM v1.6                                                          #
#########################################################################################

# Atualiza os pacotes do sistema
sudo apt update -y
sudo apt upgrade -y

# Instala os pacotes necessários
sudo apt install -y nginx mysql-server php-fpm php-mysql php-cli php-mbstring php-json php-curl php-xml php-xmlrpc php-zip php-gmp php-gd php-pear git

# Inicia e habilita o NGINX e o MySQL
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start mysql
sudo systemctl enable mysql

# Configura o MySQL
sudo mysql_secure_installation <<EOF

y
root_password
root_password
y
y
y
y
EOF

# Remove instalação anterior do phpIPAM se existir
if [ -d "/var/www/phpipam" ]; then
    sudo rm -rf /var/www/phpipam
    echo "Instalação anterior do phpIPAM removida."
fi

# Cria o banco de dados e usuário para o PHP IPAM
sudo mysql -uroot -proot_password <<EOF
CREATE DATABASE IF NOT EXISTS phpipam;
CREATE USER IF NOT EXISTS 'phpipamuser'@'localhost' IDENTIFIED BY 'phpipampassword';
GRANT ALL PRIVILEGES ON phpipam.* TO 'phpipamuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Baixa o PHP IPAM
cd /var/www/
git clone https://github.com/phpipam/phpipam.git
cd phpipam
git config --global --add safe.directory /var/www/phpipam  # Adiciona o diretório seguro no Git
git checkout main  # Alterado para a branch principal, que é a mais atual

# Ajusta permissões
sudo chown -R www-data:www-data /var/www/phpipam
sudo chmod -R 755 /var/www/phpipam

# Cria o arquivo de configuração do NGINX se não existir
if [ ! -f /etc/nginx/sites-available/phpipam ]; then
    cat <<EOF | sudo tee /etc/nginx/sites-available/phpipam
server {
    listen 80;
    server_name your_domain_or_ip;  # Substitua pelo seu domínio ou IP

    root /var/www/phpipam;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;  # Altere para sua versão do PHP
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/phpipam /etc/nginx/sites-enabled/
else
    echo "Configuração do NGINX já existe."
fi

# Testa a configuração do NGINX
sudo nginx -t
sudo systemctl restart nginx

# Configuração do PHP IPAM
cp config.dist.php config.php

# Atualiza as configurações do banco de dados
sed -i "s/\$db_user = '.*'/\$db_user = 'phpipamuser'/g" config.php
sed -i "s/\$db_pass = '.*'/\$db_pass = 'phpipampassword'/g" config.php
sed -i "s/\$db_name = '.*'/\$db_name = 'phpipam'/g" config.php

# Reinicia o PHP-FPM
sudo systemctl restart php7.4-fpm  # Ou a versão do PHP que você está usando

# Conclui a instalação
echo "Instalação concluída! Acesse http://your_domain_or_ip para configurar o PHP IPAM."
