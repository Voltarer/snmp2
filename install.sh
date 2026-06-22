echo "SNMP_AGENT"
echo "Сборка в Ubuntu:"

echo "Подготовим нужные файлы..."
chmod +x scripts/setup.sh
./scripts/setup.sh

echo "Компиляция с Ubuntu..."
chmod +x scripts/choice.sh
./scripts/choice.sh

