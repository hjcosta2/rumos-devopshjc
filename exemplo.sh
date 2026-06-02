#!/bin/bash

# Nome do ficheiro YAML por defeito
YAML_FILE="hosts.yml"

# ==========================================
# FUNÇÃO DE TRAP e GESTÃO DE SINAIS
# ==========================================
capturar_sinais() {
    echo -e "\n\n[AVISO] Operação cancelada pelo utilizador ou interrompida pelo sistema."
    echo "A fechar o script de forma segura..."
    # Se fossem usados ficheiros temporários, seriam removidos aqui:
    # rm -f /tmp/dados_temporarios.$$
    exit 1
}
# Ativar o trap para capturar:
# SIGINT (Ctrl+C), SIGTERM (Sinal de terminação), SIGTSTP (Ctrl+Z)
trap capturar_sinais SIGINT SIGTERM SIGTSTP

# Função para inicializar o ficheiro YAML caso não exista
inicializar_yaml() {
    if [ ! -f "$YAML_FILE" ]; then
        echo "hosts:" > "$YAML_FILE"
        echo "Criado ficheiro inicial: $YAML_FILE"
    fi
}

# Função para adicionar um host ao ficheiro YAML
adicionar_host() {
    local nome="$1"
    local ip="$2"
    local grupo="${3:-geral}" # Se não for especificado um grupo, usa 'geral'

    if [ -z "$nome" ] || [ -z "$ip" ]; then
        echo "Erro: Para adicionar um host necessita de fornecer o Nome e o IP."
        echo "Exemplo: $0 -a myserver 10.0.0.5"
        exit 1
    fi

    inicializar_yaml

    # Verificar se o host já existe no ficheiro para evitar duplicados simples
    if grep -q "name: \"$nome\"" "$YAML_FILE"; then
        echo "Aviso: O host '$nome' já se encontra registado no ficheiro."
        return
    fi

    # Simulação de um processo ligeiramente mais demorado para testar o Ctrl+C
    sleep 1

    # Adicionar a estrutura formatada em YAML
    echo "  - name: \"$nome\"" >> "$YAML_FILE"
    echo "    ip: \"$ip\"" >> "$YAML_FILE"
    echo "    group: \"$grupo\"" >> "$YAML_FILE"

    echo "Host '$nome' ($ip) adicionado com sucesso ao grupo '$grupo'."
}




# Função para exibir a ajuda/utilização do script
exibir_ajuda() {
    echo "Uso: $0 [opção] [parâmetros]"
    echo ""
    echo "Opções disponíveis:"
    echo "  -a, --adicionar    Adiciona um novo host. Requer: <nome_host> <ip_host> [grupo]"
    echo "  -l, --ler          Lê e lista todos os hosts registados."
    echo "  -b, --buscar       Procura um host específico pelo nome. Requer: <nome_host>"
    echo "  -h, --ajuda        Exibe esta mensagem de ajuda."
    echo ""
    echo "Exemplos:"
    echo "  $0 -a servidor1 192.168.1.10 webservers"
    echo "  $0 -l"
    echo "  $0 -b servidor1"
}

# Função para ler e listar todos os hosts
ler_hosts() {
    if [ ! -f "$YAML_FILE" ] || [ "$(wc -l < "$YAML_FILE")" -le 1 ]; then
        echo "O ficheiro '$YAML_FILE' está vazio ou não existe."
        return
    fi

    echo "=== Lista de Hosts Registados ==="
    cat "$YAML_FILE"
}

# Função para buscar um host específico
buscar_host() {
    local nome="$1"
    if [ -z "$nome" ]; then
        echo "Erro: Indique o nome do host que pretende procurar."
        exit 1
    fi

    if [ ! -f "$YAML_FILE" ]; then
        echo "O ficheiro '$YAML_FILE' ainda não existe."
        exit 1
    fi

    # Procura a linha do nome e exibe-a junto com as 2 linhas seguintes (ip e group)
    grep -A 2 "name: \"$nome\"" "$YAML_FILE"
    if [ $? -ne 0 ]; then
        echo "Host '$nome' não foi encontrado."
    fi
}



# ==========================================
# FLUXO PRINCIPAL (EXECUÇÃO)
# ==========================================

# Validação do número de argumentos mínimos
if [ $# -eq 0 ]; then
    exibir_ajuda
    exit 0
fi

# Tratamento dos parâmetros com base no primeiro argumento
case "$1" in
    -a|--adicionar)
        adicionar_host "$2" "$3" "$4"
        ;;
    -l|--ler)
        ler_hosts
        ;;
    -b|--buscar)
        buscar_host "$2"
        ;;
    -h|--ajuda)
        exibir_ajuda
        ;;
    *)
        echo "Opção inválida: $1"
        exibir_ajuda
        exit 1
        ;;
esac
