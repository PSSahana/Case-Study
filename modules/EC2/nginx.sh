#!bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1
sudo systemctl start nginx.service
sudo systemctl status nginx.service
echo "<h1>Welcome from $(hostname -f)</h1>" > /var/www/html/index.html