-module(trading_parser_api).
-export([parse/1, parse_and_compile/1, tokenize/1]).

%% Parse a trading command string into an AST
parse(String) ->
    case tokenize(String) of
        {ok, Tokens} ->
            case trading_parser:parse(Tokens) of
                {ok, AST} -> {ok, AST};
                {error, {Line, Module, Message}} -> {error, {Line, Module, Message}};
                Error -> Error
            end;
        {error, Reason} -> {error, Reason}
    end.

%% Tokenize a string using the lexer
tokenize(String) ->
    case trading_lexer:string(String) of
        {ok, Tokens, _Line} -> {ok, Tokens};
        {error, ErrorInfo, _Line} -> {error, ErrorInfo}
    end.

%% Parse and compile to instrument contract
parse_and_compile(String) ->
    case parse(String) of
        {ok, {command, Action, Condition}} ->
            case compile_command(Action, Condition) of
                {ok, Contract} -> {ok, Contract};
                Error -> Error
            end;
        {ok, {command, Action}} ->
            case compile_command(Action, none) of
                {ok, Contract} -> {ok, Contract};
                Error -> Error
            end;
        Error -> Error
    end.

%% Compile parsed command to instrument contract
compile_command({action, buy, Quantity, Symbol}, none) ->
    {ok, {buy, Quantity, Symbol}};

compile_command({action, sell, Quantity, Symbol}, none) ->
    {ok, {sell, Quantity, Symbol}};

compile_command({action, buy, Quantity, Symbol}, Condition) ->
    {ok, {buy, Quantity, Symbol, compile_condition(Condition)}};

compile_command({action, sell, Quantity, Symbol}, Condition) ->
    {ok, {sell, Quantity, Symbol, compile_condition(Condition)}}.

%% Compile condition to DSL
compile_condition({comparison, Op, Left, Right}) ->
    {compare, Op, compile_expr(Left), compile_expr(Right)};

compile_condition({price_comparison, Op, Value}) ->
    {price_compare, Op, compile_expr(Value)};

compile_condition({volume_comparison, Op, Value}) ->
    {volume_compare, Op, compile_expr(Value)};

compile_condition({volatility_comparison, Op, Value}) ->
    {volatility_compare, Op, compile_expr(Value)};

%% Moving Average Conditions
compile_condition({price_ma_comparison, Op, Period, Value}) ->
    {price_ma_comparison, Op, Period, compile_expr(Value)};

compile_condition({volume_ma_comparison, Op, Period, Value}) ->
    {volume_ma_comparison, Op, Period, compile_expr(Value)};

compile_condition({volatility_ma_comparison, Op, Period, Value}) ->
    {volatility_ma_comparison, Op, Period, compile_expr(Value)};

compile_condition({ema_comparison, Field, Period, Op, Value}) ->
    {ema_compare, Field, Period, Op, compile_expr(Value)};

compile_condition({ema_crossover, Field, Period, Op}) ->
    {ema_crossover, Field, Period, Op};

compile_condition({volatility_comparison, Op, Value}) ->
    {volatility_compare, Op, compile_expr(Value)};

compile_condition({logic_op, Op, Left, Right}) ->
    {logic, Op, compile_condition(Left), compile_condition(Right)};

compile_condition({not_op, Cond}) ->
    {not_op, compile_condition(Cond)}.

%% Compile expression
compile_expr({identifier, Name}) -> Name;
compile_expr({integer, Value}) -> Value;
compile_expr({float, Value}) -> Value.