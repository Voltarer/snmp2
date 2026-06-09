#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include <signal.h>
#include "ifTable.h"

static int keep_runnig;

void stop_server (int a){
    keep_runnig = 0;
}

int main(int agrc, int **agrv){

    netsnmp_ds_get_boolean(NETSNMP_DS_APPLICATION_ID,NETSNMP_DS_AGENT_ROLE);

    init_agent("test");

    init_ifTable();

    init_snmp("test");

    keep_runnig = 1;

    signal(SIGTERM,stop_server);
    signal(SIGINT,stop_server);

    printf("Сервер запущен");

    while (keep_runnig){
        agent_check_and_process(1);
    }

    snmp_shutdown("test");

    return 0;
}