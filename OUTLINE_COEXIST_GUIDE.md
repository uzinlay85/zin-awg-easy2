# Outline VPN Coexistence & Troubleshooting Setup Guide
*(AmneziaWG 2.0 + 3X-UI + Outline VPN Multi-Protocol Coexistence)*

ဤလမ်းညွှန်သည် **AmneziaWG 2.0** (Port 443) နှင့် **3X-UI** (Port 2053, 8443) တို့ လည်ပတ်နေပြီးသား VPS ဆာဗာတစ်ခုတည်းပေါ်တွင် **Outline VPN (Shadowbox)** ကို Port မတိုက်ဘဲ အောင်မြင်စွာ တပ်ဆင်တွဲဖက် အသုံးပြုနည်းနှင့် ကြုံတွေ့ရတတ်သော **Docker TLS Handshake Timeout / MTU Blackhole** ပြဿနာများကို ဖြေရှင်းနည်း ပြည့်စုံသော မှတ်တမ်းဖြစ်ပါသည်။

---

## ၁။ ကြုံတွေ့ခဲ့ရသော အခက်အခဲများနှင့် ဖြစ်ရသည့် အကြောင်းရင်းများ (Root Cause Analysis)

### ပြဿနာ (၁) - `quay.io/outline/shadowbox:stable`: `net/http: TLS handshake timeout`
Outline တပ်ဆင်စဉ် `Starting Shadowbox ... FAILED` ဖြစ်ပြီး Docker log တွင် Quay.io သို့ ချိတ်ဆက်ရာ၌ TLS handshake timeout ဖြစ်သွားခဲ့သည်။

#### ဖြစ်ရသည့် အကြောင်းရင်း (The Root Cause):
1. **PMTUD (Path MTU Discovery) Blackhole & Packet Fragmentation**:
   - `curl -Iv https://quay.io/v2/` ဖြင့် စစ်ဆေးကြည့်ရာ TCP SYN/ACK (3-way handshake) သည် အောင်မြင်သော်လည်း TLS Client Hello ပို့ပြီးနောက် Server Certificate အပြန်အလှန် လဲလှယ်ချိန်တွင် `SSL connection timeout` ဖြစ်သွားခဲ့သည်။
   - **အကြောင်းရင်း**: TCP Handshake packet သေးငယ်သော အချိန်တွင် ချိတ်ဆက်မှု ပေါက်သော်လည်း TLS Handshake အဆင့်တွင် ဆာဗာမှ ပေးပို့သော Certificate Packets များသည် Size ကြီးမားပါသည် (1400 bytes အထက်)။ VPS Network Interface ၏ Default MTU (1500) သည် အထက် ISP / Cloud Provider Tunnel ၏ MTU ထက် ကြီးမားနေပြီး၊ ပိုလျှံသော Packets များကို ကြားခံ Network က Drop ပစ်လိုက်သောကြောင့် Handshake မပြီးဆုံးနိုင်ဘဲ Timeout ဖြစ်သွားခြင်း ဖြစ်သည်။
2. **Docker DNS Resolution**:
   - Docker daemon သည် default အားဖြင့် host ၏ local DNS stub ကို သုံးတတ်ပြီး `quay.io` ကဲ့သို့သော RedHat registry များကို lookup လုပ်ရာတွင် နှေးကွေးခြင်း သို့မဟုတ် IPv6 routing မရှိသော လိပ်စာများသို့ ဦးစားပေး ချိတ်မိနေခြင်း ဖြစ်သည်။

#### ဖြေရှင်းချက် (The Solution):
- VPS Network Interface နှင့် Docker0 Interface ၏ **MTU ကို 1360** သို့ လျှော့ချခြင်း။
- `iptables` တွင် **TCP MSS Clamping (`--clamp-mss-to-pmtu`)** ထည့်သွင်းပေးခြင်း။
- `/etc/docker/daemon.json` တွင် Google/Cloudflare DNS (`1.1.1.1`, `8.8.8.8`) နှင့် `"mtu": 1360` ကို အမြဲတမ်း သတ်မှတ်ပေးခြင်း။

---

### ပြဿနာ (၂) - Port Collision (ရှိပြီးသား VPN များနှင့် Port တိုက်နိုင်သည့် အန္တရာယ်)
Outline ၏ Default Installer သည် Port များကို သူ့သဘောနှင့်သူ ရွေးချယ်တတ်ပြီး တစ်ခါတစ်ရံ Port `443` ကို အသုံးပြုရန် ကြိုးစားတတ်သည်။

#### လက်ရှိ ဆာဗာ၏ Port ခွဲဝေမှု မြေပုံ:
| Port | Protocol | အသုံးပြုနေသော ဝန်ဆောင်မှု (Service) |
| :--- | :--- | :--- |
| **2213** | TCP | Custom SSH Access |
| **80** | TCP | Nginx HTTP (ACME Challenge / Redirect) |
| **443** | TCP | Nginx Reverse Proxy (AmneziaWG 2.0 Web UI) |
| **443** | UDP | **AmneziaWG 2.0 VPN Traffic** (Obfuscated WireGuard) |
| **2053** | TCP | **3X-UI Web Management Panel** |
| **8443** | TCP | **3X-UI: VLESS-Reality-XTLS** |
| **8443** | UDP | **3X-UI: Hysteria 2 (hy2)** |
| **10443** | TCP & UDP | **Outline VPN: Client Access Keys Port** *(NEW)* |
| **18443** | TCP | **Outline VPN: Shadowbox Management API** *(NEW)* |

