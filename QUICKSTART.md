# Quick Start Guide - Trading Engine Parser

## 5-Minute Setup

### 1. Build the System

```bash
# Using Make (easiest)
make

# Or using rebar3
rebar3 compile
```

### 2. Start Erlang Shell

```bash
# Using Make
make repl

# Or manually
erl -pa src
```

### 3. Run Your First Command

```erlang
% Start the engine
trading_engine:start().

% Execute a simple command
trading_engine:execute("buy 9000 shares of GOOG.").
% Output: {ok, {buy, 9000, 'GOOG'}}

% Execute a conditional command
trading_engine:execute("buy 9000 shares of GOOG when price is less than 500.").
% Output: {ok, {buy, 9000, 'GOOG', {price_compare, less, 500}}}
```

## Common Commands

### Basic Trading

```erlang
trading_engine:execute("buy 100 shares of AAPL.").
trading_engine:execute("sell 50 shares of MSFT.").
trading_engine:execute("buy GOOG.").  % Buy 1 share
```

### Conditional Trading

```erlang
trading_engine:execute("buy 100 shares of AAPL when price is less than 150.").
trading_engine:execute("sell 50 shares of MSFT when price is greater than 200.").
trading_engine:execute("buy 100 shares of TSLA when price below 200.").
```

### Complex Conditions

```erlang
trading_engine:execute("buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000.").
trading_engine:execute("sell 500 shares of AAPL when price is greater than 150 or volume less than 500000.").
```

## Evaluate Conditions

```erlang
% Define market data
MarketData = #{price => 450, volume => 2000000}.

% Evaluate a condition
trading_engine:evaluate({price_compare, less, 500}, MarketData).
% Output: true

% Evaluate a complex condition
trading_engine:evaluate(
    {logic, and,
        {price_compare, less, 500},
        {compare, greater, volume, 1000000}
    },
    MarketData
).
% Output: true
```

## Run Demos

```erlang
% Run all demos
trading_demo:run().

% Run examples
trading_examples:run().

% Run tests
trading_parser_tests:run_all().
```

## Integration Example

```erlang
% Start integration
trading_integration:start().

% Create instrument from command
trading_integration:execute_trading_command("buy 9000 shares of GOOG when price is less than 500.").

% Evaluate command against market data
trading_integration:evaluate_command(
    "buy 1000 shares of GOOG when price is less than 500.",
    #{price => 450, volume => 2000000}
).
% Output: {ok, true}
```

## Syntax Reference

| Pattern | Example |
|---------|---------|
| Buy shares | `buy 100 shares of GOOG.` |
| Sell shares | `sell 50 shares of AAPL.` |
| Buy single | `buy GOOG.` |
| Price condition | `when price is less than 500.` |
| Volume condition | `when volume greater than 1000000.` |
| AND condition | `when price < 500 and volume > 1000000.` |
| OR condition | `when price > 150 or volume < 500000.` |

## Next Steps

- Read [PARSER_README.md](PARSER_README.md) for detailed documentation
- Read [TRADING_ENGINE_GUIDE.md](TRADING_ENGINE_GUIDE.md) for complete guide
- Explore the source code in `src/` directory
- Run the examples in `examples/` directory