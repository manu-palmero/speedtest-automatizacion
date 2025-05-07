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

# === VARIABLES ===

# Configuración de Telegram
while getopts "b:c:-:h" opt; do
    case $opt in
        b) BOT_TOKEN="$OPTARG" ;;
        c) CHAT_ID="$OPTARG" ;;
        h) 
            echo "Uso: $0 -b BOT_TOKEN -c CHAT_ID"
            exit 0
            ;;
        -)
            case $OPTARG in
                help)
                    echo "Uso: $0 -b BOT_TOKEN -c CHAT_ID"
                    exit 0
                    ;;
                *)
                    echo "Opción inválida. Usa -h o --help para ayuda."
                    exit 1
                    ;;
            esac
            ;;
        *) 
            echo "Opción inválida. Usa -h o --help para ayuda."
            exit 1
            ;;
    esac
done
# Verificar que las variables requeridas estén definidas
if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
    echo "❌ Debes proporcionar el BOT_TOKEN y el CHAT_ID. Usa -h para ayuda."
    exit 1
fi
TMP_FILE="/tmp/speedtest_result.txt"


# === EJECUCIÓN ===

# Ejecutar speedtest y guardar salida
if ! speedtest > "$TMP_FILE" 2>&1; then
    ERROR_MSG="❌ Error al ejecutar speedtest."
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode=Markdown \
        -d text="$ERROR_MSG"
    exit 1
fi

# Filtrar líneas de interés
DOWNLOAD=$(grep "Download" "$TMP_FILE")
UPLOAD=$(grep "Upload" "$TMP_FILE")

# Si no encontró las líneas, también considerar como error
if [[ -z "$DOWNLOAD" || -z "$UPLOAD" ]]; then
    ERROR_MSG="⚠️ Speedtest se ejecutó pero no se detectaron resultados válidos."
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode=Markdown \
        -d text="$ERROR_MSG"
    exit 1
fi

# Armar mensaje final
MESSAGE="✅ Resultado de Speedtest:
$DOWNLOAD
$UPLOAD"

# Enviar por Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d parse_mode=Markdown \
    -d text="$MESSAGE"

exit 0
