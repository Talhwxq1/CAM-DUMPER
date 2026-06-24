<?php
function getRealIP() {
    // Cloudflare
    if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
        return $_SERVER['HTTP_CF_CONNECTING_IP'];
    }
    // Nginx proxy
    if (isset($_SERVER['HTTP_X_REAL_IP'])) {
        return $_SERVER['HTTP_X_REAL_IP'];
    }
    // X-Forwarded-For
    if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        return trim($ips[0]);
    }
    // REMOTE_ADDR
    if (isset($_SERVER['REMOTE_ADDR'])) {
        return $_SERVER['REMOTE_ADDR'];
    }
    return '0.0.0.0';
}

header('Content-Type: text/plain');
echo getRealIP();
?>
