#!/usr/bin/env bash
set -e

INSTALL_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.local/share/lithiumcli"
CLI_DEFAULT_NAME="lithium"
CLI_ALT_NAME="lithium-cli"
MANAGER_DEFAULT_NAME="lithium-manager"
MANAGER_ALT_NAME="lithium-cli-manager"

# Repositório público
BASE_URL="https://raw.githubusercontent.com/aencyorganization/lithiumcli/main"

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

ask_name_choice() {
  local prompt="$1"
  local default="$2"
  local alt="$3"
  local answer
  echo ""
  echo "${prompt}"
  echo "1) ${default}"
  echo "2) ${alt}"
  read -r -p "Escolha [1/2] (padrão 1): " answer
  case "$answer" in
    2) echo "${alt}" ;;
    *) echo "${default}" ;;
  esac
}

ensure_node() {
  if ! command -v node >/dev/null 2>&1; then
    echo "Erro: node não encontrado no PATH."
    echo "Instale Node.js antes de continuar."
    exit 1
  fi
}

install_cli() {
  ensure_node
  mkdir -p "${INSTALL_DIR}" "${DATA_DIR}"

  local cli_name
  cli_name="$(ask_name_choice 'Nome do comando para o Lithium CLI?' "${CLI_DEFAULT_NAME}" "${CLI_ALT_NAME}")"

  local manager_name
  manager_name="$(ask_name_choice 'Nome do comando para o gerenciador do Lithium CLI?' "${MANAGER_DEFAULT_NAME}" "${MANAGER_ALT_NAME}")"

  echo ""
  echo "Instalando Lithium CLI e gerenciador..."

  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "${tmp}/bin" "${tmp}/src"

  download "bin/lithium.js" "${tmp}/bin/lithium.js"
  download "src/index.js" "${tmp}/src/index.js"
  download "VERSION" "${tmp}/VERSION"

  install "${tmp}/bin/lithium.js" "${INSTALL_DIR}/${cli_name}"
  chmod +x "${INSTALL_DIR}/${cli_name}"

  mkdir -p "${DATA_DIR}"
  cp "${tmp}/src/index.js" "${DATA_DIR}/index.js"
  cp "${tmp}/VERSION" "${DATA_DIR}/VERSION"

  cat > "${INSTALL_DIR}/${manager_name}" <<EOF
#!/usr/bin/env bash
set -e
INSTALL_DIR="${INSTALL_DIR}"
DATA_DIR="${DATA_DIR}"
CLI_NAME="${cli_name}"
BASE_URL="${BASE_URL}"

manager_download() {
  local src="\$1"
  local dst="\$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "\${BASE_URL}/\${src}" -o "\${dst}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "\${dst}" "\${BASE_URL}/\${src}"
  else
    echo "Erro: nem curl nem wget estão instalados."
    exit 1
  fi
}

manager_install() {
  echo "Reinstalando Lithium CLI..."
  mkdir -p "\${INSTALL_DIR}" "\${DATA_DIR}"
  local tmp
  tmp="\$(mktemp -d)"
  mkdir -p "\${tmp}/bin" "\${tmp}/src"
  manager_download "bin/lithium.js" "\${tmp}/bin/lithium.js"
  manager_download "src/index.js" "\${tmp}/src/index.js"
  manager_download "VERSION" "\${tmp}/VERSION"
  install "\${tmp}/bin/lithium.js" "\${INSTALL_DIR}/\${CLI_NAME}"
  chmod +x "\${INSTALL_DIR}/\${CLI_NAME}"
  cp "\${tmp}/src/index.js" "\${DATA_DIR}/index.js"
  cp "\${tmp}/VERSION" "\${DATA_DIR}/VERSION"
  echo "Instalação concluída."
}

manager_update() {
  echo "Verificando atualizações..."
  mkdir -p "\${DATA_DIR}"
  local local_version=""
  if [ -f "\${DATA_DIR}/VERSION" ]; then
    local_version="\$(cat "\${DATA_DIR}/VERSION" | tr -d '[:space:]')"
  fi
  local tmp_ver
  tmp_ver="\$(mktemp)"
  manager_download "VERSION" "\${tmp_ver}"
  local remote_version
  remote_version="\$(cat "\${tmp_ver}" | tr -d '[:space:]')"
  if [ -z "\${remote_version}" ]; then
    echo "Não foi possível obter versão remota."
    exit 1
  fi
  if [ "\${local_version}" = "\${remote_version}" ] && [ -n "\${local_version}" ]; then
    echo "Você já está na versão mais recente (\${local_version})."
    exit 0
  fi
  echo "Atualizando da versão '\${local_version:-nenhuma}' para '\${remote_version}'..."
  manager_install
}

manager_uninstall() {
  echo "Desinstalando Lithium CLI..."
  rm -f "\${INSTALL_DIR}/\${CLI_NAME}"
  rm -rf "\${DATA_DIR}"
  echo "Removido Lithium CLI."
}

case "\$1" in
  install)
    manager_install
    ;;
  update)
    manager_update
    ;;
  uninstall)
    manager_uninstall
    ;;
  *)
    echo "Uso: \$(basename "\$0") [install|update|uninstall]"
    echo ""
    echo "  install   - instala ou reinstala o Lithium CLI"
    echo "  update    - atualiza o Lithium CLI se houver nova versão"
    echo "  uninstall - remove o Lithium CLI instalado"
    ;;
esac
EOF

  chmod +x "${INSTALL_DIR}/${manager_name}"

  echo ""
  echo "Instalação concluída!"
  echo "- CLI: ${INSTALL_DIR}/${cli_name}"
  echo "- Gerenciador instalado: ${INSTALL_DIR}/${manager_name}"
  echo ""
  echo "Certifique-se de que ${INSTALL_DIR} está no seu PATH."
  echo ""
  echo "Exemplos de uso do gerenciador:"
  echo "  ${manager_name} update      # atualizar para última versão"
  echo "  ${manager_name} uninstall   # desinstalar Lithium CLI"
}

uninstall_all() {
  echo "Desinstalando gerenciador e Lithium CLI..."
  for name in "${CLI_DEFAULT_NAME}" "${CLI_ALT_NAME}" "${MANAGER_DEFAULT_NAME}" "${MANAGER_ALT_NAME}"; do
    rm -f "${INSTALL_DIR}/${name}" 2>/dev/null || true
  done
  rm -rf "${DATA_DIR}"
  echo "Remoção concluída."
}

print_menu() {
  echo "LithiumCLI - Gerenciador (Linux/macOS)"
  echo "--------------------------------------"
  echo "1) Instalar / reinstalar Lithium CLI"
  echo "2) Atualizar Lithium CLI"
  echo "3) Desinstalar Lithium CLI e gerenciador"
  echo "q) Sair"
  echo ""
}

main() {
  print_menu
  read -r -p "Escolha uma opção: " opt
  case "$opt" in
    1)
      install_cli
      ;;
    2)
      # usa o gerenciador se já existir, senão faz install_cli
      if command -v "${MANAGER_DEFAULT_NAME}" >/dev/null 2>&1; then
        "${MANAGER_DEFAULT_NAME}" update
      elif command -v "${MANAGER_ALT_NAME}" >/dev/null 2>&1; then
        "${MANAGER_ALT_NAME}" update
      else
        echo "Gerenciador não encontrado, executando instalação..."
        install_cli
      fi
      ;;
    3)
      uninstall_all
      ;;
    q|Q)
      echo "Saindo."
      ;;
    *)
      echo "Opção inválida."
      ;;
  esac
}

main "$@"


