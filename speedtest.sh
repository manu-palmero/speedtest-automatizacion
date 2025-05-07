#!/bin/bash

# === VERIFICAR DEPENDENCIAS ===

if ! command -v speedtest &> /dev/null; then
    echo "❌ El paquete 'speedtest-cli' no está instalado. Por favor, instálalo con 'sudo apt install speedtest-cli'."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ El paquete 'curl' no está instalado. Por favor, instálalo con 'sudo apt install curl'."
    exit 1
fi

# === FUNCIONES ===
# Función para mostrar el uso del script
function usage() {
    echo "Uso: $0 -b BOT_TOKEN -c CHAT_ID"
    echo "  -b BOT_TOKEN   Token del bot de Telegram."
    echo "  -c CHAT_ID     ID del chat de Telegram."
    echo "  -h             Mostrar esta ayuda."
    echo "  --help         Mostrar esta ayuda."
    exit 0
}
# Función para mostrar un mensaje de error y salir
function error() {
    echo "❌ $1"
    exit 1
}
# Función para enviar un mensaje a Telegram
function enviar_mensaje_telegram() {
    local BOT_TOKEN="$1"
    local CHAT_ID="$2"
    local message="$3"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message"
}

# === VARIABLES ===

# Configuración de Telegram
while getopts "b:c:-:h" opt; do
    case $opt in
        b) BOT_TOKEN="$OPTARG" ;;
        c) CHAT_ID="$OPTARG" ;;
        h) 
            usage
            ;;
        -)
            case $OPTARG in
                help)
                    usage
                    ;;
                *)
                    error "Opción inválida. Usa -h o --help para ayuda."
                    ;;
            esac
            ;;
        *) 
            error "Opción inválida. Usa -h o --help para ayuda."
            ;;
    esac
done
# Verificar que las variables requeridas estén definidas
if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
    echo "❌ Debes proporcionar el BOT_TOKEN y el CHAT_ID. Usa -h o --help para ayuda."
    exit 1
fi

TMP_FILE=$(mktemp /tmp/speedtest_result_XXXXX.txt)
# TMP_FILE="/tmp/speedtest_result.txt"


# === EJECUCIÓN ===

# Ejecutar speedtest y guardar salida
if ! speedtest > "$TMP_FILE" 2>&1; then
    ERROR_MSG="❌ Error al ejecutar speedtest."
    enviar_mensaje_telegram "$BOT_TOKEN" "$CHAT_ID" "$ERROR_MSG"
    # curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    #     -d chat_id="$CHAT_ID" \
    #     -d text="$ERROR_MSG"
    exit 1
fi

# Filtrar líneas de interés
DOWNLOAD=$(grep "Download" "$TMP_FILE")
UPLOAD=$(grep "Upload" "$TMP_FILE")

# Si no encontró las líneas, también considerar como error
if [[ -z "$DOWNLOAD" || -z "$UPLOAD" ]]; then
    ERROR_MSG="⚠️ Speedtest se ejecutó pero no se detectaron resultados válidos."
    enviar_mensaje_telegram "$BOT_TOKEN" "$CHAT_ID" "$ERROR_MSG"
    # curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    #     -d chat_id="$CHAT_ID" \
    #     -d text="$ERROR_MSG"
    exit 1
fi

# Armar mensaje final
MESSAGE="✅ Resultado de Speedtest:
$DOWNLOAD
$UPLOAD"

# Enviar por Telegram
enviar_mensaje_telegram "$BOT_TOKEN" "$CHAT_ID" "$MESSAGE"
# curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
#     -d chat_id="$CHAT_ID" \
#     -d text="$MESSAGE"

# Eliminar el archivo temporal
sudo rm -f "$TMP_FILE" 
exit 0
