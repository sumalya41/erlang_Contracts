# Trading Engine Parser & Tokenizer - Complete Guide

## Overview

This trading engine provides a natural language interface for executing trading commands in your Erlang finance system. It uses `leex` for tokenization and `yecc` for parsing, integrated with your existing instrument DSL.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Natural Language Input                     │
│              "buy 9000 shares of GOOG when price < 500"      │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    trading_lexer.xrl                         │
│                    (Tokenizer - leex)                        │
│  Tokens: [{action, buy}, {integer, 9000}, {shares, ...}]    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   trading_parser.yrl                         │
│                    (Parser - yecc)                           │
│  AST: {command, {action, buy, 9000, 'GOOG'}, Condition}     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  trading_parser.erl                          │
│                    (Parser Interface)                        │
│  Compiles AST to executable contract                         │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   trading_engine.erl                         │
│                    (Execution Engine)                        │
│  Executes commands and evaluates conditions                 │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                trading_integration.erl                       │
│              (Instrument System Integration)                 │
│  Creates instruments from trading commands                   │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
erl_finance/
├── src/
│   ├── trading_lexer.xrl          # Lexer definition (leex)
│   ├── trading_parser.yrl         # Parser definition (yecc)
│   ├── trading_parser.erl         # Parser interface
│   ├── trading_engine.erl         # Execution engine
│   ├── trading_integration.erl    # Instrument integration
│   ├── trading_demo.erl           # Demo and examples
│   ├── trading_parser_tests.erl   # Test suite
│   ├── erl_finance_app.erl        # Application module
│   ├── erl_finance_sup.erl        # Supervisor
│   └── erl_finance.app.src        # Application resource file
├── examples/
│   └── trading_examples.erl       # Usage examples
├── rebar.config                   # Rebar3 configuration
├── Makefile                       # Build automation
├── PARSER_README.md               # Quick reference
└── TRADING_ENGINE_GUIDE.md        # This file
```

## Building the System

### Using Make (Recommended)

```bash
# Build everything
make

# Clean build artifacts
make clean

# Run demo
make demo

# Start REPL
make repl
```

### Using Rebar3

```bash
# Compile
rebar3 compile

# Run shell
rebar3 shell

# Run tests
rebar3 eunit
```

### Manual Build

```bash
# Generate lexer and parser
cd src
erlc trading_lexer.xrl
erlc trading_parser.yrl

# Compile modules
erlc *.erl
```

## Usage Guide

### 1. Basic Commands

```erlang
% Start the engine
trading_engine:start().

% Simple buy command
trading_engine:execute("buy 9000 shares of GOOG.").
% Output: {ok, {buy, 9000, 'GOOG'}}

% Simple sell command
trading_engine:execute("sell 500 shares of AAPL.").
% Output: {ok, {sell, 500, 'AAPL'}}

% Buy without "shares" keyword
trading_engine:execute("buy 100 of MSFT.").
% Output: {ok, {buy, 100, 'MSFT'}}

% Buy single share (default quantity)
trading_engine:execute("buy GOOG.").
% Output: {ok, {buy, 1, 'GOOG'}}
```

### 2. Conditional Commands

```erlang
% Buy when price is less than threshold
trading_engine:execute("buy 9000 shares of GOOG when price is less than 500.").
% Output: {ok, {buy, 9000, 'GOOG', {price_compare, less, 500}}}

% Sell when price is greater than threshold
trading_engine:execute("sell 100 shares of AAPL when price is greater than 150.").
% Output: {ok, {sell, 100, 'AAPL', {price_compare, greater, 150}}}

% Alternative syntax
trading_engine:execute("buy 500 shares of TSLA when price below 200.").
trading_engine:execute("sell 200 shares of AMZN when price above 3000.").
```

### 3. Complex Conditions

```erlang
% AND condition
trading_engine:execute("buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000.").
% Output: {ok, {buy, 1000, 'GOOG', {logic, and,
%     {price_compare, less, 500},
%     {compare, greater, volume, 1000000}
% }}}

% OR condition
trading_engine:execute("sell 500 shares of AAPL when price is greater than 150 or volume less than 500000.").
% Output: {ok, {sell, 500, 'AAPL', {logic, or,
%     {price_compare, greater, 150},
%     {compare, less, volume, 500000}
% }}}

% NOT condition
trading_engine:execute("buy 100 shares of MSFT when not price is less than 200.").
```

### 4. Condition Evaluation

```erlang
% Define market data
MarketData = #{price => 450, volume => 2000000}.

% Evaluate simple condition
Condition = {price_compare, less, 500},
trading_engine:evaluate(Condition, MarketData).
% Output: true

