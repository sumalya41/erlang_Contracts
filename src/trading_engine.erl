-module(trading_engine).
-export([start/0, execute/1, evaluate/2, compile_command/1]).

%% Start the trading engine
start() ->
    instrument_custom:start().

%% Execute a natural language trading command
execute(CommandString) ->
    case trading_parser_api:parse_and_compile(CommandString) of
        {ok, Contract} ->
            execute_contract(Contract);
        {error, Reason} ->
            {error, Reason}
    end.

%% Execute a compiled contract
execute_contract({buy, Quantity, Symbol}) ->
    io:format("Executing: Buy ~p shares of ~p~n", [Quantity, Symbol]),
    {ok, {buy, Quantity, Symbol}};

execute_contract({sell, Quantity, Symbol}) ->
    io:format("Executing: Sell ~p shares of ~p~n", [Quantity, Symbol]),
    {ok, {sell, Quantity, Symbol}};

execute_contract({buy, Quantity, Symbol, Condition}) ->
    io:format("Conditional Buy: ~p shares of ~p when ~p~n", [Quantity, Symbol, Condition]),
    {ok, {buy, Quantity, Symbol, Condition}};

execute_contract({sell, Quantity, Symbol, Condition}) ->
    io:format("Conditional Sell: ~p shares of ~p when ~p~n", [Quantity, Symbol, Condition]),
    {ok, {sell, Quantity, Symbol, Condition}}.

%% Evaluate a condition against market data
evaluate(Condition, MarketData) ->
    eval_condition(Condition, MarketData).

%% Evaluate condition
eval_condition({compare, Op, Left, Right}, MarketData) ->
    LeftVal = eval_expr(Left, MarketData),
    RightVal = eval_expr(Right, MarketData),
    compare(Op, LeftVal, RightVal);

eval_condition({price_compare, Op, Value}, MarketData) ->
    Price = maps:get(price, MarketData, 0),
    compare(Op, Price, eval_expr(Value, MarketData));

eval_condition({volume_compare, Op, Value}, MarketData) ->
    Volume = maps:get(volume, MarketData, 0),
    compare(Op, Volume, eval_expr(Value, MarketData));

eval_condition({volatility_compare, Op, Value}, MarketData) ->
    Volatility = maps:get(volatility, MarketData, 0),
    compare(Op, Volatility, eval_expr(Value, MarketData));

%% Moving Average Conditions
eval_condition({price_ma_comparison, Op, Period, Value}, MarketData) ->
    MA = get_price_ma(MarketData, Period),
    compare(Op, MA, eval_expr(Value, MarketData));

eval_condition({volume_ma_comparison, Op, Period, Value}, MarketData) ->
    MA = get_volume_ma(MarketData, Period),
    compare(Op, MA, eval_expr(Value, MarketData));

eval_condition({volatility_ma_comparison, Op, Period, Value}, MarketData) ->
    MA = get_volatility_ma(MarketData, Period),
    compare(Op, MA, eval_expr(Value, MarketData));

%% EMA Conditions
eval_condition({ema_compare, Field, Period, Op, Value}, MarketData) ->
    EMA = get_ema(MarketData, Field, Period),
    compare(Op, EMA, eval_expr(Value, MarketData));

eval_condition({ema_crossover, Field, Period, Op}, MarketData) ->
    EMA = get_ema(MarketData, Field, Period),
    Current = get_current(MarketData, Field),
    compare(Op, Current, EMA);

%% Volatility Conditions
eval_condition({volatility_compare, Op, Value}, MarketData) ->
    Volatility = maps:get(volatility, MarketData, 0),
    compare(Op, Volatility, eval_expr(Value, MarketData));

eval_condition({logic, 'and', Left, Right}, MarketData) ->
    eval_condition(Left, MarketData) andalso eval_condition(Right, MarketData);

eval_condition({logic, 'or', Left, Right}, MarketData) ->
    eval_condition(Left, MarketData) orelse eval_condition(Right, MarketData);

eval_condition({not_op, Cond}, MarketData) ->
    not eval_condition(Cond, MarketData).

%% Evaluate expression
eval_expr(Symbol, MarketData) when is_atom(Symbol); is_list(Symbol) ->
    maps:get(Symbol, MarketData, 0);

eval_expr(Value, _MarketData) when is_number(Value) ->
    Value.

%% Compare values
compare(less, A, B) -> A < B;
compare(greater, A, B) -> A > B;
compare(above, A, B) -> A > B;
compare(below, A, B) -> A < B;
compare(at, A, B) -> A =:= B.

%% Get moving average from market data
get_price_ma(MarketData, Period) ->
    case maps:get(price_ma, MarketData, undefined) of
        undefined -> maps:get(price, MarketData, 0);
        MAs -> lists:nth(min(Period, length(MAs)), lists:reverse(MAs))
    end.

get_volume_ma(MarketData, Period) ->
    case maps:get(volume_ma, MarketData, undefined) of
        undefined -> maps:get(volume, MarketData, 0);
        MAs -> lists:nth(min(Period, length(MAs)), lists:reverse(MAs))
    end.

get_volatility_ma(MarketData, Period) ->
    case maps:get(volatility_ma, MarketData, undefined) of
        undefined -> maps:get(volatility, MarketData, 0);
        MAs -> lists:nth(min(Period, length(MAs)), lists:reverse(MAs))
    end.

%% EMA helper
get_ema(MarketData, Field, Period) ->
    case maps:get({ema, Field}, MarketData, undefined) of
        undefined -> maps:get(Field, MarketData, 0);
        EMAs -> lists:nth(min(Period, length(EMAs)), lists:reverse(EMAs))
    end.

%% Get current price/volume for EMA crossover
get_current(MarketData, price) ->
    maps:get(price, MarketData, 0);
get_current(MarketData, volume) ->
    maps:get(volume, MarketData, 0).

%% Compile command to instrument contract
compile_command(CommandString) ->
    trading_parser_api:parse_and_compile(CommandString).