#!/bin/bash
apt update
apt install apache2 -y
cd /var/www/html
rm index.html
echo "<html><body><h1>Terraform provisioner example</h1><p>Welcome to my world</p></body></html>" > index.html