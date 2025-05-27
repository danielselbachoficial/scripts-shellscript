#!/bin/bash

#########################################################################################
# Autor: Daniel S. Figueiró                                                             #
# Versão: 1.3 - phpIPAM v1.7.3                                                          #
# Compatível com: Debian 12, Ubuntu Server 22.04 LTS, Ubuntu Server 24.04 LTS           #
# Requisitos: PHP >= 7.2, MariaDB >= 10.3                                               #
#########################################################################################

# Função para verificar se o script está sendo executado como root
verificar_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script deve ser executado como root."
        exit 1
    fi
}

# Atualizar repositórios e pacotes do sistema
atualizar_sistema() {
    apt update && apt upgrade -y
}

# Instalar pacotes essenciais
instalar_pacotes_essenciais() {
    apt install -y sudo curl wget zip git unzip lsb-release gnupg2 ca-certificates
}

# Instalar e configurar o servidor web (Apache ou Nginx)
instalar_servidor_web() {
    echo "Escolha o servidor web: 1 - Apache | 2 - Nginx"
    read -r webserver_choice

    if [ "$webserver_choice" -eq 1 ]; then
        echo "Instalando Apache..."
        apt install -y apache2 libapache2-mod-php
        a2enmod rewrite
        systemctl enable apache2
    elif [ "$webserver_choice" -eq 2 ]; then
        echo "Instalando Nginx..."
        apt install -y nginx
        systemctl enable nginx
    else
        echo "Escolha inválida! Encerrando o script."
        exit 1
    fi
}

# Instalar e configurar o MariaDB
instalar_mariadb() {
    apt install -y mariadb-server mariadb-client
    systemctl enable mariadb

    # Configuração segura do MariaDB
    mysql_secure_installation <<EOF

y
phpipamadmin
phpipamadmin
y
y
y
y
EOF

    # Criar banco de dados e usuário para o phpIPAM
    mysql -u root -p'phpipamadmin' <<EOF
CREATE DATABASE phpipam;
GRANT ALL PRIVILEGES ON phpipam.* TO 'phpipam'@'localhost' IDENTIFIED BY 'phpipamadmin';
FLUSH PRIVILEGES;
EXIT;
EOF
}

# Instalar componentes PHP necessários
instalar_php() {
    apt install -y php php-fpm php-curl php-mysql php-gmp php-mbstring php-xml php-ldap php-gd php-pear php-json
    systemctl enable php-fpm
}

# Baixar e configurar o phpIPAM
instalar_phpipam() {
    git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam
    cd /var/www/html/phpipam || exit
    git checkout 1.7
    git submodule update --init --recursive

    chown -R www-data:www-data /var/www/html/phpipam
    chmod -R 755 /var/www/html/phpipam

    cp config.dist.php config.php
    sed -i "s/'host'.*/'host' => '127.0.0.1',/" config.php
    sed -i "s/'user'.*/'user' => 'phpipam',/" config.php
    sed -i "s/'pass'.*/'pass' => 'phpipamadmin',/" config.php
    sed -i "s/'name'.*/'name' => 'phpipam',/" config.php
    sed -i "s/'port'.*/'port' => 3306,/" config.php
    echo "define('BASE', '/phpipam/');" >> config.php
}

# Configurar o VirtualHost para Apache
configurar_apache() {
    cat > /etc/apache2/sites-available/phpipam.conf <<EOF
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
    a2ensite phpipam.conf
    systemctl reload apache2
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
}

# Configurar o servidor Nginx
configurar_nginx() {
    cat > /etc/nginx/sites-available/phpipam <<EOF
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
        fastcgi_pass unix:/run/php/php-fpm.sock;
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
    ln -s /etc/nginx/sites-available/phpipam /etc/nginx/sites-enabled/
    systemctl reload nginx
}

# Reiniciar serviços
reiniciar_servicos() {
    if [ "$webserver_choice" -eq 1 ]; then
        systemctl restart apache2
        systemctl status apache2
    elif [ "$webserver_choice" -eq 2 ]; then
        systemctl restart nginx
        systemctl status nginx
    fi
    systemctl restart mariadb
    systemctl status mariadb
}

# Execução das funções
verificar_root
atualizar_sistema
instalar_pacotes_essenciais
instalar_servidor_web
instalar_mariadb
instalar_php
instalar_phpipam

if [ "$webserver_choice" -eq 1 ]; then
    configurar_apache
elif [ "$webserver_choice" -eq 2 ]; then
    configurar_nginx
fi

reiniciar_servicos

echo "Instalação concluída! Acesse seu phpIPAM via http://<seu_ip>/phpipam"
