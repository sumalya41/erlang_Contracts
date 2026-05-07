# Trading Engine Parser & Tokenizer

This module provides a natural language parser for trading commands in your Erlang finance system.

## Features

- **Natural Language Commands**: Parse commands like "buy 9000 shares of GOOG when price is less than 500"
- **Lexer (Tokenizer)**: Uses `leex` for lexical analysis
- **Parser**: Uses `yecc` for LALR-1 parsing
- **Condition Evaluation**: Evaluate conditions against market data
- **Integration**: Works with existing instrument system

## Building

```bash
# Generate lexer and parser
cd src
erlc trading_lexer.xrl
erlc trading_parser.yrl

# Or use rebar3
rebar3 compile
```

## Usage

### Basic Commands

```erlang
% Start the engine
trading_engine:start().

% Execute simple commands
trading_engine:execute("buy 9000 shares of GOOG.").
trading_engine:execute("sell 500 shares of AAPL.").

% Execute conditional commands
trading_engine:execute("buy 9000 shares of GOOG when price is less than 500.").
trading_engine:execute("sell 100 shares of AAPL when price is greater than 150.").
```

### Supported Syntax

**Actions:**
- `buy [quantity] shares of [symbol]`
- `sell [quantity] shares of [symbol]`
- `buy [quantity] of [symbol]`
- `buy [symbol]` (defaults to 1 share)

**Conditions:**
- `when price is less than [value]`
- `when price is greater than [value]`
- `when price below [value]`
- `when price above [value]`
- `when [expression] compare [expression]`

**Logical Operators:**
- `and` - logical AND
- `or` - logical OR
- `not` - logical NOT

**Comparison Operators:**
- `less` / `below` - less than
- `greater` / `above` - greater than
- `at` - equal to

### Condition Evaluation

```erlang
% Define market data
MarketData = #{price => 450, volume => 2000000}.

% Evaluate condition
Condition = {price_compare, less, 500},
trading_engine:evaluate(Condition, MarketData).
% Returns: true

% Complex condition
Condition2 = {logic, and,
    {price_compare, less, 500},
    {compare, greater, volume, 1000000}
},
trading_engine:evaluate(Condition2, MarketData).
% Returns: true
```

### Running Demo

```erlang
trading_demo:run().
```

## Architecture

```
trading_lexer.xrl    -> Tokenizer (leex)
trading_parser.yrl   -> Parser (yecc)
trading_parser.erl   -> Parser interface
trading_engine.erl   -> Execution engine
trading_demo.erl     - Demo and tests
```

## Examples

### Simple Buy
```
Input:  "buy 9000 shares of GOOG."
Output: {ok, {buy, 9000, 'GOOG'}}
```

### Conditional Buy
```
Input:  "buy 9000 shares of GOOG when price is less than 500."
Output: {ok, {buy, 9000, 'GOOG', {price_compare, less, 500}}}
```

### Complex Condition
```
Input:  "buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000."
Output: {ok, {buy, 1000, 'GOOG', {logic, and,
    {price_compare, less, 500},
    {compare, greater, volume, 1000000}
}}}
```

## Integration with Instrument System

The parser can be extended to compile trading commands into your existing instrument DSL:

```erlang
% Example: Convert trading command to instrument contract
compile_to_instrument({buy, Quantity, Symbol, Condition}) ->
    %% Create a conditional order instrument
    instrument_custom:barrier(up_and_in, Threshold, Contract).
```

## Future Enhancements

- Support for limit orders
- Support for stop-loss orders
- Support for time-based conditions
- Support for portfolio-level commands
- Integration with real-time market data feeds
- Order book management