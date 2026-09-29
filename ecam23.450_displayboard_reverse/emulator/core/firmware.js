// Firmware image loaders: raw .bin (little endian words, as dumped by a
// programmer, config word at word 0x2007) and Intel HEX (XC8 output) for the
// PIC16F916, and Intel HEX -> programmer image for the PIC18F4525.

export function parseBin(bytes) {
  const words = new Uint16Array(0x2000).fill(0x3fff);
  const n = Math.min(0x2000, bytes.length >> 1);
  for (let i = 0; i < n; i++) words[i] = bytes[2 * i] | (bytes[2 * i + 1] << 8);
  let config;
  if (bytes.length >= 0x2008 * 2) config = bytes[0x2007 * 2] | (bytes[0x2007 * 2 + 1] << 8);
  return { words, config };
}

export function parseHex(text) {
  const mem = new Map();
  let base = 0;
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line.startsWith(':')) continue;
    const b = line.slice(1).match(/../g).map(x => parseInt(x, 16));
    const [len, ah, al, type] = b;
    const data = b.slice(4, 4 + len);
    if (type === 0) data.forEach((v, i) => mem.set(base + ((ah << 8) | al) + i, v));
    else if (type === 4) base = ((data[0] << 8) | data[1]) << 16;
    else if (type === 1) break;
  }
  const words = new Uint16Array(0x2000).fill(0x3fff);
  let config;
  for (const [addr, v] of mem) {
    const w = addr >> 1;
    const cur = w < 0x2000 ? words[w] : (config ?? 0x3fff);
    const nv = (addr & 1) ? ((cur & 0x00ff) | (v << 8)) : ((cur & 0xff00) | v);
    if (w < 0x2000) words[w] = nv & 0x3fff; else if (w === 0x2007) config = nv & 0x3fff;
  }
  return { words, config };
}

export function parseFirmware(bytes, name = '') {
  const isHex = name.toLowerCase().endsWith('.hex') || bytes[0] === 0x3a;  // ':'
  return isHex ? parseHex(new TextDecoder().decode(bytes)) : parseBin(bytes);
}

// PIC18: Intel HEX (byte addresses) to the programmer dump layout that
// PIC18F4525.loadImage() takes: flash at 0, config at 0x300000, EEPROM at
// 0xF00000. Unprogrammed flash and EEPROM read 0xFF. A raw dump is returned
// as is.
export function pic18Image(bytes, name = '') {
  const isHex = name.toLowerCase().endsWith('.hex') || bytes[0] === 0x3a;
  if (!isHex) return bytes;
  const img = new Uint8Array(0xF00400).fill(0xff);
  img.fill(0x00, 0x300000, 0x30000E);         // config bytes not in the file stay 0
  let base = 0;
  for (const raw of new TextDecoder().decode(bytes).split(/\r?\n/)) {
    const line = raw.trim();
    if (!line.startsWith(':')) continue;
    const b = line.slice(1).match(/../g).map(x => parseInt(x, 16));
    const [len, ah, al, type] = b;
    const data = b.slice(4, 4 + len);
    if (type === 0) data.forEach((v, i) => { const a = base + ((ah << 8) | al) + i; if (a < img.length) img[a] = v; });
    else if (type === 4) base = ((data[0] << 8) | data[1]) << 16;
    else if (type === 1) break;
  }
  return img;
}
