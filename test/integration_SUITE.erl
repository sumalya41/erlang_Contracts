-module(integration_SUITE).
-include_lib("eunit/include/eunit.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).

%% Test functions
-export([
    end_to_end_digital_option_test/0,
    end_to_end_exchange_option_test/0,
    end_to_end_rainbow_option_test/0,
    end_to_end_barrier_option_test/0,
    complex_derivative_test/0
]).

all() ->
    [
        end_to_end_digital_option_test,
        end_to_end_exchange_option_test,
        end_to_end_rainbow_option_test,
        end_to_end_barrier_option_test,
        complex_derivative_test
    ].

init_per_suite(Config) ->
    %% Start the supervisor system
    {ok, _Sup} = instrument_sup:start_link(),
    Config.

end_per_suite(_Config) ->
    %% Stop the supervisor
    ok = supervisor:stop(instrument_sup).

%% =========================
%% END-TO-END TESTS (LIKE main.erl)
%% =========================

end_to_end_digital_option_test() ->
    %% Digital Option: 1 if S_T > 100
    Digital = instrument_custom:digital(stock, 100),
    
    %% Environment with terminal stock price = 120
    Env = #{
        time => terminal,
        {stock, terminal} => 120
    },
    
    %% Should be 1 (in-the-money)
    1 = instrument_server:value(Digital, Env),
    
    %% Test out-of-the-money
    Env2 = #{
        time => terminal,
        {stock, terminal} => 80
    },
    0 = instrument_server:value(Digital, Env2),
    
    %% Test at-the-money
    Env3 = #{
        time => terminal,
        {stock, terminal} => 100
    },
    0 = instrument_server:value(Digital, Env3).

%% =========================
%% END-TO-END EXCHANGE OPTION TEST
%% =========================

end_to_end_exchange_option_test() ->
    %% Exchange Option: max(A - B, 0)
    Exchange = instrument_custom:exchange(a, b),
    
    %% A = 100, B = 90
    Env1 = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 90
    },
    
    10 = instrument_server:value(Exchange, Env1),
    
    %% A = 80, B = 100
    Env2 = #{
        time => terminal,
        {a, terminal} => 80,
        {b, terminal} => 100
    },
    
    0 = instrument_server:value(Exchange, Env2),
    
    %% A = B
    Env3 = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 100
    },
    
    0 = instrument_server:value(Exchange, Env3).

%% =========================
%% END-TO-END RAINBOW OPTION TEST
%% =========================

end_to_end_rainbow_option_test() ->
    %% Rainbow Option: max of assets
    Rainbow = instrument_custom:rainbow_best([a, b, c]),
    
    %% Test 1: c is highest
    Env1 = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 90,
        {c, terminal} => 130
    },
    
    130 = instrument_server:value(Rainbow, Env1),
    
    %% Test 2: a is highest
    Env2 = #{
        time => terminal,
        {a, terminal} => 150,
        {b, terminal} => 90,
        {c, terminal} => 130
    },
    
    150 = instrument_server:value(Rainbow, Env2),
    
    %% Test 3: b is highest
    Env3 = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 160,
        {c, terminal} => 130
    },
    
    160 = instrument_server:value(Rainbow, Env3).

%% =========================
%% END-TO-END BARRIER OPTION TEST
%% =========================

end_to_end_barrier_option_test() ->
    %% Barrier Option: up-and-in with digital payoff
    BarrierContract =
        {transform, {binary, 100},
            {observe, {terminal, stock}}},
    
    Barrier = instrument_custom:barrier(up_and_in, 110, BarrierContract),
    
    %% Test 1: Barrier hit (max(path) >= 110), and S_T > 100
    Env1 = #{
        time => terminal,
        {stock, terminal} => 120,
        path => [80, 90, 110, 120]
    },
    
    1 = instrument_server:value(Barrier, Env1),
    
    %% Test 2: Barrier not hit
    Env2 = #{
        time => terminal,
        {stock, terminal} => 120,
        path => [80, 90, 100, 105]
    },
    
    0 = instrument_server:value(Barrier, Env2),
    
    %% Test 3: Barrier hit but S_T < 100
    Env3 = #{
        time => terminal,
        {stock, terminal} => 95,
        path => [80, 90, 110, 120]
    },
    
    0 = instrument_server:value(Barrier, Env3).

%% =========================
%% COMPLEX DERIVATIVE TEST
%% =========================

complex_derivative_test() ->
    %% Create a complex contract: choose between digital and exchange
    Digital = {transform, {binary, 100}, {observe, {terminal, stock}}},
    Exchange = {transform, diff, {observe, {multi, [a, b]}}},
    Complex = {choice, Digital, Exchange},
    
    {ok, Pid} = instrument_server:start_link(#{contract => Complex}),
    
    %% Environment
    Env = #{
        time => terminal,
        {stock, terminal} => 120,
        {a, terminal} => 100,
        {b, terminal} => 90
    },
    
    %% choice takes max: max(1, 10) = 10
    10 = instrument_server:value(Pid, Env),
    
    %% Test where digital is better
    Env2 = #{
        time => terminal,
        {stock, terminal} => 120,
        {a, terminal} => 100,
        {b, terminal} => 99
    },
    
    %% max(1, 1) = 1
    1 = instrument_server:value(Pid, Env2),
    
    %% Test where digital loses
    Env3 = #{
        time => terminal,
        {stock, terminal} => 50,
        {a, terminal} => 100,
        {b, terminal} => 90
    },
    
    %% max(0, 10) = 10
    10 = instrument_server:value(Pid, Env3).
