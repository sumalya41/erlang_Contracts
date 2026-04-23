# Test Documentation

## Overview

The project includes **38 comprehensive test cases** organized into 5 test suites covering all modules with unit and integration tests.

## Test Suites Summary

| Suite | Tests | Focus |
|-------|-------|-------|
| `barrier_logic_SUITE` | 6 | Barrier state transitions |
| `instruments_SUITE` | 9 | DSL primitives and transformations |
| `instrument_server_SUITE` | 8 | Contract evaluation engine |
| `instrument_custom_SUITE` | 10 | Contract constructors |
| `integration_SUITE` | 5 | End-to-end workflows |
| **TOTAL** | **38** | **Complete system coverage** |

## Detailed Test Cases

### barrier_logic_SUITE (6 tests)

Tests the barrier option state machine implementation.

#### 1. up_and_in_activation_test
- **Purpose**: Verify up-and-in barrier transitions to active when barrier is hit from below
- **Scenario**: Barrier at 110, price sequence 100 → 110 → 120
- **Expected**: State changes from dormant → active → active

#### 2. down_and_in_activation_test
- **Purpose**: Verify down-and-in barrier transitions to active when barrier is hit from above
- **Scenario**: Barrier at 90, price sequence 100 → 90 → 80
- **Expected**: State changes from dormant → active → active

#### 3. up_and_out_expiry_test
- **Purpose**: Verify up-and-out barrier expires when knocked-out from below
- **Scenario**: Start active, barrier 120, price sequence 100 → 120 → 100
- **Expected**: State changes from active → expired → expired (sticky)

#### 4. down_and_out_expiry_test
- **Purpose**: Verify down-and-out barrier expires when knocked-out from above
- **Scenario**: Start active, barrier 80, price sequence 100 → 80 → 100
- **Expected**: State changes from active → expired → expired

#### 5. no_transition_test
- **Purpose**: Verify no state change when conditions aren't met
- **Scenarios**:
  - Up-and-in dormant below barrier → stays dormant
  - Unknown barrier type → no transition
- **Expected**: State unchanged

#### 6. barrier_boundary_conditions_test
- **Purpose**: Test exact barrier level hits (edge cases)
- **Scenarios**:
  - Up-and-in with exact hit (100 ≥ 100)
  - Down-and-in with exact hit (100 ≤ 100)
  - Just below/above barriers
- **Expected**: Correct transitions at boundaries

### instruments_SUITE (9 tests)

Tests DSL primitives and transformations.

#### 1. terminal_observation_test
- **Purpose**: Verify terminal observation structure
- **Expected**: `{observe, {terminal, Asset}}`

#### 2. path_observation_test
- **Purpose**: Verify path observation for lookback options
- **Expected**: `{observe, {path, Asset}}`

#### 3. constant_test
- **Purpose**: Verify constant wrapping
- **Expected**: `{constant, Value}` for various values

#### 4. binary_transformation_test
- **Purpose**: Verify binary (digital) transformation
- **Expected**: `{transform, {binary, K}, Observation}`

#### 5. diff_transformation_test
- **Purpose**: Verify spread/exchange transformation
- **Expected**: `{transform, diff, {observe, {multi, [A, B]}}}`

#### 6. max_of_transformation_test
- **Purpose**: Verify max transformation (rainbow option)
- **Expected**: `{transform, max_of, {observe, {multi, Assets}}}`

#### 7. min_of_transformation_test
- **Purpose**: Verify min transformation
- **Expected**: `{transform, min_of, {observe, {multi, Assets}}}`

#### 8. add_composition_test
- **Purpose**: Verify contract addition composition
- **Expected**: `{combine, add, C1, C2}`

#### 9. choice_composition_test
- **Purpose**: Verify choice (max) composition
- **Expected**: `{choice, C1, C2}`

### instrument_server_SUITE (8 tests)

Tests the contract evaluation engine (core logic).

#### 1. server_init_test
- **Purpose**: Verify gen_server initialization
- **Checks**:
  - Path preservation when provided
  - Path initialization to `[]` when not provided
- **Expected**: Both paths handled correctly

#### 2. digital_option_test
- **Purpose**: Evaluate digital option payoff (1 if S > K, else 0)
- **Scenarios**:
  - S = 120, K = 100 → 1 (in-the-money)
  - S = 80, K = 100 → 0 (out-of-the-money)
- **Expected**: Correct binary payoff

#### 3. exchange_option_test
- **Purpose**: Evaluate exchange option: max(A - B, 0)
- **Scenarios**:
  - A = 100, B = 90 → 10
  - A = 80, B = 100 → 0
- **Expected**: Correct spread payoff

#### 4. rainbow_option_test
- **Purpose**: Evaluate rainbow (best-of) option: max([a, b, c])
- **Scenario**: Prices 100, 80, 120
- **Expected**: 120

