# Erlang Contracts DSL - rebar3 Project

A financial derivatives DSL (Domain Specific Language) in Erlang for composable option pricing and contract evaluation. Inspired by Simon Peyton Jones's composable contracts framework.

## Project Structure

```
erlang_Contracts/
├── rebar.config              # Rebar3 configuration
├── src/
│   ├── instruments.app.src   # Application resource file
│   ├── barrier_logic.erl     # Barrier option state machines
│   ├── instruments.erl       # DSL primitives and helpers
│   ├── instrument_server.erl # Contract evaluation engine (gen_server)
│   ├── instrument_custom.erl # Contract constructors (DSL builders)
│   ├── instrument_sup.erl    # Supervisor for instrument servers
│   └── main.erl              # Example usage
├── test/
│   ├── barrier_logic_SUITE.erl      # Barrier logic tests
│   ├── instruments_SUITE.erl        # DSL primitives tests
│   ├── instrument_server_SUITE.erl  # Contract evaluation tests
│   ├── instrument_custom_SUITE.erl  # Contract constructor tests
│   └── integration_SUITE.erl        # End-to-end integration tests
├── ebin/                     # Compiled BEAM files (generated)
└── README.md                 # This file
```

## Modules Overview

### barrier_logic.erl
Implements barrier option state transitions:
- **up_and_in**: Becomes active when price ≥ barrier
- **down_and_in**: Becomes active when price ≤ barrier
- **up_and_out**: Expires when price ≥ barrier
- **down_and_out**: Expires when price ≤ barrier

### instruments.erl
Core DSL primitives:
- **Observations**: `terminal/1`, `path/1` - Extract values from environment
- **Transformations**: `binary/2`, `diff/2`, `max_of/1`, `min_of/1`
- **Compositions**: `add/2`, `choice/2`

### instrument_server.erl
OTP-compliant gen_server implementing the contract evaluation engine:
- `value/2` - Evaluate contract given an environment
- `risk/2` - Calculate risk metrics (placeholder)
- `describe/1` - Inspect contract state
- `update_price/2` - Market price updates for path-dependent options

### instrument_custom.erl
High-level contract constructors using the DSL:
- **Options**: `digital/2`, `exchange/2`, `rainbow_best/1`, `lookback/1`, `chooser/3`, `forward_start/2`
- **Derivatives**: `barrier/3`
- **Swaps**: `vanilla_irs/2`, `equity_swap/2`, `vol_swap/2`

### instrument_sup.erl
Supervisor managing instrument server workers with `simple_one_for_one` strategy.

## Quick Start

### Prerequisites
- Erlang/OTP 21+ with rebar3 installed

### Build the Project

```bash
cd erlang_Contracts
rebar3 compile
```

### Run Tests

```bash
# Run all tests
rebar3 eunit

# Run specific test suite
rebar3 eunit --module=barrier_logic_SUITE
rebar3 eunit --module=instruments_SUITE
rebar3 eunit --module=instrument_server_SUITE
rebar3 eunit --module=instrument_custom_SUITE
rebar3 eunit --module=integration_SUITE

# Run with verbose output
rebar3 eunit --verbose

# Generate coverage report
rebar3 cover
```

### Run the Example

```bash
rebar3 shell
1> main:run().
Digital: 1
Exchange: 10
Rainbow: 130
Barrier: 1
ok
```

## Example Usage

```erlang
%% Start the system
instrument_custom:start(),

%% Define contracts using DSL
Digital = instrument_custom:digital(stock, 100),
Exchange = instrument_custom:exchange(a, b),
Rainbow = instrument_custom:rainbow_best([a, b, c]),

%% Create environment with market data
Env = #{
    time => terminal,
    {stock, terminal} => 120,
    {a, terminal} => 100,
    {b, terminal} => 90,
    {c, terminal} => 130,
    path => [80, 90, 110, 120]
},

%% Evaluate contracts
DigitalValue = instrument_server:value(Digital, Env),      %% 1
ExchangeValue = instrument_server:value(Exchange, Env),    %% 10
RainbowValue = instrument_server:value(Rainbow, Env),      %% 130

%% Barrier option with embedded contract
BarrierInner = {transform, {binary, 100}, {observe, {terminal, stock}}},
Barrier = instrument_custom:barrier(up_and_in, 110, BarrierInner),
BarrierValue = instrument_server:value(Barrier, Env).      %% 1
```

