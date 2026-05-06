# Testing Rules

Operational rules for tests. The principle (logic modules get real tests; boundary impls get conformance + mocks; tests are part of done) lives in your `docs/STANDARDS.md`; this file is the implementation contract — when, in what order, and to what shape.

The principle:

- **There are three testing regimes, not one.** Trying to apply a single discipline (strict TDD, or "tests after, as the shape of done") to every module is what produces both bloat and drift. Pick the regime per module class.
- **The regime is a property of the module, not of the developer.** A logic module is in the test-first regime even if you'd rather skip it; a UI render test is in the tests-as-shape-of-done regime even if you'd rather TDD it. The classification stays stable across PRs so reviewers can read the test file and know what to expect.
- **Tests document the contract.** A test that exists only to push coverage up by one percent has negative value — it adds maintenance weight without adding signal. Every test must answer "what would a future maintainer be wrong about without this?"

## Three regimes

### 1. Test-first (TDD) — required for logic modules

**Required for**: any module whose value is in its decisions, computations, or state transitions, where the implementation has interesting paths a reviewer can't verify by inspection.

Typical examples:

- Pure-function business logic (calculations, scoring, ranking, allocation, prioritisation)
- State machines and decision modules
- Schema/validation modules
- Persistence/retrieval logic that ranks or filters
- Internal sidecar logic (state machines, parsing, scoring)

**Workflow**:

1. Read the issue's `## Test plan` section (rough-in produces this; one named test per acceptance criterion).
2. Scaffold every named test as a failing test before any implementation lands. The exact form depends on your test runner — anything that fails red on a placeholder body is fine. Examples:

   ```elixir
   # ExUnit
   test "fits within 2048 tokens with all sections present" do
     flunk("not implemented")
   end
   ```

   ```python
   # pytest
   def test_chunks_at_sentence_boundaries() -> None:
       pytest.fail("not implemented")
   ```

   ```javascript
   // Vitest / Jest
   test("retries up to 3 times on transient errors", () => {
     throw new Error("not implemented");
   });
   ```

3. Run the test runner and confirm the new tests fail red.
4. Implement to green, one test at a time. Resist implementing past the next failing test — that's how TDD's documenting-the-design value gets lost.
5. Refactor while green. Your project's `check` task (whatever runs lint + typecheck + test) is the gate; passing it is non-negotiable before the simplify pass.

**Why TDD here**: the test is the spec. When the test name is quotable verbatim from the acceptance criterion, the rough-in spec, the test file, and the implementation all stay in sync — and a future maintainer reading the test runner's trace output sees the contract written in the same words the issue body uses.

### 2. Conformance-first — required for boundary adapters

**Required for**: any module that implements a behaviour/interface/trait/protocol with multiple impls (real + mock, or per-backend), or that sits at an external-process / HTTP / RPC / hardware boundary.

Typical examples:

- LLM backend adapters (real provider impl + mock; or one impl per provider)
- Hardware driver adapters (real driver + mock)
- External-service clients (real + mock or stub)
- Sidecar / external-process adapters
- Integration surfaces with multiple targets (e.g., dashboard + alternative consumer)

**Workflow**:

1. **Define the behaviour/interface first** — type declarations and signatures. This is the test target before any impl exists.
2. **Write the conformance test before the second impl** — a single test (or test loop) that enumerates every callback/method on every impl and proves they all conform to the contract. The test fails the moment either impl drifts.
3. **Write the shim dispatch test for both `:ok` and `:error` paths** — prove that the configurable indirection (whatever picks which impl runs at runtime) actually routes through the configured impl. Without explicit per-test expectations, a refactor that bypassed the configured impl could slip through because the mock returns the same shape as the real impl.
4. **Per-impl smoke** — at minimum, prove each impl returns canonical shapes. Real-driver impls typically start as placeholder/scaffolded smoke and upgrade to mock-backed coverage of real boundary calls in a follow-up.

**Why conformance-first here**: the contract *is* the test. A new behaviour without a conformance test is a behaviour you'll find drifting between impls in six months. Whatever your language's mocking story is (Mox, sinon, mockito, etc.), the conformance loop is what makes the abstraction real.

### 3. Tests-as-shape-of-done — UI, integration, and rehearsal

**Required for**: surfaces where the markup or wiring *is* the implementation, where writing tests before the code exists creates friction without payoff.

Typical examples:

- UI render tests (web framework views, component snapshot/render assertions)
- End-to-end integration tests with mocked boundaries (write the pipeline, then assert on observable telemetry/output)
- Hardware-on-real-device rehearsal tests (only run on the target; the scaffolding has to exist before assertions are useful)
- Dashboard / operator-console interaction tests

**Workflow**:

1. Build the surface to a working-state minimum.
2. Write tests that pin the user-visible behavior (or operator-visible behavior, for dashboards).
3. Add a regression test for any bug found during build that wasn't caught by step 2.
4. Iterate.

**Why not TDD here**: the contract is "the page renders correctly" or "the round-trip completes," and either the implementation is wrong (test fails for the right reason) or the test setup is wrong (test fails for the wrong reason and you waste an hour). The signal-to-noise ratio of test-first on these surfaces is poor enough that the discipline costs more than it saves.

## Test naming — quotable from the spec

Across all three regimes, the test name should be quotable verbatim from the acceptance criterion or contract it satisfies. Use whatever idiomatic test-name shape your runner expects, but make the name a declarative statement of the behaviour:

```elixir
# ExUnit
describe "PromptBudget.allocate/2" do
  test "fits within 2048 tokens with all sections present" do
    # ...
  end

  test "drops oldest few-shot examples first when overflowing" do
    # ...
  end
end
```

```python
# pytest
def test_chunks_at_sentence_boundaries() -> None:
    ...

def test_drops_chunks_smaller_than_min_chunk_ms() -> None:
    ...
```

