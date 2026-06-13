#!/bin/sh
echo "1、删除旧版Packages"
rm Packages Packages.*

echo "2、扫描重新生成、压缩Packages"
dpkg-scanpackages --multiversion roothide >> Packages
dpkg-scanpackages --multiversion rootless >> Packages
dpkg-scanpackages --multiversion rootful >> Packages

cat Packages | xz > Packages.xz
cat Packages | bzip2 > Packages.bz2
cat Packages | gzip > Packages.gz
cat Packages | lzma > Packages.lzma
cat Packages | zstd > Packages.zst

echo "3、生成 Release 文件"
# 手动生成 Release 文件（替代 apt-ftparchive）
cat > Release << EOF
Origin: dpp隐私保护
Label: dpp隐私保护
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 仅用于学习交流
Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")

MD5Sum:
 $(md5sum Packages | awk '{print $1" "$2" Packages"}')
 $(md5sum Packages.bz2 | awk '{print $1" "$2" Packages.bz2"}')
 $(md5sum Packages.gz | awk '{print $1" "$2" Packages.gz"}')
 $(md5sum Packages.xz | awk '{print $1" "$2" Packages.xz"}')
 $(md5sum Packages.lzma | awk '{print $1" "$2" Packages.lzma"}')
 $(md5sum Packages.zst | awk '{print $1" "$2" Packages.zst"}')

SHA1:
 $(sha1sum Packages | awk '{print $1" "$2" Packages"}')
 $(sha1sum Packages.bz2 | awk '{print $1" "$2" Packages.bz2"}')
 $(sha1sum Packages.gz | awk '{print $1" "$2" Packages.gz"}')
 $(sha1sum Packages.xz | awk '{print $1" "$2" Packages.xz"}')
 $(sha1sum Packages.lzma | awk '{print $1" "$2" Packages.lzma"}')
 $(sha1sum Packages.zst | awk '{print $1" "$2" Packages.zst"}')

SHA256:
 $(sha256sum Packages | awk '{print $1" "$2" Packages"}')
 $(sha256sum Packages.bz2 | awk '{print $1" "$2" Packages.bz2"}')
 $(sha256sum Packages.gz | awk '{print $1" "$2" Packages.gz"}')
 $(sha256sum Packages.xz | awk '{print $1" "$2" Packages.xz"}')
 $(sha256sum Packages.lzma | awk '{print $1" "$2" Packages.lzma"}')
 $(sha256sum Packages.zst | awk '{print $1" "$2" Packages.zst"}')
EOF

echo "4、推送提交"
git add .
git commit -s -m "sync repo"
git push