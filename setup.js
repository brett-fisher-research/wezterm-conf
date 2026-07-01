#!/usr/bin/env node
// Idempotent WezTerm config setup. Safe to run repeatedly.
// Copies wezterm.lua to ~/.wezterm.lua, which WezTerm reads on every platform.

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');

const SRC = path.join(__dirname, 'wezterm.lua');
const DEST = path.join(os.homedir(), '.wezterm.lua');

function log(msg) {
  console.log(`[wezterm-conf] ${msg}`);
}

fs.copyFileSync(SRC, DEST);
log(`Copied wezterm.lua -> ${DEST}`);
log('Done. WezTerm auto-reloads the config; open windows pick it up immediately.');
