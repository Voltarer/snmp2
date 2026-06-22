#!/bin/bash

# --- НАСТРОЙКА ПУТЕЙ ---
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BUILD_DIR="$PROJECT_ROOT/build"
NETSNMP_VER="5.9.3"
NETSNMP_DIR="$PROJECT_ROOT/lib/net-snmp-$NETSNMP_VER"

# Пути внутри твоего Toolchain
LIB_TOOLCHAIN="$PROJECT_ROOT/toolchain"
TOOLCHAIN_BIN="$LIB_TOOLCHAIN/mips-buildroot-linux-uclibc_sdk-buildroot/bin"
SYSROOT="$LIB_TOOLCHAIN/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot"

# Явно добавляем компиляторы в PATH 
export PATH="$TOOLCHAIN_BIN:$PATH"
export SYSROOT="$SYSROOT"

echo "========================================================="
echo " АВТОМАТИЧЕСКАЯ СБОРКА SNMP-АГЕНТА ПОД MIPS "
echo "========================================================="
echo "Корень проекта: $PROJECT_ROOT"
echo "Путь к Sysroot:  $SYSROOT"
echo "========================================================="

# --- ШАГ 1: ПРОВЕРКА И СБОРКА БИБЛИОТЕКИ NET-SNMP ---
# Проверяем наличие ключевого файла библиотеки и папки с инклудами в тулчейне
if [ -f "$SYSROOT/usr/lib/libnetsnmpagent.so" ] && [ -d "$SYSROOT/usr/include/net-snmp" ]; then
    echo "✅ Шаг 1: Библиотека и заголовочные файлы Net-SNMP уже вживлены в Toolchain. Пропускаем сборку библиотеки."
else
    echo "⚠️ Шаг 1: Библиотека или заголовочные файлы Net-SNMP не найдены в Toolchain. Начинаем сборку..."

    # Проверяем, подготовил ли setup.sh исходники
    if [ ! -d "$NETSNMP_DIR" ]; then
        echo "❌ ОШИБКА: Исходные файлы Net-SNMP не найдены в папке: $NETSNMP_DIR"
        echo "Пожалуйста, сначала запустите скрипт setup.sh!"
        exit 1
    fi

    cd "$NETSNMP_DIR"

    echo "Конфигурация Net-SNMP под архитектуру MIPS..."
    make distclean >/dev/null 2>&1 || true
    
    ./configure --host=mips-linux \
        CC="mips-linux-gcc --sysroot=$SYSROOT" \
        AR="mips-linux-ar" \
        RANLIB="mips-linux-ranlib" \
        --disable-embedded-perl \
        --without-perl-modules \
        --disable-snmpv3 \
        --with-default-snmp-version="2" \
        --with-logfile="/var/log/snmpd.log" \
        --with-persistent-directory="/var/net-snmp" \
        --prefix=/usr

    echo "Компиляция Net-SNMP (это может занять пару минут)..."
    PATH=$PATH make -j$(nproc)

    echo "Ручное копирование файлов (.so/.a) и заголовочных файлов в Sysroot..."
    mkdir -p "$SYSROOT/usr/lib"
    mkdir -p "$SYSROOT/usr/include"
    
    # 🌟 ИСПРАВЛЕНИЕ: Копируем заголовки, чтобы компилятор видел net-snmp-config.h
    cp -r include/net-snmp "$SYSROOT/usr/include/"

    # Копируем скомпилированные .so библиотеки
    cp -d snmplib/.libs/libnetsnmp* "$SYSROOT/usr/lib/"
    cp -d agent/.libs/libnetsnmp* "$SYSROOT/usr/lib/"
    cp -d agent/helpers/.libs/libnetsnmp* "$SYSROOT/usr/lib/"
    cp -d agent/mibgroup/.libs/libnetsnmp* "$SYSROOT/usr/lib/" 2>/dev/null || true

    echo "✅ Библиотека и заголовки Net-SNMP успешно установлены в Toolchain!"
fi

# --- ШАГ 2: СБОРКА ТВОЕГО АГЕНТА ---
echo "---------------------------------------------------------"
echo "Шаг 2: Финальная сборка SNMP-агента"
echo "---------------------------------------------------------"

cd "$PROJECT_ROOT"
mkdir -p "$BUILD_DIR"

SRC_FILES="$PROJECT_ROOT/src/main.c $PROJECT_ROOT/src/ifTable.c"

# Настройки линковщика
INCLUDES="-I$SYSROOT/usr/include"
LDFLAGS="-L$SYSROOT/usr/lib"
SNMP_LIBS="-lnetsnmpagent -lnetsnmp -lnetsnmpmibs -lnetsnmphelpers"

echo "Компиляция бинарника my_agent под MIPS..."
mips-linux-gcc -o "$BUILD_DIR/my_agent" \
    $SRC_FILES \
    --sysroot="$SYSROOT" \
    $INCLUDES \
    $LDFLAGS \
    $SNMP_LIBS \
    -std=c99 -DTARGET_MIPS -lpthread

if [ $? -eq 0 ]; then
    echo "========================================================="
    echo "УСПЕХ! Проект полностью собран."
    echo "Исполняемый файл: $BUILD_DIR/my_agent"
    
    # Копирование созданного агента в папку mips_docker
    echo "Копирование бинарника в папку mips_docker..."
    mkdir -p "$PROJECT_ROOT/mips_docker"
    cp "$BUILD_DIR/my_agent" "$PROJECT_ROOT/mips_docker/"
    echo "✅ Файл успешно скопирован в $PROJECT_ROOT/mips_docker/my_agent"
    
    echo "---------------------------------------------------------"
    echo "Информация о файле:"
    file "$BUILD_DIR/my_agent"
    echo "========================================================="
else
    echo "❌ ОШИБКА при сборке агента."
    exit 1
fi