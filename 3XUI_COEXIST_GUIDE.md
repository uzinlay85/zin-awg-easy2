# AmneziaWG 2.0 ဆာဗာပေါ်တွင် 3X-UI (VLESS-Reality & Hysteria 2) တွဲဖက်တပ်ဆင်နည်း လမ်းညွှန်

ဤလမ်းညွှန်သည် လက်ရှိလည်ပတ်နေသော **AmneziaWG 2.0 Web UI** စနစ်ကို လုံးဝမထိခိုက်စေဘဲ၊ ဆာဗာတစ်ခုတည်းပေါ်တွင် **3X-UI** (Xray Panel) ကို အတူတွဲဖက်၍ **VLESS-Reality (Vision)** နှင့် **Hysteria 2 (Hy2)** Inbounds များကို Port မငြိစွန်းစေဘဲ အောင်မြင်စွာ တပ်ဆင်အသုံးပြုနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 📌 ကွန်ရက်ဆိပ်ကမ်း (Port) ခွဲဝေမှု ဇယား

ဆာဗာတစ်ခုတည်းတွင် VPN စနစ် (၃) မျိုးလုံး တပြိုင်နက် ငြိမ်းချမ်းစွာ အလုပ်လုပ်နိုင်စေရန် Port များကို အောက်ပါအတိုင်း စနစ်တကျ ခွဲဝေထားပါသည် -

| ဝန်ဆောင်မှုအမည် (Service) | Protocol | Port နံပါတ် | ရှင်းလင်းချက် |
| :--- | :--- | :--- | :--- |
| **SSH** | TCP | `22` သို့မဟုတ် `2213` | ဆာဗာ Terminal ချိတ်ဆက်ရန် |
| **AmneziaWG Web UI** | TCP | `443` | Nginx HTTPS Reverse Proxy ဖြင့် Panel ဝင်ရန် |
| **AmneziaWG VPN Tunnel** | UDP | `443` | DPI ကျော်ဖြတ်ရန် QUIC အသွင်ဆောင် UDP Port |
| **3X-UI Admin Dashboard** | TCP | `2053` | 3X-UI Web Panel သို့ ဝင်ရောက်စီမံရန် |
| **VLESS-Reality (Vision)** | TCP | `8443` | Microsoft/Apple TLS အတုခိုးထားသော TCP Inbound |
| **Hysteria 2 (Hy2)** | UDP | `8443` | Packet loss များသော ဖုန်းလိုင်းများအတွက် အမြန်ဆုံး UDP Inbound |

> [!TIP]
> **အဘယ်ကြောင့် Port မငြိစွန်းသနည်း?**
> * TCP နှင့် UDP သည် Network အလွှာတွင် သီးခြားစီဖြစ်သဖြင့် `TCP 443` (Amnezia UI) နှင့် `UDP 443` (Amnezia VPN) သည် အတူတွဲသုံးနိုင်ပါသည်။
> * အလားတူပင် `TCP 8443` (VLESS-Reality) နှင့် `UDP 8443` (Hysteria 2) တို့သည်လည်း တစ်ခုနှင့်တစ်ခု လုံးဝ မငြိစွန်းဘဲ တပြိုင်နက် အလုပ်လုပ်နိုင်ပါသည်။

---

## 🚀 အဆင့် (၁) - Firewall ပေါက်များ ဖွင့်ပေးခြင်း

ဆာဗာ Terminal ထဲတွင် 3X-UI နှင့် Inbound များအတွက် လိုအပ်သော Port များကို ကြိုတင်ဖွင့်ပေးပါ -

```bash
# 3X-UI Panel (2053/TCP)၊ VLESS (8443/TCP) နှင့် Hysteria 2 (8443/UDP) တို့ကို ဖွင့်ခြင်း
sudo ufw allow 2053/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 8443/udp
sudo ufw reload
```

