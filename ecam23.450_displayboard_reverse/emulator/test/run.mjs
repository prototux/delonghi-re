// Headless test runner: node test/run.mjs [scenario,...]
// (browser alternative: serve the repo and open test/run.html)
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { runScenarios } from './scenarios.js';

const dir = fileURLToPath(new URL('../../../files/machines/ECAM_23.450/', import.meta.url));
const fw = readFileSync(dir + 'display_board_5513220041_v30_firmware.bin');
const ee = readFileSync(dir + 'display_board_5513220041_v30_eeprom.bin');
const pbImage = new Uint8Array(readFileSync(dir + 'power_board_unknown_v1.0_firmware.bin'));
const only = process.argv[2]?.split(',');
const fails = await runScenarios(new Uint8Array(fw), new Uint8Array(ee), s => console.log(s), { only, pbImage });
process.exit(fails ? 1 : 0);
