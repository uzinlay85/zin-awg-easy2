# AmneziaWG 2.0 Web UI (zin-awg-easy2)

ဒီပရောဂျက်ဟာ လူကြိုက်များတဲ့ `wg-easy` ကို အခြေခံပြီး **AmneziaWG 2.0** protocol ကို အပြည့်အဝ support ပေးနိုင်အောင် ပြုလုပ်ထားတဲ့ Web-based management interface ဖြစ်ပါတယ်။ 

မူလဗားရှင်းထက် ပိုမိုကောင်းမွန်ပြီး လုံခြုံတဲ့ traffic obfuscation parameters များဖြစ်တဲ့ **CPS (Custom Protocol Signature)** parameters (`I1`, `I2`, `I3`, `I4`, `I5`) များကိုပါ Web Panel ကနေ client configurations တွေဆီ အလိုအလျောက် ထည့်သွင်းထုတ်ပေးနိုင်အောင် မွမ်းမံပြင်ဆင်ထားပါတယ်။

---

## 📌 Features (ထူးခြားချက်များ)
- **AmneziaWG 2.0 Support:** DPI bypass လုပ်ရန် အဆင့်မြင့် UDP mimicry (QUIC, DNS စသည်) ပြုလုပ်နိုင်သည့် `I1` - `I5` parameter များ အလိုအလျောက်ထုတ်ပေးခြင်း။
- **Web UI Management:** VPN clients များကို အလွယ်တကူ ဖန်တီးခြင်း၊ ဖျက်ခြင်း၊ ပိတ်ခြင်း/ဖွင့်ခြင်း ပြုလုပ်နိုင်ခြင်း။
- **QR Code & Config Download:** Client များအတွက် ဆက်သွယ်ရန် configuration ဖိုင်နှင့် QR ကုဒ်များ တိုက်ရိုက်ထုတ်ပေးခြင်း။
- **Traffic Stats:** တစ်ဦးချင်းစီ၏ အင်တာနက်အသုံးပြုမှု နှုန်းထားများကို စောင့်ကြည့်နိုင်ခြင်း။
- **Docker Auto-Build:** GitHub သို့ push တင်လိုက်ရုံဖြင့် Docker image ကို GitHub Container Registry (GHCR) သို့ အလိုအလျောက် build ပြီး တင်ပေးခြင်း။

---

## 🚀 VPS ပေါ်တွင် အစအဆုံး တပ်ဆင်နည်း လမ်းညွှန် (Full Setup Guide)

သင့်ပိုင် Domain Name (ဥပမာ- `vpn.yourdomain.com`) ကို အသုံးပြုပြီး Ubuntu/Debian server ပေါ်တွင် Error ကင်းကင်းဖြင့် အစအဆုံး တပ်ဆင်နည်း ဖြစ်သည်။

> [!IMPORTANT]
> **မစတင်မီ:** Cloudflare သို့မဟုတ် သင့် Domain provider panel တွင် Domain ကို သင့် VPS IP သို့ ညွှန်ပြထားပြီး **Proxy Status ကို DNS Only (မီးခိုးရောင် တိမ်တိုက်)** အဖြစ် ပြောင်းထားပါ။

### အဆင့် (၁) - NAT Module ဖွင့်ခြင်း နှင့် Docker သွင်းခြင်း
Docker ၏ legacy iptables စနစ် အလုပ်လုပ်နိုင်ရန် NAT Module ကို ကြိုတင်ဖွင့်ပြီး Docker သွင်းပါ -
```bash
# ၁။ NAT module ဖွင့်ရန်
sudo modprobe iptable_nat

# ၂။ Reboot တက်တိုင်း အလိုအလျောက် ပွင့်နေစေရန် save လုပ်ရန်
echo "iptable_nat" | sudo tee /etc/modules-load.d/iptable_nat.conf

# ၃။ Docker သွင်းရန်
curl -fsSL https://get.docker.com | sudo bash

# ၄။ Docker Service ကို အမြဲတမ်း run ထားရန် ဖွင့်ခြင်း
sudo systemctl enable --now docker
```