```javascript
// Vitest / Jest
describe("RateLimiter", () => {
  test("rejects requests above the per-minute cap", () => { /* ... */ });
});
```

The mapping is:

- One acceptance criterion → one test name (rephrased from imperative spec to declarative test)
- The rough-in `## Test plan` section names them; the implementer writes them as failing tests on day one
- A reviewer reading the test runner's trace output sees the contract in the same words the issue body uses

## Async tests are the default

Tests should run in parallel by default unless they mutate shared global state (env vars, named processes, the database without a per-test sandbox, file-system fixtures that aren't isolated). Sequential-only tests are a tax on the suite — pay it deliberately, not by default. Most modern test runners offer per-test isolation primitives (sandboxed DB connections, per-test temp dirs, mock context isolation); use them.

## Coverage — measured, not gated

Track coverage in CI and surface deltas in PR review, but do not gate on a percentage threshold. Coverage *delta* is a review concern when a logic module drops without explicit reason — surfaced by your PR-review tooling in the pre-PR sweep.

## Anti-patterns

### ❌ Post-hoc TDD

```elixir
# Wrote the implementation, then wrote the test that "tests" it
test "computes the right answer" do
  assert MyModule.calc(@input) == @result_from_repl
end
```

The test was written knowing the answer. It pins the current behavior, not the contract — and the next refactor that produces a different-but-equally-correct output will fail it for no reason. Rewrite to assert against properties, not snapshots: *"total fits within budget,"* *"required fields always present,"* *"oldest entry dropped first."*

### ❌ Coverage-driven test bloat

```python
def test_function_returns():
    assert my_module.calc(input) is not None
```

This adds a covered line to the report and zero signal to the suite. Delete it. The shape-of-the-output assertions in the real test cover this implicitly; if they don't, the test plan is wrong.

### ❌ Skipping conformance tests because "there's only one impl"

The conformance shape is what makes a behaviour real. A behaviour with one impl and no conformance test is a behaviour that's about to gain a second impl that drifts. Write the conformance loop the moment the behaviour is declared, even if it iterates over `[OnlyImpl]` for now.

### ❌ TDD on UI render tests

```elixir
# Before the LiveView exists
test "shows the conversation transcript" do
  {:ok, _view, html} = live(conn, "/")
  assert html =~ "transcript"
end
```

The view doesn't exist; the test fails for "module not loaded" reasons; you build the view; the test passes; you didn't learn anything from the failing-then-passing cycle that you wouldn't have learned by building the view and then writing the assertion. Friction without payoff. Build, then assert.

### ❌ Per-tick assertions on high-frequency loops

If your project has a high-frequency loop (60Hz body loop, audio buffer pump, render tick), asserting on per-tick state in a test introduces flakiness (timing-dependent) and noise (assertion churn on every tick refactor). Test the *decision* function directly with synthetic state input; assert telemetry events for whole-loop behavior.

### ❌ Snapshot tests as acceptance

```elixir
assert PromptAssembler.assemble(@persona, @memory) == File.read!("snapshot.txt")
```

A snapshot pins one specific output. The contract is usually a property ("the assembled prompt has the persona base, modifiers in order, retrieved memory inlined, total under 2048 tokens"); assert *that*, not the snapshot. Snapshots are useful for content where the bytes themselves are the contract (rendered SVG, generated code); not for prose-shaped output where minor revisions break tests for no reason.

## Quick reference

| Module class | Regime | Order | Pattern |
|---|---|---|---|
| Logic (pure functions, decision modules, state machines) | Test-first (TDD) | Tests fail red → implement to green → refactor | One named test per acceptance criterion; quotable from rough-in spec |
| Behaviour adapters (driver/port modules, external-service backends, hardware/sidecar interfaces) | Conformance-first | Behaviour declared → conformance loop → shim dispatch (`:ok` + `:error`) → impl | Enumerate every callback across every impl; explicit per-test expectations for the shim |
| UI render | Tests-as-shape-of-done | Build view → assert against render API | Render assertions, interaction assertions, regression tests for found bugs |
| End-to-end integration | Tests-as-shape-of-done | Wire pipeline with mocked boundaries → assert telemetry | Mocked external services, assert turn/transaction telemetry |
| Hardware-on-real-device rehearsal | Tests-as-shape-of-done | Tagged for target-only execution | Mock-backed in CI; real-hardware-backed manually |
| High-frequency loop tick | Telemetry assertions only | n/a | Assert telemetry event shape; never per-tick state |

## Where the regimes meet

- **A logic module accessed via a behaviour** gets **both**: TDD on its internal logic + conformance test that it implements the behaviour callbacks. The two test files coexist; one file per concern.
- **A UI surface that displays computed state** gets **shape-of-done** for the rendering and **TDD** for the state-computation function the view reads. Don't put the computation logic inside the view module — extract to a logic module so it gets the right regime.
- **A sidecar with non-trivial internal state** gets **conformance** at the IPC/RPC boundary and **TDD** internally inside the sidecar. Both test files exist; one in the host language's test tree, one alongside the sidecar in its own language's test layout.

## When to update this file

This rules file is load-bearing once any logic-regime, conformance-regime, or shape-of-done modules begin shipping. Update it when:

- A new module class emerges that doesn't fit the three regimes (e.g., property-based tests for grammar emission, eval-driven tests for LLM critic verdicts) — add a fourth regime with the same shape (when, examples, workflow, why)
- A new boundary type is introduced — add it to the conformance-first examples list
- A specific anti-pattern recurs in PRs — add it under § Anti-patterns with a one-line "what to do instead"

The corresponding entry in `docs/STANDARDS.md` § Testing philosophy points here for the operational detail; that file states the principle, this file states the contract.
