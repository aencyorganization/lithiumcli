/**
 * TUI principal do gerenciador de aplicações Kiti & Aency.
 * Implementado em Node.js (CommonJS) sem dependências externas.
 */

const { spawn } = require('child_process');

const MODES = ['Aency', 'Kiti'];

// Cores ANSI simples
const COLORS = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  gray: '\x1b[90m',
};

function clearScreen() {
  process.stdout.write('\x1b[2J\x1b[0f');
}

function getKitiDependenciesStatus() {
  const deps = ['curl', 'wget', 'node'];
  const status = {};

  for (const dep of deps) {
    try {
      // command -v é geralmente mais portável que which, mas depende do shell.
      // Aqui usamos `which` diretamente como comando.
      const which = spawn('which', [dep]);
      status[dep] = false;

      which.on('exit', (code) => {
        status[dep] = code === 0;
      });
    } catch (e) {
      status[dep] = false;
    }
  }

  return status;
}

function checkBinarySync(cmd) {
  // Tentativa simples e síncrona usando spawnSync sem depender de módulos extras.
  try {
    const { spawnSync } = require('child_process');
    const res = spawnSync('which', [cmd]);
    return res.status === 0;
  } catch (e) {
    return false;
  }
}

function renderUI(state) {
  clearScreen();

  const { modeIndex, focusIndex, message } = state;
  const mode = MODES[modeIndex];
  const width = process.stdout.columns || 60;

  function padCenter(text) {
    const len = text.length;
    if (len >= width - 2) return text;
    const totalPad = width - 2 - len;
    const left = Math.floor(totalPad / 2);
    const right = totalPad - left;
    return ' '.repeat(left) + text + ' '.repeat(right);
  }

  const topLeft = `${COLORS.gray}[TAB: modo]${COLORS.reset}`;
  const topRight = `${COLORS.gray}[↑↓: seleção]${COLORS.reset}`;

  const horizontal = '─'.repeat(Math.max(width - 2, 10));
  const topBorder = `┌${horizontal}┐`;
  const bottomBorder = `└${horizontal}┘`;

  // Cabeçalho com cantos
  console.log(
    `${COLORS.cyan}${topBorder}${COLORS.reset}`
  );

  const titleLine = padCenter(`${COLORS.bright}Gerenciador TUI - Kiti & Aency${COLORS.reset}`);
  console.log(`│${titleLine}│`);

  // Linha de modo atual
  const modeLabel =
    mode === 'Aency'
      ? `${COLORS.bright}[Aency]${COLORS.reset}   ${COLORS.dim}Kiti${COLORS.reset}`
      : `${COLORS.dim}Aency${COLORS.reset}   ${COLORS.bright}[Kiti]${COLORS.reset}`;
  const modeLine = padCenter(`Modo: ${modeLabel}`);
  console.log(`│${modeLine}│`);

  // Linha com indicadores nos cantos superiores (abaixo do título)
  const indicatorsLineRaw = `${topLeft}${' '.repeat(Math.max(width - 2 - topLeft.length - topRight.length, 1))}${topRight}`;
  const indicatorsLine = indicatorsLineRaw.slice(0, width - 2);
  console.log(`│${indicatorsLine}│`);

  // Linha em branco
  console.log(`│${' '.repeat(width - 2)}│`);

  // Área de conteúdo centralizada
  function printCenteredLine(text, color) {
    const colored = color ? color + text + COLORS.reset : text;
    const line = padCenter(colored);
    console.log(`│${line}│`);
  }

  printCenteredLine('Controles principais:', COLORS.yellow);
  printCenteredLine('TAB: alternar modo (Aency / Kiti)', COLORS.gray);
  printCenteredLine('↑/↓: mover seleção', COLORS.gray);
  printCenteredLine('ENTER: executar ação', COLORS.gray);
  printCenteredLine('Q ou ESC: sair', COLORS.gray);
  console.log(`│${' '.repeat(width - 2)}│`);

  if (mode === 'Aency') {
    printCenteredLine('Funcionalidades Aency (em breve)', COLORS.magenta);
    printCenteredLine('Gerenciamento de aplicações Aency será adicionado aqui.', COLORS.dim);
    console.log(`│${' '.repeat(width - 2)}│`);
    printCenteredLine('Use o modo Kiti para instalar o KitiOS Server.', COLORS.cyan);
  } else if (mode === 'Kiti') {
    const isSelected = focusIndex === 0;
    printCenteredLine('Aplicações Kiti disponíveis:', COLORS.magenta);
    const bullet = isSelected ? `${COLORS.bright}▶${COLORS.reset}` : ' ';
    const itemText = `${bullet} KitiOS Server - Instalar / Gerenciar`;
    printCenteredLine(itemText, isSelected ? COLORS.green : COLORS.reset);
    console.log(`│${' '.repeat(width - 2)}│`);
    printCenteredLine('Requisitos: curl, wget, node', COLORS.yellow);
  }

  if (message) {
    console.log(`│${' '.repeat(width - 2)}│`);
    const lines = message.split('\n');
    for (const line of lines) {
      const truncated = line.length > width - 4 ? line.slice(0, width - 5) + '…' : line;
      const padded = truncated.padEnd(width - 2, ' ');
      console.log(`│${padded}│`);
    }
  }

  console.log(
    `${COLORS.cyan}${bottomBorder}${COLORS.reset}`
  );
}

