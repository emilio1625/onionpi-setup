#!/bin/bash

# Update and install Tor
sudo apt-get update
sudo apt-get install -y tor

# Configure Tor

cp torrc /etc/tor/torrc

# Create a log file
sudo touch /var/log/tor/notices.log
sudo chown debian-tor /var/log/tor/notices.log
sudo chmod 644 /var/log/tor/notices.log

# Start Tor and enable it on boot
sudo service tor start
sudo update-rc.d tor enable
