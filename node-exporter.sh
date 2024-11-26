#!/bin/bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
#rm -r node_exporter-1.5.0.linux-amd64*
sudo useradd -rs /bin/false node_exporter
 
cat > /etc/systemd/system/node_exporter.service << "EOF"
[Unit]
Description=Node Exporter
After=network.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:1784
 
[Install]
WantedBy=multi-user.target
EOF
 
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
chcon -t bin_t /usr/local/bin/node_exporter
sudo systemctl restart node_exporter.service
sudo systemctl status node_exporter.service