> [!CAUTION]
> Outline ကို command arguments မပါဘဲ run လိုက်ပါက Port 443 သို့မဟုတ် 8443 ကို သွားရောက် ထပ်တူကျစေနိုင်ပြီး AmneziaWG သို့မဟုတ် 3X-UI ပျက်သွားနိုင်ပါသည်။ ထို့ကြောင့် `--api-port=18443 --keys-port=10443` ကို အတိအကျ သတ်မှတ် run ရပါမည်။

---

## ၂။ အဆင့်ဆင့် တပ်ဆင်နည်း လမ်းညွှန် (Full Setup Walkthrough)

### အဆင့် (၁) - Network MTU နှင့် TCP MSS Clamping ချိန်ညှိခြင်း

Terminal (SSH) တွင် အောက်ပါ command များကို run ပါ:

```bash
# 1. Default Interface MTU ကို 1360 သို့ ပြောင်းပါ
DEFAULT_IF=$(ip route show default | awk '{print $5}')
sudo ip link set dev $DEFAULT_IF mtu 1360

# 2. Docker Interface MTU ကိုပါ 1360 ပြောင်းပါ
sudo ip link set dev docker0 mtu 1360 2>/dev/null || true

# 3. TCP MSS Clamping စနစ် ထည့်သွင်းပါ
sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

---

### အဆင့် (၂) - Docker Daemon DNS နှင့် MTU အမြဲတမ်း သတ်မှတ်ခြင်း

Docker daemon restart ဖြစ်တိုင်း အလိုအလျောက် မှန်ကန်စေရန်:

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "dns": ["1.1.1.1", "8.8.8.8"],
  "mtu": 1360
}
EOF

sudo systemctl restart docker
```

---

### အဆင့် (၃) - Firewall (UFW) တွင် Outline Ports များ ဖွင့်ပေးခြင်း

Outline VPN ချိတ်ဆက်မှုများအတွက် Port များကို ဖွင့်ပါ:

```bash
sudo ufw allow 10443/tcp
sudo ufw allow 10443/udp
sudo ufw allow 18443/tcp
sudo ufw reload
```

---

### အဆင့် (၄) - Outline Server ကို Custom Ports ဖြင့် Run ခြင်း

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/OutlineFoundation/outline-apps/master/server_manager/install_scripts/install_server.sh)" -- --api-port=18443 --keys-port=10443
```

တပ်ဆင်မှု ပြီးစီးပါက အောက်ပါကဲ့သို့ Management API JSON စာကြောင်း ထွက်လာပါမည်:
```json
{"apiUrl":"https://<YOUR_SERVER_IP>:18443/XXXXXX","certSha256":"XXXXXXXXXXXXXX"}
```

---

### အဆင့် (၅) - ဆာဗာ Reboot ဖြစ်သွားသော်လည်း MTU မပြုတ်စေရန် ပြုလုပ်နည်း (Persistence)

ဆာဗာ Restart/Reboot ဖြစ်သွားပါက Linux kernel MTU မူလအတိုင်း ပြန်မဖြစ်စေရန် systemd service တစ်ခု ဖန်တီးထားပါမည်:

```bash
sudo tee /etc/systemd/system/set-mtu.service << 'EOF'
[Unit]
Description=Set Network MTU and TCP MSS Clamping on Boot
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "DEFAULT_IF=$(ip route show default | awk '{print $5}'); ip link set dev $DEFAULT_IF mtu 1360; iptables -t mangle -C POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable set-mtu.service
sudo systemctl start set-mtu.service
```

---

## ၃။ Outline Manager နှင့် အသုံးပြုပုံ

1. ကွန်ပျူတာ (PC/Mac) သို့မဟုတ် ဖုန်းတွင် **Outline Manager** App ကို ဖွင့်ပါ။
2. **"Set up Outline anywhere"** (Advanced) ကို နှိပ်ပါ။
3. အဆင့် (၄) တွင် ရရှိခဲ့သော `{"apiUrl": ...}` JSON စာကြောင်းတစ်ခုလုံးကို ကူးယူထည့်သွင်းပြီး **"Done"** နှိပ်ပါ။
4. Outline Manager ထဲတွင် **"Add new key"** နှိပ်၍ Client Key (ss:// link) ထုတ်ယူကာ Outline Client App များထဲသို့ ထည့်သွင်းအသုံးပြုနိုင်ပါပြီ။

---

## ၄။ ဝန်ဆောင်မှုများ စစ်ဆေးခြင်း အမိန့်များ (Cheat Sheet)

```bash
# Outline Docker Containers အခြေအနေ စစ်ဆေးရန်
sudo docker ps --filter "name=shadowbox" --filter "name=watchtower"

# Outline Logs စစ်ဆေးရန်
sudo docker logs -f shadowbox

# UFW Status စစ်ဆေးရန်
sudo ufw status verbose
```
