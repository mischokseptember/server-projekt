# server-projekt

```
# Altlasten aufräumen
tofu destroy

# Neueste Version vom Repository holen
git pull

# Eigenes Schlüsselpaar erzeugen
(
  umask 077
  wg genkey > vpn-keys/anna.priv
)
wg pubkey < vpn-keys/anna.priv > vpn-keys/anna.pub

# VPN-Schlüsseldatei und Wunsch-IP-Adresse in main.tf angeben
nano main.tf

# Änderungen auf GitHub laden
git add vpn-keys/anna.pub
git commit -a
git push

# VPN-Server mieten und starten
tofu apply

# VPN-Verbindung starten (aber korrektes öffentliches Serverschloss einsetzen,
# dieses kann auf https://ntfy.sh/mischok-citest eingesehen werden)
sudo bash connect.sh zuacTUd23m1qdhQGdhrPN724LdLlokuIMuY6oTYIMiA= 192.168.0.105 vpn-keys/anna.priv

# optional als viertes Argument die Server-IP angeben
sudo bash connect.sh zuacTUd23m1qdhQGdhrPN724LdLlokuIMuY6oTYIMiA= 192.168.0.105 vpn-keys/anna.priv 3.79.14.80
```
