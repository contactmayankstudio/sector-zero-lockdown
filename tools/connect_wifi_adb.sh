#!/usr/bin/env bash
# Quick script to connect Android phone over Wi-Fi
set -e

echo "=== ADB Wi-Fi Connect Tool ==="

# Check if already connected wirelessly
if adb devices | grep -q ":5555[[:space:]]\+device"; then
    echo "✓ Device is already connected over Wi-Fi!"
    adb devices -l
    exit 0
fi

# If connected via USB, enable tcpip 5555 and fetch IP
USB_DEV=$(adb devices | grep -v "List" | grep "device$" | grep -v ":5555" | awk '{print $1}' | head -n 1 || true)

if [ -n "$USB_DEV" ]; then
    echo "Found USB device: $USB_DEV. Enabling TCP/IP mode on port 5555..."
    adb -s "$USB_DEV" tcpip 5555
    sleep 1

    # Fetch IPv4
    IP4=$(adb -s "$USB_DEV" shell "ip -4 addr show wlan0 | grep inet" | awk '{print $2}' | cut -d/ -f1 | head -n 1 || true)
    
    # Fetch IPv6
    IP6=$(adb -s "$USB_DEV" shell "ip -6 route show dev wlan0" | grep -v fe80 | grep "proto" | awk '{print $1}' | head -n 1 || true)
    if [ -z "$IP6" ]; then
        IP6=$(adb -s "$USB_DEV" shell "ip -6 addr show wlan0 | grep global" | awk '{print $2}' | cut -d/ -f1 | head -n 1 || true)
    fi

    # Try connecting
    CONNECTED=false
    if [ -n "$IP4" ]; then
        echo "Attempting IPv4 connect to $IP4:5555..."
        if timeout 3 adb connect "$IP4:5555"; then
            CONNECTED=true
        fi
    fi

    if [ "$CONNECTED" = false ] && [ -n "$IP6" ]; then
        echo "Attempting IPv6 connect to [$IP6]:5555..."
        adb connect "[$IP6]:5555"
    fi
else
    # Try known IPv6 address
    LAST_IP6="2402:3a80:1ce1:deb6:54c4:8972:d13d:e96e"
    echo "No USB device found. Attempting direct connect to last known phone address: [$LAST_IP6]:5555..."
    adb connect "[$LAST_IP6]:5555" || true
fi

echo "--- Current ADB Devices ---"
adb devices -l
