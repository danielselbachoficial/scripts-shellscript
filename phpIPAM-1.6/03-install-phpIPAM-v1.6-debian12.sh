#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachtech/                              #
# SCRIPT V.: 1.2 - phpIPAM v1.6                                                         #
#########################################################################################

# Atualizar repositórios de sistema
sudo apt update
apt list --upgradable

# Instalar atualizações de sistema disponíveis
sudo apt upgrade -y

# Instalar pacotes essenciais
sudo apt install curl wget zip git -y

# Escolher entre Apache ou Nginx
echo "Escolha o servidor web: 1 - Apache | 2 - Nginx"
read -r webserver_choice

if [ "$webserver_choice" -eq 1 ]; then
    echo "Instalando Apache..."
    sudo apt install apache2 -y
    sudo a2enmod rewrite
    sudo systemctl enable apache2
elif [ "$webserver_choice" -eq 2 ]; then
    echo "Instalando Nginx..."
    sudo apt install nginx -y
    sudo systemctl enable nginx
else
    echo "Escolha inválida! Encerrando o script."
    exit 1
fi

# Instalar e configurar MariaDB
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb

# Configuração segura do MariaDB
sudo mysql_secure_installation <<EOF
n
y
your_password_here
y
y
y
y
EOF

# Cria banco de dados e usuário para o phpIPAM
sudo mysql -u root -p <<EOF
CREATE DATABASE php_ipam;
GRANT ALL ON php_ipam.* TO 'phpipam'@'localhost' IDENTIFIED BY 'phpipamadmin';
FLUSH PRIVILEGES;
EXIT;
EOF

# Instalar componentes PHP necessários
sudo apt install php php-fpm php-curl php-mysql php-gmp php-mbstring php-xml -y
sudo systemctl enable php-fpm

# Baixar e configurar phpIPAM
sudo git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam
cd /var/www/html/phpipam || exit
sudo git checkout "$(git tag --sort=v:tag | tail -n1)"
sudo chown -R www-data:www-data /var/www/html/phpipam
sudo chmod -R 775 /var/www/html/phpipam/app/admin/import-export/upload

# Configurar o arquivo config.php
sudo cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php
sudo bash -c "cat > /var/www/html/phpipam/config.php" <<EOF
<?php
\$db['host'] = '127.0.0.1';
\$db['user'] = 'phpipam';
\$db['pass'] = 'phpipamadmin';
\$db['name'] = 'php_ipam';
\$db['port'] = 3306;

define('BASE' , '/phpipam/');
EOF

# Configuração do VirtualHost para Apache (se escolhido)
if [ "$webserver_choice" -eq 1 ]; then
    sudo bash -c "cat > /etc/apache2/sites-available/phpipam.conf" <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/phpipam
    <Directory /var/www/html/phpipam>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/phpipam_error.log
    CustomLog \${APACHE_LOG_DIR}/phpipam_access.log combined
</VirtualHost>
EOF
    sudo a2ensite phpipam.conf
    sudo systemctl reload apache2

    # Configurar ServerName
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
fi

# Configuração do Nginx (se escolhido)
if [ "$webserver_choice" -eq 2 ]; then
    sudo bash -c "cat > /etc/nginx/sites-available/phpipam" <<EOF
server {
    listen 80;
    server_name _;

    root /var/www/html/phpipam;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;  # Altere a versão conforme necessário
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/phpipam_error.log;
    access_log /var/log/nginx/phpipam_access.log;
}
EOF
    sudo ln -s /etc/nginx/sites-available/phpipam /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
fi

# Testar serviços
if [ "$webserver_choice" -eq 1 ]; then
    sudo systemctl restart apache2
    sudo systemctl status apache2
elif [ "$webserver_choice" -eq 2 ]; then
    sudo systemctl restart nginx
    sudo systemctl status nginx
fi
sudo systemctl restart mariadb
sudo systemctl status mariadb

echo "Instalação concluída! Acesse seu phpIPAM via http://<seu_ip>/phpipam"
