#!/usr/bin/env node

/**
 * CLI wrapper que apenas delega para o TUI principal.
 * Mantido em CJS para compatibilidade ampla.
 */

const path = require('path');
const { runApp } = require(path.join(__dirname, '..', 'src', 'index.js'));

runApp().catch((err) => {
  console.error('Erro inesperado:', err && err.message ? err.message : err);
  process.exitCode = 1;
});


