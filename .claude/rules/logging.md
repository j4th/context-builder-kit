# Logging Rules

Operational rules for structured logging. Your `docs/STANDARDS.md` establishes the principle; this file is the implementation contract. When writing or modifying logging code, follow these rules — adapted to whatever logging stack your project uses.

## Pick one structured logger per language; don't mix

Whatever languages your project uses, pick a structured-logging library per language and stay with it. Don't add a second logger because a new module "needs" something different. Examples of common single-library choices (your project picks one per language during blueprint and records it in `docs/ARCHITECTURE.md`):

- **Elixir**: built-in `Logger` (with a JSON formatter at the OTP `:logger` level) plus `:telemetry` for boundary events
- **Python**: `structlog` (with stdout JSON output, ingested by the host language if running as a sidecar)
- **Node / TypeScript**: `pino` or similar JSON-first logger
- **Go**: `slog` (stdlib) or `zerolog`
- **Rust**: `tracing` with a JSON formatting layer

Whichever you pick, **don't fall back to `print` / stdout / `console.log`** for anything that should ship to the log surface. Those calls escape the structured pipeline.

## Correlation IDs

The load-bearing concept. Every user-utterance-to-response cycle (or request, or transaction) is a logical unit with a unique correlation ID. Every log line generated during that unit — including in any sidecar process — carries the correlation ID.

**Pick UUID v7** (or a similar time-ordered, sortable, globally unique scheme) for correlation IDs. Avoid ad-hoc IDs assembled from monotonic-time stitches or string concatenation — they're hard to sort and hard to compare across systems.

Common correlation-ID names you'll see in cascade projects (rename to fit your domain):

- `turn_id` — for the lifetime of one user-utterance-to-response cycle (e.g., voice agent turn)
- `request_id` — for the lifetime of one HTTP request or RPC call
- `perception_event_id` — for chains of perception events (face tracking sequence, sensor batch)
- `session_id` — for the lifetime of a logged-in user session
- `pilot_session_id` / `persona_session_id` — for the lifetime of an active persona configuration

### Propagation patterns by language

The language's logger should have a metadata-binding API that propagates across `await` / `Task.async` / async boundaries automatically. Use it.

**Elixir** — `Logger.metadata`:

```elixir
turn_id = MyApp.Logging.TurnId.uuid7()
Logger.metadata(turn_id: turn_id)
```

`Logger.metadata` is process-local but copies across `Task.async/1` and `Task.Supervisor.async/2` automatically. For child processes spawned via `GenServer.cast` or explicit `spawn`, **pass the correlation ID explicitly** as a message and have the child set its own metadata.

**Python** — `structlog.contextvars`:

```python
import structlog
from structlog.contextvars import bind_contextvars, clear_contextvars

def handle_request(payload: bytes, turn_id: str) -> str:
    bind_contextvars(turn_id=turn_id)
    try:
        log = structlog.get_logger()
        log.info("request_started", payload_len=len(payload))
        # ... work ...
        return result
    finally:
        clear_contextvars()
```

`bind_contextvars` is async-context-safe and propagates through `await` boundaries automatically.

