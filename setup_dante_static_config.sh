#!/bin/bash

# Pastikan Anda menjalankan script ini sebagai root
echo "Installing Dante Server..."

# Install Dante Server
apt update
apt install -y dante-server

# Daftar IP tambahan beserta konfigurasi port, username, dan password
PROXY_CONFIG=(
    "46.23.108.12:1080:Masconon:MascononCloud."
    "46.23.108.16:1080:Masconon:MascononCloud."
    "46.23.108.21:1080:Masconon:MascononCloud."
    "46.23.108.23:1080:Masconon:MascononCloud."
    "46.23.108.24:1080:Masconon:MascononCloud."
    "46.23.108.25:1080:Masconon:MascononCloud."
    "46.23.108.26:1080:Masconon:MascononCloud."
    "46.23.108.29:1080:Masconon:MascononCloud."
    "46.23.108.49:1080:Masconon:MascononCloud."
    "46.23.108.54:1080:Masconon:MascononCloud."
    "46.23.108.55:1080:Masconon:MascononCloud."
    "46.23.108.56:1080:Masconon:MascononCloud."
    "46.23.108.57:1080:Masconon:MascononCloud."
    "46.23.108.58:1080:Masconon:MascononCloud."
    "46.23.108.61:1080:Masconon:MascononCloud."
    "46.23.108.62:1080:Masconon:MascononCloud."
    "46.23.108.63:1080:Masconon:MascononCloud."
    "46.23.108.68:1080:Masconon:MascononCloud."
    "46.23.108.96:1080:Masconon:MascononCloud."
    "46.23.108.105:1080:Masconon:MascononCloud."
)

# Buat konfigurasi dante-server
echo "Configuring Dante Server..."
cat <<EOL > /etc/danted.conf
logoutput: syslog

# Global SOCKS rules
method: username
user.notprivileged: nobody

EOL

# Tambahkan konfigurasi untuk setiap IP
for CONFIG in "${PROXY_CONFIG[@]}"; do
    # Pisahkan konfigurasi menjadi IP, Port, Username, dan Password
    IFS=':' read -r IP PORT USERNAME PASSWORD <<< "$CONFIG"

    # Tambahkan konfigurasi ke file danted.conf
    cat <<EOL >> /etc/danted.conf
# Configuration for IP $IP
internal: $IP port = $PORT
external: $IP

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
EOL

    # Tambahkan user ke sistem
    useradd -m -s /usr/sbin/nologin $USERNAME || echo "User $USERNAME already exists, skipping..."
    echo "$USERNAME:$PASSWORD" | chpasswd

    echo "Configured IP: $IP with Port: $PORT, Username: $USERNAME"
done

# Restart Dante Server
echo "Restarting Dante Server..."
systemctl restart danted

# Tampilkan informasi konfigurasi akhir
echo "SOCKS5 Proxy setup is complete! Configuration details:"
for CONFIG in "${PROXY_CONFIG[@]}"; do
    IFS=':' read -r IP PORT USERNAME PASSWORD <<< "$CONFIG"
    echo "IP: $IP, Port: $PORT, Username: $USERNAME, Password: [hidden]"
done
