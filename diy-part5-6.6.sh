#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part5-6.6.sh
# Description: OpenWrt DIY script part 5 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# libxcrypt 4.4.36 enables -Werror by default, which turns warnings from the
# OpenWrt fortify headers into build errors. Keep fortify enabled and disable
# only libxcrypt's warnings-as-errors behavior.
LIBXCRYPT_MAKEFILE="feeds/packages/libs/libxcrypt/Makefile"
if [ ! -f "$LIBXCRYPT_MAKEFILE" ]; then
    echo "libxcrypt Makefile not found: $LIBXCRYPT_MAKEFILE" >&2
    exit 1
fi

if ! grep -qxF 'CONFIGURE_ARGS += --disable-werror' "$LIBXCRYPT_MAKEFILE"; then
    sed -i.bak '/BuildPackage,libxcrypt/i\
CONFIGURE_ARGS += --disable-werror
' "$LIBXCRYPT_MAKEFILE"
    rm -f "${LIBXCRYPT_MAKEFILE}.bak"
fi

if ! grep -qxF 'CONFIGURE_ARGS += --disable-werror' "$LIBXCRYPT_MAKEFILE"; then
    echo "Failed to disable libxcrypt warnings as errors" >&2
    exit 1
fi

# 添加组播防火墙规则
# cat >> package/network/config/firewall/files/firewall.config <<EOF
# config rule
#         option name 'Allow-UDP-igmpproxy'
#         option src 'wan'
#         option dest 'lan'
#         option dest_ip '224.0.0.0/4'
#         option proto 'udp'
#         option target 'ACCEPT'
#         option family 'ipv4'

# config rule
#         option name 'Allow-UDP-udpxy'
#         option src 'wan'
#         option dest_ip '224.0.0.0/4'
#         option proto 'udp'
#         option target 'ACCEPT'
# EOF
