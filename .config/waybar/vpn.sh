#!/bin/bash
ip add show | grep -qF tun0 \
&& echo ' VPN up' \
|| echo ' VPN down'