## Test Suites

### barrier_logic_SUITE
6 tests covering barrier state transitions:
- Up-and-in activation
- Down-and-in activation
- Up-and-out expiry
- Down-and-out expiry
- No-transition cases
- Boundary conditions (exact hits)

### instruments_SUITE  
9 tests for DSL primitives:
- Terminal observation
- Path observation
- Constants
- Binary transformations
- Diff transformations
- Max/min transformations
- Addition composition
- Choice composition

### instrument_server_SUITE
8 tests for contract evaluation:
- Server initialization
- Digital option payoff
- Exchange option payoff
- Rainbow option (best-of)
- Barrier option with path dependency
- Constant values
- Combined contracts
- Path updates via market data

### instrument_custom_SUITE
10 tests for contract constructors:
- Digital option creation
- Exchange option creation
- Rainbow option creation
- Barrier option creation
- Forward start option
- Chooser option
- Lookback option
- Vanilla IRS
- Equity swap
- Volatility swap

### integration_SUITE
5 end-to-end tests:
- Digital option full workflow
- Exchange option full workflow
- Rainbow option full workflow
- Barrier option full workflow
- Complex composite derivatives

## Key Features

✅ **Composable Contracts**: Build complex derivatives from simple primitives
✅ **DSL-Based**: Declarative contract specification
✅ **Path-Dependent**: Support for lookback and barrier options
✅ **Modular Architecture**: Clean separation between DSL, evaluation, and OTP infrastructure
✅ **Comprehensive Testing**: 38+ unit and integration tests
✅ **Production-Ready**: Uses OTP best practices

## Environment Maps

Contracts are evaluated using environment maps:

```erlang
Env = #{
    time => terminal,                    %% Time point
    {asset, terminal} => Price,          %% Terminal asset prices
    {asset, time} => Value,              %% Values at specific times
    path => [P1, P2, P3, ...],          %% Price path for path-dependent options
    %% Additional market data as needed
}
```

## Extending the DSL

To add new contract types:

1. **Add DSL constructor** in `instrument_custom.erl`
2. **Add evaluation clause** in `instrument_server.erl` `value_contract/2`
3. **Add tests** in appropriate `*_SUITE.erl` file

Example:

```erlang
%% instrument_custom.erl
my_new_option(Param) ->
    C = {my_new_type, Param},
    start_instrument(#{contract => C}).

%% instrument_server.erl
value_contract({my_new_type, Param}, Env) ->
    %% Implementation here
    SomeValue.

%% test/*_SUITE.erl
my_new_option_test() ->
    Pid = instrument_custom:my_new_option(param_value),
    Env = #{...},
    ExpectedValue = instrument_server:value(Pid, Env),
    %%assertions...
```

## Performance Considerations

- **Lazy Evaluation**: Contracts are evaluated on-demand with `value/2`
- **Process Per Contract**: Each contract gets its own gen_server for isolation
- **Path Management**: Paths are accumulated during market updates

## Future Enhancements

- Real-time market feeds integration
- Greeks calculation (delta, gamma, vega)
- Monte Carlo simulation
- More exotic derivatives (Asian, Cliquets, Variance swaps)
- Persistence layer for contract data

## License

Educational project based on SPJ's composable contracts framework.

## References

- Simon Peyton Jones - "Composable and Modular Financial Contracts"
- Erlang/OTP Documentation: http://erlang.org/doc/
- Rebar3: https://rebar3.org/