#### 5. barrier_option_test
- **Purpose**: Evaluate barrier option with path dependency
- **Scenarios**:
  - Barrier hit (path max ≥ 110), payoff 120 → 120
  - Barrier not hit (path max < 110) → 0
- **Expected**: Correct barrier knock-in logic

#### 6. constant_value_test
- **Purpose**: Verify constant contracts return same value
- **Expected**: Constant value returned regardless of environment

#### 7. combined_option_test
- **Purpose**: Evaluate composed contracts
- **Scenarios**:
  - Addition: 100 + 50 = 150
  - Choice: max(100, 80) = 100
- **Expected**: Correct compositions

#### 8. path_handling_test
- **Purpose**: Verify market updates accumulate in path
- **Scenario**: Two price updates (110, 120)
- **Expected**: Path = [120, 110] (LIFO)

### instrument_custom_SUITE (10 tests)

Tests contract constructor functions.

#### 1. digital_option_creation_test
- **Purpose**: Verify digital option instantiation
- **Checks**:
  - Valid PID returned
  - Contract structure correct
- **Expected**: `digital(stock, 100)` creates proper server

#### 2. exchange_option_creation_test
- **Purpose**: Verify exchange option instantiation
- **Expected**: `{transform, diff, {observe, {multi, [A, B]}}}`

#### 3. rainbow_option_creation_test
- **Purpose**: Verify rainbow option instantiation
- **Expected**: `{transform, max_of, {observe, {multi, Assets}}}`

#### 4. barrier_option_creation_test
- **Purpose**: Verify barrier option instantiation
- **Expected**: `{barrier, Type, Level, Contract}`

#### 5. forward_start_creation_test
- **Purpose**: Verify forward start option instantiation
- **Expected**: `{'when', {'after', T}, Contract}`

#### 6. chooser_option_creation_test
- **Purpose**: Verify chooser option instantiation
- **Expected**: `{'when', {'at', T}, {choice, Call, Put}}`

#### 7. lookback_option_creation_test
- **Purpose**: Verify lookback option instantiation
- **Expected**: `{observe, {path_max, Asset}}`

#### 8-10. Swap Creation Tests
- **Purpose**: Verify swap contracts instantiate
- Tests for:
  - Vanilla IRS
  - Equity swap
  - Volatility swap
- **Expected**: Valid PIDs created

### integration_SUITE (5 tests)

End-to-end workflow tests combining multiple components.

#### 1. end_to_end_digital_option_test
- **Workflow**: Create digital → evaluate in 3 scenarios
- **Scenarios**:
  - In-the-money (S > K): 1
  - Out-of-the-money (S < K): 0
  - At-the-money (S = K): 0
- **Tests**: Full creation and evaluation pipeline

#### 2. end_to_end_exchange_option_test
- **Workflow**: Create exchange → evaluate spread payoff
- **Scenarios**:
  - A > B: payoff = A - B = 10
  - A < B: payoff = 0
  - A = B: payoff = 0
- **Tests**: Multiple asset pricing

#### 3. end_to_end_rainbow_option_test
- **Workflow**: Create rainbow → evaluate 3 scenarios
- **Scenarios**: Different assets are highest (a, b, c)
- **Tests**: Multi-asset maximum selection

#### 4. end_to_end_barrier_option_test
- **Workflow**: Create barrier → evaluate with path dependency
- **Scenarios**:
  - Barrier hit, payoff in-the-money: 1
  - Barrier not hit: 0
  - Barrier hit, payoff out-of-the-money: 0
- **Tests**: Path-dependent option logic

#### 5. complex_derivative_test
- **Workflow**: Build complex composite (choice between digital and exchange)
- **Scenarios**:
  - Digital payoff (1) vs Exchange payoff (10) → max(1,10) = 10
  - Both payoffs 1 → max(1,1) = 1
  - Digital 0 vs Exchange 10 → max(0,10) = 10
- **Tests**: Contract composition and evaluation

## Running Tests

```bash
# All tests
rebar3 eunit

# Specific suite
rebar3 eunit --module=barrier_logic_SUITE

# With coverage
rebar3 cover

# Verbose output
rebar3 eunit --verbose
```

## Test Coverage Areas

✅ **State Machines**: Barrier transitions (6 tests)
✅ **DSL Syntax**: Contract construction (9 tests)  
✅ **Evaluation Engine**: Contract valuation (8 tests)
✅ **Constructors**: High-level API (10 tests)
✅ **Integration**: End-to-end workflows (5 tests)

## Edge Cases Covered

- ✅ Barrier exact hits
- ✅ Path-dependent evaluation  
- ✅ Boundary conditions
- ✅ State persistence
- ✅ Multi-asset operations
- ✅ Composite contracts
- ✅ Zero/negative payoffs
- ✅ Complex compositions

## Key Testing Principles

1. **Isolation**: Each test is independent
2. **Clarity**: Test names describe what's being tested
3. **Completeness**: Happy path + edge cases + error handling
4. **Maintainability**: Tests are organized by module
5. **Documentation**: Each test has clear comments