> [!IMPORTANT]
> **Cloud Provider Dashboard သတိပြုရန်:**
> အကယ်၍ သင့် VPS သည် Cloud Dashboard (ဥပမာ- QQG.NET, Oracle, AWS, Alibaba) ရှိ Security Group / Ingress Firewall ကို အသုံးပြုထားပါက Dashboard ထဲတွင်လည်း `TCP 2053`၊ `TCP 8443` နှင့် `UDP 8443` (သို့မဟုတ် UDP/TCP `1-65535`) ကို ALLOW ပေးထားရန် လိုအပ်ပါသည်။

---

## 🚀 အဆင့် (၂) - 3X-UI တရားဝင် Script ကို သွင်းယူခြင်း

ဆာဗာ Terminal ထဲတွင် အောက်ပါ command ကို Run ပါ -

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

### တပ်ဆင်စဉ် မေးခွန်းများ ဖြေဆိုနည်း -
1. **Username / Password:** မိမိအသုံးပြုလိုသော အကောင့်အမည်နှင့် လျှို့ဝှက်နံပါတ်ကို သတ်မှတ်ပါ (သို့မဟုတ် Enter ခေါက်၍ auto ထုတ်ခိုင်းနိုင်သည်)။
2. **Port နံပါတ် မေးသည့်အခါ:** **`2053`** ဟု ရိုက်ထည့်ပေးပါ။
3. **SSL Certificate Setup ရွေးချယ်မှု မေးသည့်အခါ:**
   * **`4` (Skip SSL)** ကို ရွေးချယ်ပေးပါ!
   * *(အကြောင်းရင်းမှာ Port 80 ကို Nginx က အသုံးပြုထားပြီးဖြစ်၍ Let's Encrypt standalone တောင်းပါက error တက်မည်ဖြစ်သောကြောင့် ဖြစ်သည်။ 3X-UI panel သည် http ဖြင့် အလွန်လွယ်ကူစွာ ဝင်နိုင်ပြီး VLESS-Reality အတွက်လည်း panel SSL မလိုအပ်ပါ)*။

တပ်ဆင်ပြီးပါက ပေါ်လာသော Username, Password နှင့် Access URL ကို သေချာစွာ ကူးယူသိမ်းဆည်းထားပါ။

---

## 🚀 အဆင့် (၃) - 3X-UI Panel သို့ ဝင်ရောက်ခြင်း

Browser တွင် အောက်ပါ လိပ်စာအတိုင်း ရိုက်ထည့်ပြီး Login ဝင်ပါ -

```text
http://<သင့်ဆာဗာ_IP>:2053/<WebBasePath>
(ဥပမာ - http://50.114.172.236:2053/bwuAAHsdQV2Tyo8NYp)
```

---

## 🚀 အဆင့် (၄) - VLESS-Reality (Vision) Inbound ဖန်တီးနည်း

VLESS-Reality သည် မည်သည့် Domain/SSL Certificate မှ ဝယ်ယူစရာမလိုဘဲ Microsoft/Apple ၏ TLS Handshake ကို အတုခိုးအသုံးပြုထားသဖြင့် ပြည်တွင်း မိုဘိုင်းဖုန်းလိုင်းများ၏ DPI ကို အကောင်းဆုံး ကျော်ဖြတ်နိုင်ပါသည်။

1. 3X-UI ဘယ်ဘက် Menu မှ **`Inbounds`** ကို နှိပ်ပါ ➡️ အပြာရောင် **`Add Inbound` (+)** ကို နှိပ်ပါ။
2. အောက်ပါအတိုင်း တိကျစွာ ဖြည့်စွက်ပါ -
   * **Remark:** `VLESS-Reality`
   * **Protocol:** `vless`
   * **Port:** `8443`
   * **Client Settings:**
     * **ID (UUID):** ဘေးက Refresh ခလုတ်နှိပ်၍ Auto-generate လုပ်ပါ။
     * **Flow:** **`xtls-rprx-vision`** ကို မဖြစ်မနေ ရွေးပေးပါ!
   * **Transport (Stream Settings):**
     * **Network:** `tcp`
   * **Security Settings:**
     * **Security:** **`Reality`** ကို ရွေးပါ။
     * **uTLS:** `chrome`
     * **Dest:** `www.microsoft.com:443` (သို့မဟုတ် `gateway.icloud.com:443`)
     * **Server Names (SNI):** `www.microsoft.com` (သို့မဟုတ် `gateway.icloud.com`)
     * **Short IDs:** ဘေးက Refresh ခလုတ်လေး နှိပ်ပါ။
     * **Keys (Private Key / Public Key):** ဘေးက **`Get New Keys`** (Refresh မြှား) ခလုတ်ကို နှိပ်ပြီး Keys အသစ်ထုတ်ပါ။
3. အောက်ဆုံးရှိ **`Create`** ကို နှိပ်ပြီး သိမ်းဆည်းပါ။
4. Inbound ဘေးရှိ **QR Code / Copy Link** ကို ယူပြီး အသုံးပြုနိုင်ပါပြီ။

---

## 🚀 အဆင့် (၅) - Hysteria 2 (Hy2) Inbound ဖန်တီးနည်း

Hysteria 2 သည် Packet loss များပြီး လိုင်းကျပ်တည်းသော ဖုန်းလိုင်းများပေါ်တွင် အမြန်နှုန်း အမြင့်ဆုံး ရရှိစေသည့် UDP-based QUIC protocol ဖြစ်ပါသည်။

1. 3X-UI ထဲရှိ **`Inbounds`** ➡️ **`Add Inbound` (+)** ကို နှိပ်ပါ။
2. အောက်ပါအတိုင်း ဖြည့်စွက်ပါ -
   * **Remark:** `Hysteria2`
   * **Protocol:** `hysteria2`
   * **Port:** `8443` (UDP)
   * **Client Settings:**
     * **Password:** Refresh ခလုတ်လေး နှိပ်ပြီး password ထုတ်ပါ (သို့မဟုတ် မိမိစိတ်ကြိုက်ထည့်ပါ)။
   * **Security Settings (TLS ပိုင်း):**
     * **SNI:** သင့်ဒိုမိန်းအမည် (ဥပမာ- `a-qqg.truehand.top`)
     * **File Path** ကို ရွေးပါ:
       * **Public Key (Certificate):** 
         ```text
         /etc/letsencrypt/live/<YOUR_DOMAIN>/fullchain.pem
         (ဥပမာ - /etc/letsencrypt/live/a-qqg.truehand.top/fullchain.pem)
         ```
       * **Private Key:** 
         ```text
         /etc/letsencrypt/live/<YOUR_DOMAIN>/privkey.pem
         (ဥပမာ - /etc/letsencrypt/live/a-qqg.truehand.top/privkey.pem)
         ```
3. အောက်ဆုံးရှိ **`Create`** ကို နှိပ်ပြီး သိမ်းဆည်းပါ။
4. Inbound ဘေးရှိ **QR Code / Copy Link** ကို ယူ၍ အသုံးပြုနိုင်ပါပြီ။

---

## 📱 ဖုန်းနှင့် ကွန်ပျူတာများတွင် အသုံးပြုနိုင်သော Application များ

| စက်အမျိုးအစား (Device) | အကြံပြု Application များ |
| :--- | :--- |
| **Android** | **NekoBox for Android** (VLESS ရော Hy2 ပါ အကောင်းဆုံး), **v2rayNG** |
| **iOS (iPhone/iPad)** | **Sing-box**, **Streisand**, **Shadowrocket**, **FoXray**, **Karing** |
| **Windows PC** | **v2rayN**, **NekoRay / Matsuri**, **Sing-box** |

---

## ✅ စစ်ဆေးအတည်ပြုခြင်း

ဆာဗာပေါ်တွင် ဝန်ဆောင်မှုများ အားလုံး အပြိုင်လည်ပတ်နေမှုကို အောက်ပါ command ဖြင့် စစ်ဆေးနိုင်ပါသည် -

```bash
# TCP နားထောင်နေသော Ports များ စစ်ရန် (SSH: 22/2213, Amnezia UI: 443, 3X-UI: 2053, VLESS: 8443)
sudo ss -tlpn

# UDP နားထောင်နေသော Ports များ စစ်ရန် (Amnezia VPN: 443, Hysteria 2: 8443)
sudo ss -ulpn
```
