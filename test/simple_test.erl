-module(simple_test).
-export([run/0]).

run() ->
    io:format("=== Volume and Volatility Test ===~n"),

    % Test volume condition
    Command = "buy 1000 shares of GOOG when volume greater than 1000000.",
    io:format("Parsing: ~s~n", [Command]),

    % Tokenize first
    case trading_lexer:string(Command) of
        {ok, Tokens, _} ->
            io:format("Tokens: ~p~n~n", [Tokens]),

            % Then parse
            case trading_parser:parse(Tokens) of
                {ok, AST} ->
                    io:format("AST: ~p~n~n", [AST]);
                {error, {Line, Module, Message}} ->
                    io:format("Parse error at line ~p: ~s~n", [Line, Module:format_error(Message)])
            end;
        {error, ErrorInfo, _Line} ->
            io:format("Lexer error: ~p~n", [ErrorInfo])
    end.