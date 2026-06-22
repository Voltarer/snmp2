#!/bin/bash
echo "Выберите ОС, которую хотите собрать:"
echo "1) Ubuntu"
echo "2) MIPS"
read -p "Ваш выбор: " CHOISE

if [ "$CHOISE" == "1" ]; then
    echo "Компиляция под Ubuntu..."
    ./scripts/build_UBUNTU.sh
elif [ "$CHOISE" == "2" ]; then   
    echo "Компиляция под MIPS"
    ./scripts/build_MIPS.sh
else
    echo "error"
fi