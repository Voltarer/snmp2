PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$PROJECT_ROOT/build"

echo "Идет создание..."
gcc -o my_agent main.c ifTable.c $(net-snmp-config --agent-libs)

if [ $? -eq 0 ]; then
    echo "🚀 УСПЕХ: Файл готов в build/my_agent"
    mv "$PROJECT_ROOT/my_agent" "$PROJECT_ROOT/build"
else
    echo "❌ ОШИБКА компиляции"
fi