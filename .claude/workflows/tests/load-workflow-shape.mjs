#!/usr/bin/env node
// Direct test of load-workflow.mjs: the meta literal loads with or without its trailing semicolon, the body
// runs as the async function the runtime would call, and a file without a meta literal fails loudly.
// Run: node .claude/workflows/tests/load-workflow-shape.mjs
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import assert from "node:assert/strict";
import { loadWorkflow } from "./load-workflow.mjs";

const dir = mkdtempSync(path.join(process.env.TMPDIR ?? tmpdir(), "load-workflow-"));
try {
  const withSemi = path.join(dir, "a.js");
  writeFileSync(withSemi, 'export const meta = {\n  name: "a",\n  phases: [{ title: "P" }],\n};\nlog("hi")\nreturn args.x + 1\n');
  const a = loadWorkflow(pathToFileURL(withSemi));
  assert.equal(a.meta.name, "a");
  const logs = [];
  assert.equal(await a.run({ x: 1 }, null, null, (m) => logs.push(m), () => {}), 2);
  assert.deepEqual(logs, ["hi"]);

  const noSemi = path.join(dir, "b.js");
  writeFileSync(noSemi, 'export const meta = {\n  name: "b",\n}\nreturn "body"\n');
  const b = loadWorkflow(pathToFileURL(noSemi));
  assert.equal(b.meta.name, "b");
  assert.equal(await b.run({}, null, null, () => {}, () => {}), "body");

  const noMeta = path.join(dir, "c.js");
  writeFileSync(noMeta, 'const x = 1\nreturn x\n');
  assert.throws(() => loadWorkflow(pathToFileURL(noMeta)), /must open with `export const meta/);
  console.log("load-workflow-shape: 3 cases ok");
} finally {
  rmSync(dir, { recursive: true, force: true });
}
