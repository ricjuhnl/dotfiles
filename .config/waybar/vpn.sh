#!/bin/bash
ip add show | grep -qF tun0 \
&& echo ' Connected' \
|| echo ' Disconnected'
