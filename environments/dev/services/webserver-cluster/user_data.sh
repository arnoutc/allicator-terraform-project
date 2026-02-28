#!/bin/bash
set -euxo pipefail

# Update packages (AL2023 uses dnf)
dnf upgrade -y

# Install Apache (httpd) and start it
dnf install -y httpd

# Enable and start the service
systemctl enable --now httpd

# Create a simple test page
cat >/var/www/html/index.html <<'HTML'
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>It works! (AL2023 + Apache)</title>
    </head>
    <body>
        <h1>Amazon Linux 2023 + Apache httpd</h1>
        <p>Provisioned via EC2 user_data.</p>
    </body>
</html>
HTML

# Optional: tighten default permissions for /var/www
usermod -a -G apache ec2-user || true
chown -R ec-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
