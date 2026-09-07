// Shared loader for the stub harnesses: reads a workflow script, evaluates its `export const meta`
// literal as an object (with or without a trailing semicolon) and wraps the body as the async function
// the runtime would call with (args, agent, parallel, log, phase). The only sources ever loaded are the
// repo's own workflow scripts — first-party code, never an input.
import { readFileSync } from "node:fs";

const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;

export function loadWorkflow(url) {
  const src = readFileSync(url, "utf8");
  const m = src.match(/^export const meta = (\{[\s\S]*?\n\});?\n/m);
  if (!m) throw new Error(`${url}: must open with \`export const meta = { … }\``);
  const meta = new Function(`return (${m[1]});`)();
  const body = src.slice(m.index + m[0].length);
  return { meta, body, run: new AsyncFunction("args", "agent", "parallel", "log", "phase", body) };
}
