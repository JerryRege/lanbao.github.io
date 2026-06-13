#!/bin/sh
echo "1、删除旧版Packages"
rm -f Packages Packages.*

echo "2、扫描重新生成、压缩Packages"

# 清空 Packages 文件
> Packages

# 手动扫描 roothide、rootless、rootful 目录
for dir in roothide rootless rootful; do
    if [ -d "$dir" ]; then
        echo "扫描目录: $dir/"
        for deb in $(find "$dir" -name "*.deb" 2>/dev/null); do
            echo "  处理: $(basename "$deb")"
            
            # 从文件名提取包名和版本
            filename=$(basename "$deb")
            pkgname=${filename%.deb}
            
            # 尝试提取版本号（通常格式：包名_版本.deb）
            version="1.0"
            if echo "$pkgname" | grep -q "_"; then
                version=$(echo "$pkgname" | sed 's/.*_//')
                pkgname=$(echo "$pkgname" | sed 's/_.*//')
            fi
            
            # 计算文件大小和哈希
            size=$(stat -c%s "$deb" 2>/dev/null || stat -f%z "$deb" 2>/dev/null)
            md5=$(md5sum "$deb" 2>/dev/null | cut -d' ' -f1)
            sha1=$(sha1sum "$deb" 2>/dev/null | cut -d' ' -f1)
            sha256=$(sha256sum "$deb" 2>/dev/null | cut -d' ' -f1)
            
            # 写入 Packages
            cat >> Packages << PKGEOF
Package: $pkgname
Version: $version
Architecture: iphoneos-arm
Maintainer: unknown
Description: Auto generated package
Filename: $deb
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256

PKGEOF
        done
    fi
done

echo "生成的包数量: $(grep -c '^Package:' Packages)"

echo "3、压缩Packages"
# 压缩成各种格式
if command -v xz >/dev/null 2>&1; then
    cat Packages | xz > Packages.xz
    echo "  生成: Packages.xz"
fi
cat Packages | bzip2 > Packages.bz2
echo "  生成: Packages.bz2"
cat Packages | gzip > Packages.gz
echo "  生成: Packages.gz"
if command -v lzma >/dev/null 2>&1; then
    cat Packages | lzma > Packages.lzma
    echo "  生成: Packages.lzma"
fi
if command -v zstd >/dev/null 2>&1; then
    cat Packages | zstd > Packages.zst
    echo "  生成: Packages.zst"
fi

echo "4、生成 Release 文件"

# 获取文件大小和哈希的函数
get_size() {
    stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || echo "0"
}

# 生成 Release
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
 $(md5sum Packages 2>/dev/null | awk '{print $1" "$2" Packages"}')
 $(md5sum Packages.bz2 2>/dev/null | awk '{print $1" "$2" Packages.bz2"}')
 $(md5sum Packages.gz 2>/dev/null | awk '{print $1" "$2" Packages.gz"}')
EOF

# 可选压缩格式的校验和（如果文件存在）
if [ -f Packages.xz ]; then
    cat >> Release << EOF
 $(md5sum Packages.xz 2>/dev/null | awk '{print $1" "$2" Packages.xz"}')
EOF
fi
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(md5sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(md5sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
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
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(sha1sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(sha1sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
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
if [ -f Packages.lzma ]; then
    cat >> Release << EOF
 $(sha256sum Packages.lzma 2>/dev/null | awk '{print $1" "$2" Packages.lzma"}')
EOF
fi
if [ -f Packages.zst ]; then
    cat >> Release << EOF
 $(sha256sum Packages.zst 2>/dev/null | awk '{print $1" "$2" Packages.zst"}')
EOF
fi

echo "  生成: Release"

echo "5、推送提交"
git add .
git commit -s -m "sync repo"
git push

echo "完成！"