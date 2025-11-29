## LithiumCLI TUI - Kiti & Aency

CLI TUI em Node.js (CommonJS) para gerenciar aplicações dos projetos **Kiti** e **Aency**.

O código-fonte está em `aencyorganization/lithiumcli` (GitHub).

---

## Instalação e gerenciamento via Lithium CLI Manager

O Lithium não é instalado diretamente via `npm`, e sim por um **gerenciador** (`lithium-cli-manager`) que:

- **instala** o Lithium TUI (CLI principal);
- **atualiza** comparando a versão local com a publicada no GitHub;
- **desinstala** o Lithium TUI e o próprio gerenciador.

O gerenciador existe em duas variantes:

- `lithium-cli-manager.sh` (Linux/macOS, bash/sh)
- `lithium-cli-manager.ps1` (Windows, PowerShell)

### Linux / macOS

**Usando `curl`:**

```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/lithiumcli/main/lithium-cli-manager.sh | bash
```

**Usando `wget`:**

```bash
wget -qO- https://raw.githubusercontent.com/aencyorganization/lithiumcli/main/lithium-cli-manager.sh | bash
```

O script irá:

- pedir o nome do comando para o CLI (`lithium` ou `lithium-cli`);
- pedir o nome do comando para o gerenciador (`lithium-manager` ou `lithium-cli-manager`);
- instalar o CLI em `~/.local/bin` (por padrão) e salvar versão/arquivos em `~/.local/share/lithiumcli`.

Depois disso, você pode:

- **Atualizar**: `lithium-manager update` (ou `lithium-cli-manager update`)
- **Desinstalar**: `lithium-manager uninstall` (ou `lithium-cli-manager uninstall`)

> Certifique-se de que `~/.local/bin` está no seu `PATH`.

### Windows (PowerShell)

Execute no PowerShell (como usuário normal):

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/aencyorganization/lithiumcli/main/lithium-cli-manager.ps1 -UseBasicParsing | iex"
```

O script irá perguntar os nomes dos comandos (CLI e gerenciador) e instalar em:

- CLI/manager: `%USERPROFILE%\AppData\Local\Microsoft\WindowsApps`
- Dados: `%USERPROFILE%\.lithiumcli`

Depois disso, você pode rodar:

- **Atualizar**: `lithium-manager.ps1 -Action update` (ou `lithium-cli-manager.ps1 -Action update`)
- **Desinstalar**: `lithium-manager.ps1 -Action uninstall` (ou `lithium-cli-manager.ps1 -Action uninstall`)

---

## Uso do Lithium TUI

Depois de instalado, rode o comando que você escolheu (por exemplo, `lithium`):

```bash
lithium
```

- **TAB**: alterna entre os modos **Aency** e **Kiti**
- **Setas ↑/↓**: movem a seleção (quando houver mais opções)
- **ENTER**: executa a ação selecionada
- **Q** ou **ESC**: sai do programa

### Modo Aency

Por enquanto apenas exibe um placeholder informando que as funcionalidades de gerenciamento Aency serão adicionadas futuramente.

### Modo Kiti

Disponível para instalar o **KitiOS Server**.

Requisitos:

- `curl`
- `wget`
- `node`

Se qualquer um deles não estiver instalado, o TUI mostrará uma mensagem indicando quais pacotes estão faltando e sugerindo comandos de instalação genéricos (para Debian/Ubuntu e Arch/CachyOS).

Quando todos os requisitos estiverem presentes, a instalação roda o comando:

```bash
curl -L https://raw.githubusercontent.com/Kiti-Co/Kiti-CLI/main/install-kiti.sh | bash
```

