-module(main).
-export([run/0]).

run() ->
    instrument_custom:start(),

    Stock = instrument_custom:base(100),

    Call = instrument_custom:derivative(
        Stock, 90, {2026,5,1}
    ),

    Bond = instrument_custom:bond(1000, 0.05, fixed),

    Env = #{},

    io:format("Stock: ~p~n",
        [instrument_server:value(Stock, Env)]),

    io:format("Call: ~p~n",
        [instrument_server:value(Call, Env)]),

    io:format("Bond: ~p~n",
        [instrument_server:value(Bond, Env)]).