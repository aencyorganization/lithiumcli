## Lithium TUI - Gerenciador de Aplicações Kiti & Aency

CLI TUI em Node.js (CommonJS) para gerenciar aplicações dos projetos **Kiti** e **Aency**.

### Instalação (via curl)

Adapte a URL abaixo para o local onde o repositório estiver hospedado:

```bash
curl -fsSL https://exemplo.com/seu-repo/lithiumcli/install-lithium.sh | bash
```

Isso irá instalar o binário `lithium` em `~/.local/bin` (certifique-se de que esse diretório está no seu `PATH`).

### Uso

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


