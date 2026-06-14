-module(test_direct).
-export([run/0]).

run() ->
    io:format("=== Direct Volume and Volatility Test ===~n~n"),

    % Test volume condition evaluation
    VolumeCondition = {volume_compare, greater, 1000000},
    MarketData1 = #{price => 450, volume => 2000000, volatility => 0.025},
    io:format("Testing: volume > 1000000 with volume = 2000000~n"),
    Result1 = trading_engine:evaluate(VolumeCondition, MarketData1),
    io:format("Result: ~p~n~n", [Result1]),

    % Test volatility condition evaluation
    VolatilityCondition = {volatility_compare, less, 0.02},
    MarketData2 = #{price => 450, volume => 2000000, volatility => 0.025},
    io:format("Testing: volatility < 0.02 with volatility = 0.025~n"),
    Result2 = trading_engine:evaluate(VolatilityCondition, MarketData2),
    io:format("Result: ~p~n~n", [Result2]),

    % Test with different volatility
    MarketData3 = #{price => 450, volume => 2000000, volatility => 0.015},
    io:format("Testing: volatility < 0.02 with volatility = 0.015~n"),
    Result3 = trading_engine:evaluate(VolatilityCondition, MarketData3),
    io:format("Result: ~p~n~n", [Result3]),

    % Test combined condition
    CombinedCondition = {logic, 'and',
                         {price_compare, less, 500},
                         {volume_compare, greater, 1000000}},
    MarketData4 = #{price => 450, volume => 2000000, volatility => 0.025},
    io:format("Testing: price < 500 AND volume > 1000000 with price=450, volume=2000000~n"),
    Result4 = trading_engine:evaluate(CombinedCondition, MarketData4),
    io:format("Result: ~p~n~n", [Result4]),

    % Test volatility calculation
    io:format("=== Volatility Calculation ===~n"),
    HistoricalPrices = [100, 102, 98, 105, 110, 108, 112, 115, 113, 118, 120, 117],
    Volatility = market_calculations:calculate_volatility(HistoricalPrices, 10),
    io:format("Historical Prices: ~p~n", [HistoricalPrices]),
    io:format("10-period Volatility: ~.4f (~.2f%)~n~n", [Volatility, Volatility * 100]),

    io:format("=== All Tests Complete ===~n").