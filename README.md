# speedtest-automatizacion

Automatización del comando sppeedtest para Linux (Debian o Ubuntu específicamente) hecha en bash y con avisos por Telegram por medio de un bot.

Dependencias necesarias:

- `curl`
- `speedtest-cli`

Modo de uso básico:

```shell
./speedtest.sh -b BOT_TOKEN -c CHAT_ID
```

Opciones disponibles:

| Opcion | Descripción |
| - | - |
| `-b BOT_TOKEN` | Token del bot de Telegram. |
| `-c CHAT_ID` | ID del chat de Telegram. |
| `-h o --help` | Mostrar la ayuda del comando. |
| | |
