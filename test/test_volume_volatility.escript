#!/usr/bin/env escript
%%! -pa src -pa examples

main(_) ->
    code:ensure_loaded(trading_parser),
    code:ensure_loaded(trading_engine),
    code:ensure_loaded(market_calculations),

    io:format("=== Testing Volume and Volatility Support ===~n~n"),

    %% Test 1: Volume condition
    Command1 = "buy 1000 shares of GOOG when volume greater than 1000000.",
    io:format("Command: ~s~n", [Command1]),
    case trading_parser_api:parse_and_compile(Command1) of
        {ok, Result1} ->
            io:format("Compiled: ~p~n~n", [Result1]);
        {error, Reason1} ->
            io:format("Error: ~p~n~n", [Reason1])
    end,

    %% Test 2: Volatility condition
    Command2 = "buy 500 shares of AAPL when volatility less than 0.02.",
    io:format("Command: ~s~n", [Command2]),
    case trading_parser_api:parse_and_compile(Command2) of
        {ok, Result2} ->
            io:format("Compiled: ~p~n~n", [Result2]);
        {error, Reason2} ->
            io:format("Error: ~p~n~n", [Reason2])
    end,

    %% Test 3: Combined condition
    Command3 = "buy 800 shares of TSLA when price less than 300 and volume greater than 500000.",
    io:format("Command: ~s~n", [Command3]),
    case trading_parser_api:parse_and_compile(Command3) of
        {ok, Result3} ->
            io:format("Compiled: ~p~n~n", [Result3]);
        {error, Reason3} ->
            io:format("Error: ~p~n~n", [Reason3])
    end,

    %% Test 4: Evaluate with market data
    Command4 = "buy 500 shares of GOOG when volume greater than 1000000.",
    MarketData = #{price => 450, volume => 2000000, volatility => 0.025},
    io:format("Command: ~s~n", [Command4]),
    io:format("Market Data: ~p~n", [MarketData]),
    case trading_parser_api:parse_and_compile(Command4) of
        {ok, {_Action, _Quantity, _Symbol, Condition}} ->
            Result = trading_engine:evaluate(Condition, MarketData),
            io:format("Evaluation Result: ~p~n~n", [Result]);
        _ ->
            io:format("Could not evaluate~n~n")
    end,

    %% Test 5: Volatility calculation
    io:format("=== Volatility Calculation Test ===~n"),
    HistoricalPrices = [100, 102, 98, 105, 110, 108, 112, 115, 113, 118, 120, 117],
    Volatility = market_calculations:calculate_volatility(HistoricalPrices, 10),
    io:format("Historical Prices: ~p~n", [HistoricalPrices]),
    io:format("10-period Volatility: ~.4f (~.2f%)~n~n", [Volatility, Volatility * 100]),

    io:format("=== All Tests Complete ===~n").