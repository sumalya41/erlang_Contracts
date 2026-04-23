-module(main).
-export([run/0]).

run() ->
    %% =========================
    %% START SYSTEM
    %% =========================
    instrument_custom:start(),

    %% =========================
    %% DEFINE CONTRACTS (DSL)
    %% =========================

    %% Digital Option: 1 if S_T > 100
    Digital = instrument_custom:digital(stock, 100),

    %% Exchange Option: max(A - B, 0)
    Exchange = instrument_custom:exchange(a, b),

    %% Rainbow Option: max of assets
    Rainbow = instrument_custom:rainbow_best([a, b, c]),

    %% Barrier Option wrapping Digital
    BarrierContract =
        {transform, {binary, 100},
            {observe, {terminal, stock}}},

    Barrier =
        instrument_custom:barrier(up_and_in, 110, BarrierContract),

    %% =========================
    %% ENVIRONMENT (CRITICAL CHANGE)
    %% =========================

    Env = #{
        time => terminal,

        %% terminal prices
        {stock, terminal} => 120,
        {a, terminal} => 100,
        {b, terminal} => 90,
        {c, terminal} => 130,

        %% path for path-dependent options
        path => [80, 90, 110, 120]
    },

    %% =========================
    %% EVALUATION
    %% =========================

    io:format("Digital: ~p~n",
        [instrument_server:value(Digital, Env)]),

    io:format("Exchange: ~p~n",
        [instrument_server:value(Exchange, Env)]),

    io:format("Rainbow: ~p~n",
        [instrument_server:value(Rainbow, Env)]),

    io:format("Barrier: ~p~n",
        [instrument_server:value(Barrier, Env)]).