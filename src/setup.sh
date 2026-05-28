#!/bin/bash

set -e

echo "[+] Installation des paquets nécessaires..."

sudo apt update
sudo apt install -y hostapd dnsmasq iptables-persistent lighttpd

echo "[+] Création du dossier web..."
mkdir -p ../web

cat > ../web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>TP Evil Twin - Démonstration</title>
</head>
<body>
    <h1>TP Evil Twin</h1>
    <p>Ceci est une page captive pédagogique.</p>
    <p>Aucun identifiant n'est collecté.</p>
</body>
</html>
EOF

echo "[+] Setup terminé."
echo "Lance ensuite : sudo ./startup.sh"