# AmneziaWG 2.0 Web UI (zin-awg-easy2)

ဒီပရောဂျက်ဟာ လူကြိုက်များတဲ့ `wg-easy` ကို အခြေခံပြီး **AmneziaWG 2.0** protocol ကို အပြည့်အဝ support ပေးနိုင်အောင် ပြုလုပ်ထားတဲ့ Web-based management interface ဖြစ်ပါတယ်။ 

မူလဗားရှင်းထက် ပိုမိုကောင်းမွန်ပြီး လုံခြုံတဲ့ traffic obfuscation parameters များဖြစ်တဲ့ **CPS (Custom Protocol Signature)** parameters (`I1`, `I2`) များကိုပါ Web Panel ကနေ client configurations တွေဆီ အလိုအလျောက် ထည့်သွင်းထုတ်ပေးနိုင်အောင် မွမ်းမံပြင်ဆင်ထားပါတယ်။

ဆာဗာပေါ်တွင် AmneziaWG 2.0 engine များကို source code မှတစ်ဆင့် compile လုပ်၍ run စေရန်နှင့် အခြား vpn (ဥပမာ- Outline) များနှင့် port တိုက်ဆိုင်မှုမရှိစေရန် **Port 8443** ကို အသုံးပြု၍ configure လုပ်နည်းကို အောက်ပါအတိုင်း ညွှန်ကြားထားပါသည်။

---

## 📌 Features (ထူးခြားချက်များ)
- **AmneziaWG 2.0 Support:** DPI bypass လုပ်ရန် အဆင့်မြင့် UDP mimicry (QUIC, DNS စသည်) ပြုလုပ်နိုင်သည့် `I1` - `I2` parameter များ အလိုအလျောက်ထုတ်ပေးခြင်း။
- **Docker Source Compilation:** Base image ၏ dependency ဟောင်းများကြောင့် crash ဖြစ်ခြင်းမှ ကာကွယ်ရန် `amneziawg-go` နှင့် `amneziawg-tools` နောက်ဆုံးဗားရှင်းများကို Container အတွင်း source code မှ တိုက်ရိုက် compile လုပ်ထားခြင်း။
- **Web UI Management:** VPN clients များကို Port 8443 (HTTPS) ဖြင့် လုံခြုံစွာ ဖန်တီးခြင်း၊ ဖျက်ခြင်း၊ ပိတ်ခြင်း/ဖွင့်ခြင်း ပြုလုပ်နိုင်ခြင်း။
- **QR Code & Config Download:** Client များအတွက် ဆက်သွယ်ရန် configuration ဖိုင်နှင့် QR ကုဒ်များ တိုက်ရိုက်ထုတ်ပေးခြင်း။
- **Traffic Stats:** တစ်ဦးချင်းစီ၏ အင်တာနက်အသုံးပြုမှု နှုန်းထားများကို စောင့်ကြည့်နိုင်ခြင်း။

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
VPN နှင့် Web UI proxy အတွက် လိုအပ်သော ports များကို firewall တွင် ဖွင့်ပါ -
```bash
sudo ufw allow <YOUR_SSH_PORT>/tcp   # မိမိအသုံးပြုနေသော SSH Port ကို ဖွင့်ပေးရန် (ပုံမှန် ၂၂ သို့မဟုတ် သီးသန့် port)
sudo ufw allow 80/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 58210/udp
sudo ufw reload
```

### အဆင့် (၃) - Source Code မှ Docker Image ကို Build ပြုလုပ်ခြင်း
VPS ပေါ်တွင် AmneziaWG 2.0 core binaries များကို compile လုပ်ရန် code ကို clone ဖတ်ပြီး build ဆွဲပါ -
```bash
git clone https://github.com/uzinlay85/zin-awg-easy2.git
cd zin-awg-easy2

# Image build ဆွဲခြင်း (၃ မိနစ်ခန့် ကြာနိုင်ပါသည်)
sudo docker build -t amnezia-wg-easy:2.0 .
```

### အဆင့် (၄) - Web UI အတွက် Password ကို Hash ပြောင်းခြင်း
Web UI သို့ ဝင်ရောက်ရန် မိမိအသုံးပြုလိုသော Password ကို လုံခြုံစိတ်ချရသော Hash Code ပြောင်းရပါမည်။ `YOUR_PASSWORD` နေရာတွင် သင့်စကားဝှက်ကို ထည့်သွင်းပါ -
```bash
sudo docker run -it amnezia-wg-easy:2.0 wgpw 'YOUR_PASSWORD'
```
*ရလဒ်အနေဖြင့် ထွက်လာသော `$2b$12$...` သို့မဟုတ် `$2a$12$...` ဟု စတင်သည့် Hash Code ကို ကူးယူသိမ်းဆည်းထားပါ။*

