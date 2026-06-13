#!/bin/sh

echo "=========================================="
echo "软件源更新脚本"
echo "=========================================="

# 删除旧文件
echo ""
echo "1、删除旧版文件"
rm -f Packages Packages.bz2 Packages.gz Packages.xz Release
echo "  已删除旧文件"

# 生成 Packages
echo ""
echo "2、生成 Packages"

# 清空并重新写入
> Packages

# 插件1: dev.sys.roothide (roothide) - 添加 Dev 和 Icon
echo "  添加: dev.sys.roothide (roothide)"
cat >> Packages << 'EOF'
Package: dev.sys.roothide
Version: 1.0
Architecture: all
Maintainer: DPP
Depends: firmware (>= 14.0), mobilesubstrate
Filename: roothide/dpp-roothide.deb
Section: Tweaks
Priority: optional
Description: roothide安装此版本
Author: Apple
Dev: Apple
Icon: xx
Name: DPP(roothide)

EOF

# 插件2: com.dao.afc2 (rootless) - Section 改为 嗨-系统
echo "  添加: com.dao.afc2 (rootless)"
cat >> Packages << 'EOF'
Package: com.dao.afc2
Version: 1.1.7-1
Architecture: iphoneos-arm64
Maintainer: Cannathea <csupport@cannathea.com>
Pre-Depends: dpkg (>= 1.14.25-8)
Depends: cy+cpu.arm64, mobilesubstrate, firmware (>= 11.0), ldid | firmware (>= 15.0)
Conflicts: com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2, com.cannathea.afc2d-arm64, com.82skao.afc2d-arm64
Replaces: com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2
Provides: com.saurik.afc2d, net.angelxwind.afc2d-arm64, com.mrmadtw.afc2forios11, repo.feng.afc2add11, us.scw.afctwoadd, net.angelxwind.afc2ios70, afc2.25pp, afc2.25pp7, afc2.91, app.taig.afc2
Filename: rootless/AFC2(rootless).deb
Section: Tweaks
Description: 允许设备通过USB访问完整的文件系统，对iOS 11及更高版本的设备特别有用
Tag: purpose::daemon, role::enduser
Author: saurik, Cannathea <csupport@cannathea.com>
Name: AFC2(rootless)

EOF

# 插件3: dev.sys.dipp (rootless) - 添加 Icon
echo "  添加: dev.sys.dipp (rootless)"
cat >> Packages << 'EOF'
Package: dev.sys.dipp
Version: 1.0
Architecture: all
Maintainer: DPP
Depends: firmware (>= 14.0), mobilesubstrate
Filename: rootless/dpp.deb
Section: Tweaks
Priority: optional
Description: rootless安装此版本
Author: Apple
Icon: xx
Name: DPP

EOF

echo "  完成，共添加 3 个插件"

# 计算哈希并写入文件（这部分不变，动态读取）
echo ""
echo "3、计算文件哈希"

# 插件1: dpp-roothide.deb
if [ -f "roothide/dpp-roothide.deb" ]; then
    size1=$(stat -c%s "roothide/dpp-roothide.deb" 2>/dev/null || stat -f%z "roothide/dpp-roothide.deb" 2>/dev/null)
    md5_1=$(md5sum "roothide/dpp-roothide.deb" 2>/dev/null | cut -d' ' -f1)
    sha1_1=$(sha1sum "roothide/dpp-roothide.deb" 2>/dev/null | cut -d' ' -f1)
    sha256_1=$(sha256sum "roothide/dpp-roothide.deb" 2>/dev/null | cut -d' ' -f1)
    
    sed -i "/Filename: roothide\/dpp-roothide.deb/a\\Size: $size1\nMD5sum: $md5_1\nSHA1: $sha1_1\nSHA256: $sha256_1" Packages
    echo "  更新: dpp-roothide.deb"
else
    echo "  ⚠️ 警告: roothide/dpp-roothide.deb 不存在"
fi

# 插件2: AFC2(rootless).deb
if ls rootless/AFC2*.deb >/dev/null 2>&1; then
    actual_file=$(ls rootless/AFC2*.deb 2>/dev/null | head -1)
    size2=$(stat -c%s "$actual_file" 2>/dev/null || stat -f%z "$actual_file" 2>/dev/null)
    md5_2=$(md5sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    sha1_2=$(sha1sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    sha256_2=$(sha256sum "$actual_file" 2>/dev/null | cut -d' ' -f1)
    
    sed -i "/Filename: rootless\/AFC2(rootless).deb/a\\Size: $size2\nMD5sum: $md5_2\nSHA1: $sha1_2\nSHA256: $sha256_2" Packages
    echo "  更新: AFC2(rootless).deb"
else
    echo "  ⚠️ 警告: rootless/AFC2 文件不存在"
fi

# 插件3: dpp.deb
if [ -f "rootless/dpp.deb" ]; then
    size3=$(stat -c%s "rootless/dpp.deb" 2>/dev/null || stat -f%z "rootless/dpp.deb" 2>/dev/null)
    md5_3=$(md5sum "rootless/dpp.deb" 2>/dev/null | cut -d' ' -f1)
    sha1_3=$(sha1sum "rootless/dpp.deb" 2>/dev/null | cut -d' ' -f1)
    sha256_3=$(sha256sum "rootless/dpp.deb" 2>/dev/null | cut -d' ' -f1)
    
    sed -i "/Filename: rootless\/dpp.deb/a\\Size: $size3\nMD5sum: $md5_3\nSHA1: $sha1_3\nSHA256: $sha256_3" Packages
    echo "  更新: dpp.deb"
else
    echo "  ⚠️ 警告: rootless/dpp.deb 不存在"
fi

# 压缩
echo ""
echo "4、压缩文件"
cat Packages | bzip2 > Packages.bz2
echo "  生成: Packages.bz2"
cat Packages | gzip > Packages.gz
echo "  生成: Packages.gz"

# xz 可选
if command -v xz >/dev/null 2>&1; then
    cat Packages | xz > Packages.xz
    echo "  生成: Packages.xz"
else
    echo "  ⚠️ 跳过: xz 命令不存在"
fi

# 生成 Release
echo ""
echo "5、生成 Release"

cat > Release << EOF
Origin: dpp软改工具
Label: dpp软改工具
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 仅用于学习交流
Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")

MD5Sum:
 $(md5sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(md5sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(md5sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

# 如果 xz 存在，加入 Release
if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(md5sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

cat >> Release << EOF

SHA1:
 $(sha1sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(sha1sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(sha1sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(sha1sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

cat >> Release << EOF

SHA256:
 $(sha256sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(sha256sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(sha256sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(sha256sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi

echo "  生成: Release"

# 验证
echo ""
echo "=========================================="
echo "验证哈希一致性"
if [ -f Packages.bz2 ]; then
    echo "Packages.bz2 MD5: $(md5sum Packages.bz2 2>/dev/null | cut -d' ' -f1)"
    echo "Release MD5: $(grep Packages.bz2 Release | head -1 | awk '{print $1}')"
fi

echo ""
echo "生成完成！文件列表："
ls -la Packages* Release
echo "=========================================="

# 推送
echo ""
echo "6、推送到 GitHub"

git add Packages Packages.bz2 Packages.gz Release
if [ -f Packages.xz ]; then
    git add Packages.xz
fi
git commit -m "update repo"

if git push; then
    echo "✅ 推送成功！"
else
    echo "❌ 推送失败，请手动上传文件"
fi

echo ""
echo "完成！"