#!/usr/bin/env bash
set -e

APP_NAME="lithium"
INSTALL_DIR="${HOME}/.local/bin"

echo "Instalador do Gerenciador TUI Kiti & Aency (${APP_NAME})"

if ! command -v node >/dev/null 2>&1; then
  echo "Erro: node não encontrado no PATH."
  echo "Instale Node.js antes de continuar."
  exit 1
fi

mkdir -p "${INSTALL_DIR}"

TMP_DIR="$(mktemp -d)"
echo "Baixando arquivos do lithium TUI para ${TMP_DIR}..."

# ATENÇÃO:
# Substitua a URL abaixo pela URL real do seu repositório (por ex., GitHub).
# Exemplo:
#   BASE_URL="https://raw.githubusercontent.com/seu-usuario/lithiumcli/main"
BASE_URL="https://exemplo.com/seu-repo/lithiumcli"

download() {
  local src="$1"
  local dst="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${BASE_URL}/${src}" -o "${dst}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${dst}" "${BASE_URL}/${src}"
  else
    echo "Erro: nem curl nem wget estão instalados."
    exit 1
  fi
}

mkdir -p "${TMP_DIR}/bin" "${TMP_DIR}/src"

download "bin/lithium.js" "${TMP_DIR}/bin/lithium.js"
download "src/index.js" "${TMP_DIR}/src/index.js"

install "${TMP_DIR}/bin/lithium.js" "${INSTALL_DIR}/${APP_NAME}"
chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo ""
echo "Instalação concluída!"
echo "- Binário: ${INSTALL_DIR}/${APP_NAME}"
echo ""
echo "Certifique-se de que ${INSTALL_DIR} está no seu PATH."
echo "Use: ${APP_NAME}"


