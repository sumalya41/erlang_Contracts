-module(trading_examples).
-export([run/0, example_basic/0, example_conditional/0, example_complex/0, example_integration/0]).

run() ->
    io:format("~n=== Trading Engine Examples ===~n~n"),
    example_basic(),
    example_conditional(),
    example_complex(),
    example_volume_volatility(),
    example_integration().

%% Basic Trading Commands
example_basic() ->
    io:format("--- Basic Trading Commands ---~n~n"),

    Commands = [
        "buy 9000 shares of GOOG.",
        "sell 500 shares of AAPL.",
        "buy 100 of MSFT.",
        "buy GOOG."
    ],

    lists:foreach(fun(Command) ->
        io:format("Command: ~s~n", [Command]),
        case trading_parser_api:parse_and_compile(Command) of
            {ok, Result} ->
                io:format("Compiled: ~p~n~n", [Result]);
            {error, Reason} ->
                io:format("Error: ~p~n~n", [Reason])
        end
    end, Commands).

%% Conditional Trading Commands
example_conditional() ->
    io:format("--- Conditional Trading Commands ---~n~n"),

    Commands = [
        "buy 9000 shares of GOOG when price is less than 500.",
        "sell 100 shares of AAPL when price is greater than 150.",
        "buy 500 shares of TSLA when price below 200.",
        "sell 200 shares of AMZN when price above 3000."
    ],

    lists:foreach(fun(Command) ->
        io:format("Command: ~s~n", [Command]),
        case trading_parser_api:parse_and_compile(Command) of
            {ok, Result} ->
                io:format("Compiled: ~p~n~n", [Result]);
            {error, Reason} ->
                io:format("Error: ~p~n~n", [Reason])
        end
    end, Commands).

%% Complex Conditions
example_complex() ->
    io:format("--- Complex Conditions ---~n~n"),

    Commands = [
        "buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000.",
        "sell 500 shares of AAPL when price is greater than 150 or volume less than 500000.",
        "buy 200 shares of TSLA when price below 200 and volume above 500000."
    ],

    lists:foreach(fun(Command) ->
        io:format("Command: ~s~n", [Command]),
        case trading_parser_api:parse_and_compile(Command) of
            {ok, Result} ->
                io:format("Compiled: ~p~n~n", [Result]);
            {error, Reason} ->
                io:format("Error: ~p~n~n", [Reason])
        end
    end, Commands).

%% Volume and Volatility Conditions
example_volume_volatility() ->
    io:format("--- Volume and Volatility Conditions ---~n~n"),

    Commands = [
        "buy 1000 shares of GOOG when volume greater than 1000000.",
        "sell 500 shares of AAPL when volume less than 500000.",
        "buy 200 shares of TSLA when volatility greater than 0.02.",
        "sell 300 shares of AMZN when volatility less than 0.01.",
        "buy 500 shares of MSFT when price less than 300 and volatility greater than 0.015.",
        "sell 800 shares of NFLX when volume greater than 2000000 or volatility less than 0.025."
    ],

    lists:foreach(fun(Command) ->
        io:format("Command: ~s~n", [Command]),
        case trading_parser_api:parse_and_compile(Command) of
            {ok, Result} ->
                io:format("Compiled: ~p~n~n", [Result]);
            {error, Reason} ->
                io:format("Error: ~p~n~n", [Reason])
        end
    end, Commands).

%% Integration with Instrument System
example_integration() ->
    io:format("--- Integration with Instrument System ---~n~n"),

    trading_engine:start(),

    %% Example 1: Create instrument from command
    Command1 = "buy 9000 shares of GOOG when price is less than 500.",
    io:format("Command: ~s~n", [Command1]),
    case trading_integration:execute_trading_command(Command1) of
        {ok, Result} ->
            io:format("Instrument Created: ~p~n~n", [Result]);
        {error, Reason} ->
            io:format("Error: ~p~n~n", [Reason])
    end,

    %% Example 2: Evaluate command against market data
    Command2 = "buy 1000 shares of GOOG when price is less than 500.",
    MarketData1 = #{price => 450, volume => 2000000},
    io:format("Command: ~s~n", [Command2]),
    io:format("Market Data: ~p~n", [MarketData1]),
    case trading_integration:evaluate_command(Command2, MarketData1) of
        {ok, true} ->
            io:format("Result: Condition met, order would execute~n~n");
        {ok, false} ->
            io:format("Result: Condition not met, order would not execute~n~n");
        {error, Reason1} ->
            io:format("Error: ~p~n~n", [Reason1])
    end,

    %% Example 3: Same command with different market data
    MarketData2 = #{price => 550, volume => 2000000},
    io:format("Command: ~s~n", [Command2]),
    io:format("Market Data: ~p~n", [MarketData2]),
    case trading_integration:evaluate_command(Command2, MarketData2) of
        {ok, true} ->
            io:format("Result: Condition met, order would execute~n~n");
        {ok, false} ->
            io:format("Result: Condition not met, order would not execute~n~n");
        {error, Reason2} ->
            io:format("Error: ~p~n~n", [Reason2])
    end,

    %% Example 4: Complex condition evaluation
    Command3 = "buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000.",
    MarketData3 = #{price => 450, volume => 2000000},
    io:format("Command: ~s~n", [Command3]),
    io:format("Market Data: ~p~n", [MarketData3]),
    case trading_integration:evaluate_command(Command3, MarketData3) of
        {ok, true} ->
            io:format("Result: Condition met, order would execute~n~n");
        {ok, false} ->
            io:format("Result: Condition not met, order would not execute~n~n");
        {error, Reason3} ->
            io:format("Error: ~p~n~n", [Reason3])
    end,

    %% Example 5: Volatility calculation
    io:format("--- Volatility Calculation Example ---~n~n"),
    HistoricalPrices = [100, 102, 98, 105, 110, 108, 112, 115, 113, 118, 120, 117],
    Volatility = market_calculations:calculate_volatility(HistoricalPrices, 10),
    io:format("Historical Prices: ~p~n", [HistoricalPrices]),
    io:format("10-period Volatility: ~.4f (~.2f%)~n~n", [Volatility, Volatility * 100]),

    %% Example 6: Volatility condition evaluation
    Command4 = "buy 500 shares of GOOG when volatility greater than 0.02.",
    MarketData4 = #{price => 450, volume => 2000000, volatility => 0.025},
    io:format("Command: ~s~n", [Command4]),
    io:format("Market Data: ~p~n", [MarketData4]),
    case trading_integration:evaluate_command(Command4, MarketData4) of
        {ok, true} ->
            io:format("Result: Condition met, order would execute~n~n");
        {ok, false} ->
            io:format("Result: Condition not met, order would not execute~n~n");
        {error, Reason4} ->
            io:format("Error: ~p~n~n", [Reason4])
    end.