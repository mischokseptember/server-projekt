# server-projekt

```
# Altlasten aufräumen
tofu destroy

# Eigenes Schlüsselpaar erzeugen
wg genkey > vpn-keys/anna.priv
wg pubkey < vpn-keys/anna.priv > vpn-keys/anna.pub

# VPN-Server mieten und starten
tofu apply

# VPN-Verbindung starten (aber korrektes öffentliches Serverschloss einsetzen)
sudo bash connect.sh zuacTUd23m1qdhQGdhrPN724LdLlokuIMuY6oTYIMiA= 192.168.0.105 vpn-keys/anna.priv
```
