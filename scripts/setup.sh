#!/bin/bash
set -e

# --- НАСТРОЙКА ПУТЕЙ ---
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

TOOLCHAIN_URL="https://github.com/Voltarer/snmp2/releases/tag/docker/toolchain.tar.gz" 
ROMFS_URL="https://github.com/Voltarer/snmp2/releases/tag/docker/romfs.tar.gz"

NETSNMP_VER="5.9.3"
NETSNMP_URL="https://sourceforge.net/projects/net-snmp/files/net-snmp/${NETSNMP_VER}/net-snmp-${NETSNMP_VER}.tar.gz"

LIB_DIR="$PROJECT_ROOT/lib"
NETSNMP_DIR="$LIB_DIR/net-snmp-$NETSNMP_VER"
LIB_TOOLCHAIN="$PROJECT_ROOT/toolchain"

echo "=== Запуск настройки окружения ==="

# Проверка наличия wget или curl
echo "Проверка наличия wget/curl..."
if command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -c -O"
elif command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -L -o"
else
    echo "❌ wget или curl не найдены. Установите один из них."
    exit 1
fi
echo "✅ Инструмент для скачивания найден."

# Создаем структуру папок
echo "Проверка структуры папок..."
mkdir -p "$LIB_DIR"
mkdir -p "$LIB_TOOLCHAIN"
mkdir -p "$PROJECT_ROOT/build"
echo "✅ Базовые папки проверены/созданы."

######################################################################
# ШАГ 1: СКАЧИВАНИЕ И РАСПАКОВКА TOOLCHAIN
echo "--- 1. Настройка Toolchain ---"
if [ -d "$LIB_TOOLCHAIN/mips-buildroot-linux-uclibc_sdk-buildroot" ]; then
    echo "✅ Toolchain уже распакован."
else
    echo "Скачивание Toolchain..."
    $DOWNLOAD_CMD "$PROJECT_ROOT/toolchain.tar.gz" "$TOOLCHAIN_URL"
    
    echo "Распаковка Toolchain..."
    tar -xzf "$PROJECT_ROOT/toolchain.tar.gz" -C "$LIB_TOOLCHAIN"
    rm "$PROJECT_ROOT/toolchain.tar.gz"
    echo "✅ Toolchain успешно настроен, архив удален."
fi

######################################################################
# ШАГ 2: СКАЧИВАНИЕ ROMFS В MIPS_DOCKER
echo "--- 2. Настройка romfs для Docker ---"
if [ -f "$MIPS_DOCKER_DIR/romfs.tar.gz" ]; then
    echo "✅ Файл romfs.tar.gz уже находится в mips_docker."
else
    echo "Скачивание romfs.tar.gz..."
    $DOWNLOAD_CMD "$MIPS_DOCKER_DIR/romfs.tar.gz" "$ROMFS_URL"

    echo "✅ Файл romfs.tar.gz успешно загружен"
fi

######################################################################
# ШАГ 3: СКАЧИВАНИЕ И РАСПАКОВКА NET-SNMP
echo "--- 3. Настройка исходников Net-SNMP ---"
if [ -d "$NETSNMP_DIR" ]; then
    echo "✅ Исходники Net-SNMP уже распакованы в $NETSNMP_DIR."
else
    echo "Скачивание архива Net-SNMP $NETSNMP_VER..."
    $DOWNLOAD_CMD "$LIB_DIR/net-snmp-$NETSNMP_VER.tar.gz" "$NETSNMP_URL"
    
    echo "Распаковка архива Net-SNMP..."
    tar -xzf "$LIB_DIR/net-snmp-$NETSNMP_VER.tar.gz" -C "$LIB_DIR"
    rm "$LIB_DIR/net-snmp-$NETSNMP_VER.tar.gz"
    echo "✅ Исходники Net-SNMP распакованы, архив удален."
fi

echo "========================================================="
echo "Настройка окружения успешно завершена!"
echo "========================================================="