**Other languages**: use the equivalent context-binding primitive (`pino`'s child loggers with bindings, `slog`'s context-attached handlers, `tracing`'s spans). The shape is the same: bind once at the entry point, every log call inside automatically inherits.

## Level taxonomy

| Level | Use for | Examples |
|---|---|---|
| `error` | Failures the operator needs to know about | External call timeout, sidecar/process crash, hardware comm failure, persistence error |
| `warn` | Unexpected but recovered | Retry succeeded after first failure, fallback path taken, cache miss in expected-hit case |
| `info` | State changes worth tracing through a request/turn | Turn started/ended, configuration change, tool/RPC call dispatched, session start |
| `debug` | Everything else | Per-frame state, per-tick loop body, individual sub-step traces, internal assembly steps |

**High-frequency loops never log at `info`.** A 60Hz loop logging at info would be 3,600 log lines per minute of "I'm still alive" — and the equivalent applies to any tick-driven, frame-driven, or hot-path code. Log loop *state changes* (mode transitions, lifecycle boundaries) at `info`; per-tick state at `debug` or via telemetry only (see next section).

## Telemetry — instrumentation, not narrative

Use a telemetry/metrics primitive at boundaries, not for general log content. Common shapes:

- **Elixir**: `:telemetry.execute/3` with event name, measurements, metadata
- **Python**: OpenTelemetry, Prometheus client, or framework-native instrumentation
- **Node**: OpenTelemetry, custom metrics emitter
- **Go**: OpenTelemetry, Prometheus client

Examples of correct telemetry events (sketched in Elixir's `:telemetry` shape; adapt to whatever your project uses):

- `[:myapp, :request, :start]` and `[:myapp, :request, :stop]` with measurements (`duration_ms`, `tokens_in`, `tokens_out`)
- `[:myapp, :llm, :call]` with measurements (`ttft_ms`, `total_ms`, `tokens`)
- `[:myapp, :persistence, :write]` with metadata (`table`, `op`) and measurements (`duration_ms`, `rows_affected`)
- `[:myapp, :tool, :dispatch]` with metadata (`tool_name`) and measurements (`duration_ms`)

Telemetry events are consumed by both the logger backend (auto-emit at info level with metadata) and any future metrics / tracing backend. **Don't write metrics-shaped log lines manually**; emit a telemetry event and let the handler decide.

## Anti-patterns

### ❌ String-interpolated context

```elixir
Logger.info("Tool call dispatched: #{tool_name} with args #{inspect(args)}")
```

This makes the log line unparseable as structured data. Tool name becomes part of the message, not a queryable field.

### ✅ Metadata pattern

```elixir
Logger.info("tool_dispatched", tool_name: tool_name, args: args)
```

The message is a stable identifier; values are metadata. Both the logger formatter (JSON output) and downstream log analysis can index by `tool_name`. Use the equivalent metadata-passing form in your language.

### ❌ Per-tick logging in a high-frequency loop

```elixir
# In a 60Hz body loop, called 60 times per second
def handle_info(:tick, state) do
  Logger.info("Tick #{state.tick_count}")  # NO
  ...
end
```

Even at `:debug`, this generates 3,600 lines per minute. Use telemetry instead and aggregate.

### ✅ Telemetry for high-frequency events

```elixir
def handle_info(:tick, state) do
  :telemetry.execute([:myapp, :body, :tick], %{tick_count: state.tick_count}, %{})
  ...
end
```

A telemetry handler can sample, aggregate to per-second metrics, or selectively log only on state transitions.

### ❌ Ad-hoc IDs

Building IDs from incrementing counters concatenated with timestamps. Hard to sort, hard to compare across systems.

### ✅ UUID v7

Time-ordered. Sortable. Cross-system-comparable. Use whatever UUID v7 primitive your language ecosystem provides (`:uuidv7` hex package on Elixir, `uuid7` libraries on Python/Node/Go, etc.).

## Sensitive data

Logging is observable by anyone with operator access. Apply these rules — adapted to whatever sensitive data your project actually handles:

- **Never log raw binary payloads** (audio buffers, image bytes, file uploads). Log byte counts and durations, not the bytes.
- **Never log full user-content transcripts at `info`.** Transcript content can be PII. Log at `debug` only, behind an explicit env flag (e.g., `MYAPP_LOG_TRANSCRIPTS=true`).
- **Never log full LLM prompts at `info`.** Persona-assembled prompts may contain user facts pulled from memory. Log prompt token count and structure summary; full prompt at `debug` behind an explicit env flag.
- **Never log raw secrets** (API keys, tokens, passwords, signing keys). Most logging libraries have a redaction primitive — use it.
- **Never log PII fields** (email, address, phone, real names) without scrubbing or hashing.

The kit's `logging-discipline-reviewer` agent (`.claude/agents/logging-discipline-reviewer.md`) is the runtime check for these rules at PR time.

## Sidecar / external-process log ingestion

If your project has external-process sidecars (Python sidecars under Snex, Rust sidecars under WASI, child processes via Port, etc.), the sidecars emit structured log lines on stdout/stderr and the host process ingests them.

Pattern:

1. The sidecar emits one JSON line per log event on stdout.
2. The host runs a dedicated log-bridge component that parses each line and re-emits via the host language's logger at the corresponding level, with sidecar identification (`sidecar: <name>`) and any included correlation IDs propagated to host-side metadata.
3. The bridge drops malformed lines at warning level to prevent log-poisoning.

The bridge is the only logging code in the host that takes external input. **It validates strictly.** Any change to the bridge needs explicit JSON parse error handling and missing-field handling.

## Quick reference

| What you want to log | How |
|---|---|
| State change in a turn/request | `Logger.info("descriptive_event_name", key: value, ...)` (or your language's equivalent metadata form) |
| Boundary with timing | Telemetry event with `name`, `measurements`, `metadata` |
| Recovered error | `Logger.warn("descriptive_event", error: reason, ...)` |
| Operator-visible failure | `Logger.error("descriptive_event", error: reason, ...)` |
| High-frequency loop state | Telemetry only; no `Logger` calls per tick |
| Cross-sidecar correlation | `turn_id` (or `request_id`, `perception_event_id`) in every log line |
| Sidecar JSON ingestion | Dedicated log-bridge per sidecar; do not bypass |
| New correlation ID type | Document it in this file; propagate via `Logger.metadata` (Elixir) and `bind_contextvars` (Python) and the equivalent in any other host language |