### အဆင့် (၅) - Container ကို စတင် Run ခြင်း
အောက်ပါ run command ကို ကူးယူပြီး `WG_HOST` နေရာတွင် သင့် domain နာမည်နှင့် `PASSWORD_HASH` နေရာတွင် အဆင့် (၄) မှ ရလာသော Hash Code ကို အစားထိုးထည့်သွင်း၍ run ပါ -

> [!NOTE]
> `I1` settings ထဲတွင် `<c>` (Packet Counter) tag အား ထည့်သွင်းပါက userspace go daemon မှ support မလုပ်သဖြင့် crash ဖြစ်စေနိုင်သောကြောင့် ဖယ်ရှားပြီး **`'<b 0xc0><r 32><t>'`** ကိုသာ အသုံးပြုထားပါသည်။

```bash
# ပြောင်းလဲမှုများ ကောင်းစွာအလုပ်လုပ်စေရန် ယခင် config အဟောင်းများရှိပါက ဖျက်ပစ်ပါ
sudo rm -f ~/.amnezia-wg-easy/wg0.json ~/.amnezia-wg-easy/wg0.conf

sudo docker run -d \
  --name=amnezia-wg-easy \
  -e WG_HOST=vpn.yourdomain.com \
  -e PASSWORD_HASH='$2a$12$...သင်၏_HASH_CODE' \
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
  # AWG 2.0 (CPS/Mimicry parameters - တရားဝင် DNS/QUIC mimicry ပုံစံ)
  -e I1='<b 0xc0><r 32><t>' \
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
  amnezia-wg-easy:2.0
```

### အဆင့် (၆) - Web UI အတွက် Nginx Reverse Proxy (Port 8443) နှင့် SSL (HTTPS) တပ်ဆင်ခြင်း
အခြားသော vpn (ဥပမာ- Outline) များသည် port 443 ကို အသုံးပြုထားတတ်သဖြင့် Web UI panel ကို Port 8443 ဖြင့် သီးသန့် reverse proxy လုပ်နည်း ဖြစ်သည်။

၁။ Nginx နှင့် Certbot သွင်းရန် -
```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y
```

၂။ SSL Certificate တောင်းယူရန် (Nginx configurations မပြင်ဆင်မီ သီးသန့်တောင်းခြင်း) -
```bash
sudo certbot certonly --nginx -d vpn.yourdomain.com
```

၃။ Nginx Config ဖိုင်အသစ် ဖန်တီးရန် (သင့် Domain นာမည် အစားထိုးပါ) -
```bash
sudo bash -c 'cat << "EOF" > /etc/nginx/sites-available/amnezia
server {
    listen 8443 ssl;
    listen [::]:8443 ssl;
    server_name vpn.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/vpn.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/vpn.yourdomain.com/privkey.pem;

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

server {
    listen 80;
    listen [::]:80;
    server_name vpn.yourdomain.com;
    return 301 https://$host:8443$request_uri;
}
EOF'
```

၄။ Config အား Activate လုပ်ပြီး Nginx reload ချရန် -
```bash
sudo ln -sf /etc/nginx/sites-available/amnezia /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

အဆင့်အားလုံး ပြီးမြောက်ပါက Browser မှ **`https://vpn.yourdomain.com:8443`** ဟု ရိုက်ထည့်ပြီး Web UI Panel သို့ လုံခြုံစွာ ဝင်ရောက်နိုင်ပြီ ဖြစ်သည်။

---

## 🗑️ စနစ်ကို ပြန်လည်ဖျက်သိမ်းနည်း (Uninstall Guide)
ဆာဗာပေါ်မှ ဤစနစ်ကို စနစ်တကျ သန့်ရှင်းစွာ ဖြုတ်လိုပါက အောက်ပါအတိုင်း အဆင့်ဆင့် လုပ်ဆောင်ပါ -

```bash
# ၁။ Docker Container နှင့် Image များ ဖျက်ခြင်း
sudo docker stop amnezia-wg-easy
sudo docker rm amnezia-wg-easy
sudo docker rmi amnezia-wg-easy:2.0
sudo rm -rf ~/.amnezia-wg-easy

# ၂။ SSL နှင့် Nginx configurations များ ဖျက်ခြင်း
sudo certbot delete --cert-name vpn.yourdomain.com
sudo rm /etc/nginx/sites-enabled/amnezia
sudo rm /etc/nginx/sites-available/amnezia
sudo systemctl reload nginx

# ၃။ Firewall ports များ ပြန်ပိတ်ခြင်း
sudo ufw delete allow 58210/udp
sudo ufw delete allow 80/tcp
sudo ufw delete allow 8443/tcp
sudo ufw reload

# ၄။ NAT Configuration ဖျက်ခြင်း
sudo rm /etc/modules-load.d/iptable_nat.conf
```

