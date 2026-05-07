-module(trading_demo).
-export([run/0, test/1]).

run() ->
    trading_engine:start(),
    io:format("~n=== Trading Engine Demo ===~n~n"),

    %% Test basic commands
    test("buy 9000 shares of GOOG."),
    test("sell 500 shares of AAPL."),
    test("buy 100 of MSFT."),

    %% Test conditional commands
    test("buy 9000 shares of GOOG when price is less than 500."),
    test("sell 100 shares of AAPL when price is greater than 150."),
    test("buy 500 shares of TSLA when price below 200."),
    test("sell 200 shares of AMZN when price above 3000."),

    %% Test complex conditions
    test("buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000."),
    test("sell 500 shares of AAPL when price is greater than 150 or volume less than 500000."),

    %% Test evaluation
    io:format("~n=== Condition Evaluation Demo ===~n~n"),
    test_evaluation().

test(Command) ->
    io:format("Command: ~s~n", [Command]),
    case trading_engine:execute(Command) of
        {ok, Result} ->
            io:format("Result: ~p~n~n", [Result]);
        {error, Reason} ->
            io:format("Error: ~p~n~n", [Reason])
    end.

test_evaluation() ->
    %% Test condition evaluation
    MarketData1 = #{price => 450, volume => 2000000},
    Condition1 = {price_compare, less, 500},

    io:format("Market Data: ~p~n", [MarketData1]),
    io:format("Condition: price < 500~n"),
    io:format("Result: ~p~n~n", [trading_engine:evaluate(Condition1, MarketData1)]),

    MarketData2 = #{price => 550, volume => 2000000},
    io:format("Market Data: ~p~n", [MarketData2]),
    io:format("Condition: price < 500~n"),
    io:format("Result: ~p~n~n", [trading_engine:evaluate(Condition1, MarketData2)]),

    %% Test complex condition
    Condition2 = {logic, 'and',
        {price_compare, less, 500},
        {compare, greater, volume, 1000000}
    },

    io:format("Market Data: ~p~n", [MarketData1]),
    io:format("Condition: price < 500 and volume > 1000000~n"),
    io:format("Result: ~p~n~n", [trading_engine:evaluate(Condition2, MarketData1)]),

    MarketData3 = #{price => 450, volume => 500000},
    io:format("Market Data: ~p~n", [MarketData3]),
    io:format("Condition: price < 500 and volume > 1000000~n"),
    io:format("Result: ~p~n~n", [trading_engine:evaluate(Condition2, MarketData3)]).