-module(trading_parser_tests).
-export([run_all/0, test_tokenize/1, test_parse/1, test_evaluate/2]).

run_all() ->
    io:format("~n=== Running All Parser Tests ===~n~n"),
    test_tokenize_all(),
    test_parse_all(),
    test_evaluate_all(),
    io:format("~n=== All Tests Complete ===~n").

%% Tokenization Tests
test_tokenize_all() ->
    io:format("--- Tokenization Tests ---~n"),
    test_tokenize("buy 9000 shares of GOOG."),
    test_tokenize("sell 500 shares of AAPL."),
    test_tokenize("buy 100 of MSFT."),
    test_tokenize("buy 9000 shares of GOOG when price is less than 500."),
    test_tokenize("sell 100 shares of AAPL when price is greater than 150."),
    io:format("~n").

test_tokenize(String) ->
    io:format("Tokenizing: ~s~n", [String]),
    case trading_parser_api:tokenize(String) of
        {ok, Tokens} ->
            io:format("Tokens: ~p~n~n", [Tokens]);
        {error, Reason} ->
            io:format("Error: ~p~n~n", [Reason])
    end.

%% Parsing Tests
test_parse_all() ->
    io:format("--- Parsing Tests ---~n"),
    test_parse("buy 9000 shares of GOOG."),
    test_parse("sell 500 shares of AAPL."),
    test_parse("buy 100 of MSFT."),
    test_parse("buy GOOG."),
    test_parse("buy 9000 shares of GOOG when price is less than 500."),
    test_parse("sell 100 shares of AAPL when price is greater than 150."),
    test_parse("buy 500 shares of TSLA when price below 200."),
    test_parse("sell 200 shares of AMZN when price above 3000."),
    test_parse("buy 1000 shares of GOOG when price is less than 500 and volume greater than 1000000."),
    test_parse("sell 500 shares of AAPL when price is greater than 150 or volume less than 500000."),
    io:format("~n").

test_parse(String) ->
    io:format("Parsing: ~s~n", [String]),
    case trading_parser_api:parse(String) of
        {ok, AST} ->
            io:format("AST: ~p~n~n", [AST]);
        {error, Reason} ->
            io:format("Error: ~p~n~n", [Reason])
    end.

%% Evaluation Tests
test_evaluate_all() ->
    io:format("--- Evaluation Tests ---~n"),

    % Test 1: Price less than threshold (true)
    test_evaluate(
        {price_compare, less, 500},
        #{price => 450},
        true
    ),

    % Test 2: Price less than threshold (false)
    test_evaluate(
        {price_compare, less, 500},
        #{price => 550},
        false
    ),

    % Test 3: Price greater than threshold (true)
    test_evaluate(
        {price_compare, greater, 500},
        #{price => 550},
        true
    ),

    % Test 4: Price greater than threshold (false)
    test_evaluate(
        {price_compare, greater, 500},
        #{price => 450},
        false
    ),

    % Test 5: AND condition (both true)
    test_evaluate(
        {logic, 'and',
            {price_compare, less, 500},
            {compare, greater, volume, 1000000}
        },
        #{price => 450, volume => 2000000},
        true
    ),

    % Test 6: AND condition (one false)
    test_evaluate(
        {logic, 'and',
            {price_compare, less, 500},
            {compare, greater, volume, 1000000}
        },
        #{price => 450, volume => 500000},
        false
    ),

    % Test 7: OR condition (one true)
    test_evaluate(
        {logic, 'or',
            {price_compare, less, 500},
            {compare, greater, volume, 1000000}
        },
        #{price => 550, volume => 2000000},
        true
    ),

    % Test 8: OR condition (both false)
    test_evaluate(
        {logic, 'or',
            {price_compare, less, 500},
            {compare, greater, volume, 1000000}
        },
        #{price => 550, volume => 500000},
        false
    ),

    % Test 9: NOT condition
    test_evaluate(
        {not_op, {price_compare, less, 500}},
        #{price => 550},
        true
    ),

    % Test 10: NOT condition (false)
    test_evaluate(
        {not_op, {price_compare, less, 500}},
        #{price => 450},
        false
    ),

    io:format("~n").

test_evaluate(Condition, MarketData, Expected) ->
    Result = trading_engine:evaluate(Condition, MarketData),
    Status = case Result of
        Expected -> "PASS";
        _ -> "FAIL"
    end,
    io:format("Condition: ~p~n", [Condition]),
    io:format("Market Data: ~p~n", [MarketData]),
    io:format("Expected: ~p, Got: ~p~n", [Expected, Result]),
    io:format("Status: ~s~n~n", [Status]).