function installKitiOSServer(onMessage) {
  const missing = [];

  if (!checkBinarySync('curl')) missing.push('curl');
  if (!checkBinarySync('wget')) missing.push('wget');
  if (!checkBinarySync('node')) missing.push('node');

  if (missing.length > 0) {
    const msg =
      'Algumas dependências não estão instaladas:\n' +
      `- Falta(m): ${missing.join(', ')}\n\n` +
      'Instale-as manualmente e tente novamente.\n' +
      'Exemplos (ajuste conforme sua distro):\n' +
      '- Debian/Ubuntu: sudo apt install curl wget nodejs\n' +
      '- Arch/CachyOS: sudo pacman -S curl wget nodejs';
    onMessage(msg);
    return;
  }

  onMessage(
    'Iniciando instalação do KitiOS Server...\n' +
      'Comando: curl -L https://raw.githubusercontent.com/Kiti-Co/Kiti-CLI/main/install-kiti.sh | bash\n\n' +
      'A saída do instalador será exibida abaixo:\n'
  );

  const child = spawn(
    'bash',
    ['-lc', 'curl -L https://raw.githubusercontent.com/Kiti-Co/Kiti-CLI/main/install-kiti.sh | bash'],
    {
      stdio: ['ignore', 'pipe', 'pipe'],
    }
  );

  child.stdout.on('data', (data) => {
    process.stdout.write(data.toString());
  });

  child.stderr.on('data', (data) => {
    process.stderr.write(data.toString());
  });

  child.on('close', (code) => {
    if (code === 0) {
      onMessage('\nInstalação do KitiOS Server concluída com sucesso.');
    } else {
      onMessage(`\nInstalação do KitiOS Server finalizou com código ${code}. Verifique os logs acima.`);
    }
  });
}

async function runApp() {
  const state = {
    modeIndex: 0, // 0 = Aency, 1 = Kiti
    focusIndex: 0,
    message: '',
  };

  // Garante que o stdin esteja em modo raw e sem eco.
  const stdin = process.stdin;
  stdin.setRawMode(true);
  stdin.resume();
  stdin.setEncoding('utf8');

  function updateMessage(msg) {
    state.message = msg;
    renderUI(state);
  }

  renderUI(state);

  stdin.on('data', (key) => {
    // Ctrl+C
    if (key === '\u0003') {
      process.exit(0);
      return;
    }

    const code = key.charCodeAt(0);

    // ESC ou 'q'/'Q'
    if (key === '\u001b' || key === 'q' || key === 'Q') {
      process.exit(0);
      return;
    }

    // TAB
    if (key === '\t') {
      state.modeIndex = (state.modeIndex + 1) % MODES.length;
      state.focusIndex = 0;
      state.message = '';
      renderUI(state);
      return;
    }

    // ENTER
    if (key === '\r' || key === '\n') {
      if (MODES[state.modeIndex] === 'Kiti' && state.focusIndex === 0) {
        installKitiOSServer(updateMessage);
      }
      return;
    }

    // Setas (sequências ANSI)
    if (key === '\u001b[A') {
      // Up
      if (MODES[state.modeIndex] === 'Kiti') {
        state.focusIndex = 0; // só um item, mantemos em 0
        renderUI(state);
      }
      return;
    }

    if (key === '\u001b[B') {
      // Down
      if (MODES[state.modeIndex] === 'Kiti') {
        state.focusIndex = 0;
        renderUI(state);
      }
      return;
    }
  });
}

module.exports = {
  runApp,
};


