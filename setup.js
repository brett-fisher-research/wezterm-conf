#!/usr/bin/env node
// Idempotent WezTerm config setup. Safe to run repeatedly.
// 1. Ensures JetBrainsMono Nerd Font is present (installs via winget on Windows,
//    prints guidance elsewhere) — the config pins it via font_with_fallback.
// 2. Copies wezterm.lua to ~/.wezterm.lua, which WezTerm reads on every platform.

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const SRC = path.join(__dirname, 'wezterm.lua');
const DEST = path.join(os.homedir(), '.wezterm.lua');
const WINGET_FONT_ID = 'DEVCOM.JetBrainsMonoNerdFont';

function log(msg) {
  console.log(`[wezterm-conf] ${msg}`);
}

// True when a JetBrainsMono Nerd Font file exists in the per-user or system font dir
// (winget installs fonts per-user; manual installs may land system-wide).
function fontInstalledWindows() {
  const fontDirs = [
    path.join(process.env.LOCALAPPDATA || '', 'Microsoft', 'Windows', 'Fonts'),
    'C:\\Windows\\Fonts',
  ];
  return fontDirs.some((dir) => {
    let files;
    try {
      files = fs.readdirSync(dir);
    } catch {
      return false;
    }
    return files.some((f) => /^JetBrainsMono.*(NerdFont|NF)/i.test(f));
  });
}

function ensureFont() {
  if (process.platform === 'win32') {
    if (fontInstalledWindows()) {
      log('JetBrainsMono Nerd Font already installed — skipping.');
      return;
    }
    log(`Installing JetBrainsMono Nerd Font via winget (${WINGET_FONT_ID})...`);
    const result = spawnSync(
      'winget',
      ['install', '--id', WINGET_FONT_ID, '--accept-package-agreements', '--accept-source-agreements'],
      { stdio: 'inherit' }
    );
    if (result.error || result.status !== 0) {
      log('winget install failed — install manually from https://www.nerdfonts.com/font-downloads');
      process.exitCode = 1;
      return;
    }
    if (!fontInstalledWindows()) {
      log('winget reported success but font files not found — check the install.');
      process.exitCode = 1;
      return;
    }
    log('JetBrainsMono Nerd Font installed.');
  } else {
    // Non-Windows: no auto-install; keep setup passive on the nuc/macOS.
    log(
      'Font check skipped on this platform. If Nerd Font glyphs look broken, install ' +
        'JetBrainsMono Nerd Font: `brew install --cask font-jetbrains-mono-nerd-font` (macOS) ' +
        'or download from https://www.nerdfonts.com/font-downloads (Linux).'
    );
  }
}

ensureFont();

fs.copyFileSync(SRC, DEST);
log(`Copied wezterm.lua -> ${DEST}`);
log('Done. WezTerm auto-reloads the config; open windows pick it up immediately.');
