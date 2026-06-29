# Используем легкий образ
FROM ubuntu:24.04

# Устанавливаем эмулятор для Big Endian MIPS (MSB)
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Копируем и распаковываем базовую файловую систему устройства
COPY mips_docker/romfs.tar.gz .
RUN mkdir -p /app/romfs && tar xf romfs.tar.gz -C /app/romfs && rm romfs.tar.gz

# 2. Копируем скомпилированные под MIPS библиотеки net-snmp
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/usr/lib/libnetsnmp*.so* /app/romfs/usr/lib/

# 3. Копируем собранного MIPS-агента
COPY mips_docker/my_agent /app/romfs/usr/bin/my_agent
RUN chmod +x /app/romfs/usr/bin/my_agent

# 4. Копируем конфигурационный файл агента
COPY mips_docker/my_agent.conf /app/romfs/usr/bin/my_agent.conf
# Можно также положить в /etc/snmp/, но чтобы не плодить папки, оставим рядом с бинарником

# 5. Копируем ВСЕ системные библиотеки из тулчейна
RUN mkdir -p /lib /app/romfs/lib
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/lib/*.so* /lib/
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/lib/*.so* /app/romfs/lib/

USER root

CMD ["qemu-mips-static", "-L", "/app/romfs", "-E", "LD_LIBRARY_PATH=/lib:/usr/lib", "-E", "MIBS=+ALL", "/app/romfs/usr/bin/my_agent", "-c", "/app/romfs/usr/bin/my_agent.conf", "-Dread_config"]