### အဆင့် (၂) - Firewall (UFW) ပေါက်များ ဖွင့်ခြင်း
VPN နှင့် Web UI အတွက် လိုအပ်သော ports များကို firewall တွင် ဖွင့်ပါ -
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 58210/udp
sudo ufw reload
```

### အဆင့် (၃) - Web UI အတွက် Password ကို Hash ပြောင်းခြင်း
Web UI သို့ ဝင်ရောက်ရန် မိမိအသုံးပြုလိုသော Password ကို လုံခြုံစိတ်ချရသော Hash Code ပြောင်းရပါမည်။ `YOUR_PASSWORD` နေရာတွင် သင့်စကားဝှက်ကို ထည့်သွင်းပါ -
```bash
sudo docker run -it ghcr.io/uzinlay85/zin-awg-easy2 wgpw 'YOUR_PASSWORD'
```
*ရလဒ်အနေဖြင့် ထွက်လာသော `$2b$12$...` ဟု စတင်သည့် စာသားရှည်ကြီး (Hash Code) ကို ကူးယူ (Copy) သိမ်းထားပါ။*

### အဆင့် (၄) - Container ကို စတင် Run ခြင်း
အောက်ပါ run command ကို ကူးယူပြီး `vpn.yourdomain.com` နေရာတွင် သင့် domain နာမည်နှင့် `PASSWORD_HASH` နေရာတွင် အဆင့် (၃) မှ ရလာသော Hash Code ကို အစားထိုးထည့်သွင်း၍ run ပါ -

```bash
sudo docker run -d \
  --name=amnezia-wg-easy \
  -e WG_HOST=vpn.yourdomain.com \
  -e PASSWORD_HASH='$2b$12$...သင်၏_HASH_CODE' \
  -e PORT=51831 \
  -e WG_PORT=58210 \
  -e WG_MTU=1200 \
  -e WG_PERSISTENT_KEEPALIVE=25 \
  # Legacy (AWG 1.0)
  -e JC=3 \
  -e JMIN=50 \
  -e JMAX=195 \
  -e S1=70 \
  -e S2=85 \
  -e H1=1377139017 \
  -e H2=820269891 \
  -e H3=989884595 \
  -e H4=1838347724 \
  # AWG 2.0 (CPS/Mimicry parameters)
  -e I1='<b 0xc0><r 32><c><t>' \
  -e I2='<b 0x01><r 16>' \
  -e UI_ENABLE_SORT_CLIENTS=true \
  -e UI_TRAFFIC_STATS=true \
  -e WG_ENABLE_EXPIRES_TIME=true \
  -e WG_ENABLE_ONE_TIME_LINKS=true \
  -v ~/.amnezia-wg-easy:/etc/wireguard \
  -p 58210:58210/udp \
  -p 127.0.0.1:51831:51831/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --device=/dev/net/tun:/dev/net/tun \
  --restart unless-stopped \
  ghcr.io/uzinlay85/zin-awg-easy2:latest
```

### အဆင့် (၅) - Web UI အတွက် Nginx Reverse Proxy နှင့် SSL (HTTPS) တပ်ဆင်ခြင်း
Web UI ကို အပြင်မှ လုံခြုံစွာ Domain ဖြင့် လှမ်းခေါ်နိုင်ရန် Nginx ကို SSL Certificate ဖြင့် configure လုပ်ပါမည်။

၁။ Nginx နှင့် Certbot သွင်းရန် -
```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y
```

၂။ Nginx Config ဖိုင်အသစ် ဖန်တီးရန် (သင့် Domain နာမည် အစားထိုးပါ) -
```bash
sudo bash -c 'cat << "EOF" > /etc/nginx/sites-available/amnezia
server {
    listen 80;
    server_name vpn.yourdomain.com;
    
    location / {
        proxy_pass http://127.0.0.1:51831;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket Support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF'
```

၃။ Config အား Activate လုပ်ပြီး Nginx restart ချရန် -
```bash
sudo ln -s /etc/nginx/sites-available/amnezia /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

၄။ အခမဲ့ SSL လက်မှတ် (Let's Encrypt) တောင်းယူရန် -
```bash
sudo certbot --nginx -d vpn.yourdomain.com
```

---

## 🗑️ စနစ်ကို ပြန်လည်ဖျက်သိမ်းနည်း (Uninstall Guide)
ဆာဗာပေါ်မှ ဤစနစ်ကို စနစ်တကျ သန့်ရှင်းစွာ ဖြုတ်လိုပါက အောက်ပါအတိုင်း အဆင့်ဆင့် လုပ်ဆောင်ပါ -

```bash
# ၁။ Docker Container နှင့် Image များ ဖျက်ခြင်း
sudo docker stop amnezia-wg-easy
sudo docker rm amnezia-wg-easy
sudo docker rmi ghcr.io/uzinlay85/zin-awg-easy2:latest
sudo rm -rf ~/.amnezia-wg-easy

# ၂။ SSL နှင့် Nginx configurations များ ဖျက်ခြင်း
sudo certbot delete --cert-name vpn.yourdomain.com
sudo rm /etc/nginx/sites-enabled/amnezia
sudo rm /etc/nginx/sites-available/amnezia
sudo systemctl restart nginx

# ၃။ Firewall ports များ ပြန်ပိတ်ခြင်း
sudo ufw delete allow 58210/udp
sudo ufw delete allow 80/tcp
sudo ufw delete allow 443/tcp
sudo ufw reload

# ၄။ NAT Configuration ဖျက်ခြင်း
sudo rm /etc/modules-load.d/iptable_nat.conf
```
