# Используем легкий образ
FROM ubuntu:24.04

# Устанавливаем эмулятор для Big Endian MIPS (MSB)
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем и распаковываем базовую файловую систему устройства
COPY mips_docker/romfs.tar.gz .
RUN mkdir -p /app/romfs && tar xf romfs.tar.gz -C /app/romfs && rm romfs.tar.gz

# Копируем скомпилированные под MIPS библиотеки net-snmp
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/usr/lib/libnetsnmp*.so* /app/romfs/usr/lib/

# Копируем собранного MIPS-агента
COPY mips_docker/my_agent /app/romfs/usr/bin/my_agent
RUN chmod +x /app/romfs/usr/bin/my_agent

# Переносим конфиг в системную директорию Net-SNMP
RUN mkdir -p /app/romfs/usr/etc/snmp
COPY mips_docker/my_agent.conf /app/romfs/usr/etc/snmp/my_agent.conf

# Копируем текстовые MIB-файлы в файловую систему эмулятора
RUN mkdir -p /app/romfs/usr/share/snmp/mibs
COPY mips_docker/mibs/ /app/romfs/usr/share/snmp/mibs/

# Копируем ВСЕ системные библиотеки из тулчейна
RUN mkdir -p /lib /app/romfs/lib
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/lib/*.so* /lib/
COPY toolchain/mips-buildroot-linux-uclibc_sdk-buildroot/mips-buildroot-linux-uclibc/sysroot/lib/*.so* /app/romfs/lib/

USER root

CMD ["qemu-mips-static", "-L", "/app/romfs", "-E", "LD_LIBRARY_PATH=/lib:/usr/lib", "-E", "MIBS=+ALL", "-E", "MIBDIRS=/usr/share/snmp/mibs", "/app/romfs/usr/bin/my_agent"]