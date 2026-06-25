#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include <signal.h>
#include <stdio.h>
#include "ifTable.h"

static int keep_running;

void stop_server(int a) {
    keep_running = 0;
}

void init_ifTable(void);

int main(int argc, char **argv) {
    // Устанавливаем (set), субагент AgentX
    netsnmp_ds_set_boolean(NETSNMP_DS_APPLICATION_ID, NETSNMP_DS_AGENT_ROLE, 1);

    init_master_agent();

    // Инициализируем фабрику агентов под именем "test"
    init_agent("my_agent");

    // Инициализируем таблицы
    init_ifTable();

    // Читаем конфигурацию "test"
    init_snmp("my_agent");

    keep_running = 1;

    // Перехватываем сигналы завершения, чтобы красиво закрыть агент
    signal(SIGTERM, stop_server);
    signal(SIGINT, stop_server);

    printf("Субагент запущен и готов к работе...\n");
    fflush(stdout); 

    // Главный рабочий цикл субагента
    while (keep_running) {
        agent_check_and_process(1); 
    }

    // Корректное завершение работы
    snmp_shutdown("my_agent");

    return 0;
}