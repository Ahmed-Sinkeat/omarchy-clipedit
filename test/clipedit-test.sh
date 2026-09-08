#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
ROOT="$ROOT" node <<'JS'
const path = require('path')
const root = process.env.ROOT
const clipEdit = require(path.join(root, 'ClipEditModel.js'))

function assert(condition, description, detail) {
  if (condition) {
    console.log(`ok - ${description}`)
    return
  }

  if (detail) console.error(detail)
  console.error(`not ok - ${description}`)
  process.exit(1)
}

function processAdapter() {
  return {
    payload: '',
    running: false,
    stdinEnabled: false,
    writes: [],
    write(value) { this.writes.push(value) }
  }
}

const adapter = processAdapter()

assert(clipEdit.startCopy(adapter, 'first'), 'first copy starts')
assert(
  adapter.payload === 'first' && adapter.stdinEnabled && adapter.running,
  'copy starts with its complete payload and stdin open'
)

clipEdit.writePendingCopy(adapter)
assert(
  adapter.writes.length === 1 && adapter.writes[0] === 'first' && !adapter.stdinEnabled,
  'started process writes the payload and closes stdin'
)

adapter.running = false
assert(clipEdit.startCopy(adapter, 'second'), 'second copy starts on the same process adapter')
assert(
  adapter.payload === 'second' && adapter.stdinEnabled && adapter.running,
  'second copy reopens stdin before starting'
)

const emptyProcess = processAdapter()
assert(!clipEdit.startCopy(emptyProcess, ''), 'empty text is rejected')
assert(
  emptyProcess.payload === '' && !emptyProcess.stdinEnabled && !emptyProcess.running,
  'empty text leaves the copy process untouched'
)

const busyProcess = processAdapter()
busyProcess.running = true
assert(!clipEdit.startCopy(busyProcess, 'next'), 'a rapid save cannot replace an in-flight payload')
JS