% Evaluate complex condition
Condition2 = {logic, and,
    {price_compare, less, 500},
    {compare, greater, volume, 1000000}
},
trading_engine:evaluate(Condition2, MarketData).
% Output: true

% Evaluate against different market data
MarketData2 = #{price => 550, volume => 2000000},
trading_engine:evaluate(Condition, MarketData2).
% Output: false
```

### 5. Integration with Instrument System

```erlang
% Start integration system
trading_integration:start().

% Create instrument from command
trading_integration:execute_trading_command("buy 9000 shares of GOOG when price is less than 500.").
% Output: {ok, {buy_instrument, 9000, 'GOOG', BarrierPid, Condition}}

% Evaluate command against market data
trading_integration:evaluate_command(
    "buy 1000 shares of GOOG when price is less than 500.",
    #{price => 450, volume => 2000000}
).
% Output: {ok, true}  % Condition met, order would execute
```

## Grammar Reference

### Actions

```
action ::= "buy" | "sell"
quantity ::= integer
symbol ::= identifier
```

### Action Clauses

```
action_clause ::= action quantity "shares" "of" symbol
                | action quantity "of" symbol
                | action symbol
```

### Conditions

```
condition ::= expression "compare" expression
            | expression "is" "compare" expression
            | expression "is" "compare" "than" expression
            | "price" "compare" expression
            | "price" "is" "compare" expression
            | "price" "is" "compare" "than" expression
            | condition "and" condition
            | condition "or" condition
            | "not" condition
```

### Comparison Operators

```
compare ::= "less" | "greater" | "above" | "below" | "at"
```

### Expressions

```
expression ::= identifier
             | integer
             | float
             | "(" expression ")"
```

## Supported Syntax Examples

| Command Type | Example | AST |
|-------------|---------|-----|
| Simple Buy | `buy 9000 shares of GOOG.` | `{buy, 9000, 'GOOG'}` |
| Simple Sell | `sell 500 shares of AAPL.` | `{sell, 500, 'AAPL'}` |
| Conditional Buy | `buy 9000 shares of GOOG when price < 500.` | `{buy, 9000, 'GOOG', {price_compare, less, 500}}` |
| Conditional Sell | `sell 100 shares of AAPL when price > 150.` | `{sell, 100, 'AAPL', {price_compare, greater, 150}}` |
| AND Condition | `buy 1000 shares of GOOG when price < 500 and volume > 1000000.` | `{buy, 1000, 'GOOG', {logic, and, ...}}` |
| OR Condition | `sell 500 shares of AAPL when price > 150 or volume < 500000.` | `{sell, 500, 'AAPL', {logic, or, ...}}` |

## Testing

### Run All Tests

```erlang
% In Erlang shell
trading_parser_tests:run_all().
```

### Run Demo

```erlang
% In Erlang shell
trading_demo:run().
```

### Run Examples

```erlang
% In Erlang shell
trading_examples:run().
```

## Extending the System

### Adding New Actions

1. Update `trading_lexer.xrl` to add new action tokens
2. Update `trading_parser.yrl` to add new action rules
3. Update `trading_engine.erl` to handle new actions

### Adding New Conditions

1. Update `trading_lexer.xrl` to add new condition tokens
2. Update `trading_parser.yrl` to add new condition rules
3. Update `trading_engine.erl` to evaluate new conditions

### Adding New Comparison Operators

1. Update `trading_lexer.xrl` to add new operator tokens
2. Update `trading_parser.yrl` to add new operator rules
3. Update `trading_engine.erl` to implement new comparison logic

## Integration with Existing System

The trading engine is designed to work seamlessly with your existing instrument system:

1. **Instrument Creation**: Use `trading_integration:execute_trading_command/1` to create instruments from natural language commands
2. **Condition Evaluation**: Use `trading_engine:evaluate/2` to evaluate conditions against market data
3. **Command Compilation**: Use `trading_parser:parse_and_compile/1` to compile commands to executable contracts

## Future Enhancements

- [ ] Support for limit orders
- [ ] Support for stop-loss orders
- [ ] Support for time-based conditions
- [ ] Support for portfolio-level commands
- [ ] Integration with real-time market data feeds
- [ ] Order book management
- [ ] Risk management integration
- [ ] Backtesting capabilities

## Troubleshooting

### Common Issues

**Issue**: Lexer generation fails
```
Solution: Ensure you have Erlang/OTP installed with leex support
```

**Issue**: Parser generation fails
```
Solution: Check for grammar conflicts in trading_parser.yrl
```

**Issue**: Compilation errors
```
Solution: Ensure all dependencies are compiled in the correct order
```

**Issue**: Runtime errors
```
Solution: Check that the trading engine is started before executing commands
```

## License

This trading engine is part of the erl_finance project.