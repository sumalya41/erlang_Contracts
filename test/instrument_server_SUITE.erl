-module(instrument_server_SUITE).
-include_lib("eunit/include/eunit.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).

%% Test functions
-export([
    server_init_test/0,
    digital_option_test/0,
    exchange_option_test/0,
    rainbow_option_test/0,
    barrier_option_test/0,
    constant_value_test/0,
    combined_option_test/0,
    path_handling_test/0
]).

all() ->
    [
        server_init_test,
        digital_option_test,
        exchange_option_test,
        rainbow_option_test,
        barrier_option_test,
        constant_value_test,
        combined_option_test,
        path_handling_test
    ].

init_per_suite(Config) ->
    %% Start the supervisor
    {ok, _Sup} = instrument_sup:start_link(),
    Config.

end_per_suite(_Config) ->
    %% Stop the supervisor
    ok = supervisor:stop(instrument_sup).

%% =========================
%% INITIALIZATION TESTS
%% =========================

server_init_test() ->
    %% Test server initialization with path
    State = #{contract => {constant, 100}, path => [80, 90, 100]},
    {ok, InitState} = instrument_server:init(State),
    
    %% Path should be preserved
    [80, 90, 100] = maps:get(path, InitState),
    
    %% Test server initialization without path
    State2 = #{contract => {constant, 50}},
    {ok, InitState2} = instrument_server:init(State2),
    
    %% Path should be added as empty list
    [] = maps:get(path, InitState2).

%% =========================
%% DIGITAL OPTION TESTS
%% =========================

digital_option_test() ->
    %% Digital option: 1 if S > K, else 0
    %% S = 120, K = 100
    Contract = {transform, {binary, 100}, {observe, {terminal, stock}}},
    Env = #{time => terminal, {stock, terminal} => 120},
    
    {ok, Pid} = instrument_server:start_link(#{contract => Contract}),
    Value = instrument_server:value(Pid, Env),
    1 = Value,
    
    %% Test with S < K
    Contract2 = {transform, {binary, 100}, {observe, {terminal, stock}}},
    Env2 = #{time => terminal, {stock, terminal} => 80},
    
    {ok, Pid2} = instrument_server:start_link(#{contract => Contract2}),
    Value2 = instrument_server:value(Pid2, Env2),
    0 = Value2.

%% =========================
%% EXCHANGE OPTION TESTS
%% =========================

exchange_option_test() ->
    %% Exchange option: max(A - B, 0)
    Contract = {transform, diff, {observe, {multi, [a, b]}}},
    Env = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 90
    },
    
    {ok, Pid} = instrument_server:start_link(#{contract => Contract}),
    Value = instrument_server:value(Pid, Env),
    10 = Value,
    
    %% Test when A < B
    Env2 = #{
        time => terminal,
        {a, terminal} => 80,
        {b, terminal} => 100
    },
    Value2 = instrument_server:value(Pid, Env2),
    0 = Value2.

%% =========================
%% RAINBOW OPTION TESTS
%% =========================

rainbow_option_test() ->
    %% Rainbow option: max of [a, b, c]
    Contract = {transform, max_of, {observe, {multi, [a, b, c]}}},
    Env = #{
        time => terminal,
        {a, terminal} => 100,
        {b, terminal} => 80,
        {c, terminal} => 120
    },
    
    {ok, Pid} = instrument_server:start_link(#{contract => Contract}),
    Value = instrument_server:value(Pid, Env),
    120 = Value.

%% =========================
%% BARRIER OPTION TESTS
%% =========================

barrier_option_test() ->
    %% Barrier up-and-in: payoff if max(path) >= barrier
    InnerContract = {observe, {terminal, stock}},
    BarrierContract = {barrier, up_and_in, 110, InnerContract},
    
    %% Path: [80, 90, 110, 120], barrier hits at 110
    Env = #{
        time => terminal,
        {stock, terminal} => 120,
        path => [80, 90, 110, 120]
    },
    
    {ok, Pid} = instrument_server:start_link(#{contract => BarrierContract, path => [80, 90, 110, 120]}),
    Value = instrument_server:value(Pid, Env),
    
    %% Barrier hit, so payoff is 120
    120 = Value,
    
    %% Test barrier not hit
    Env2 = #{
        time => terminal,
        {stock, terminal} => 120,
        path => [80, 90, 100, 105]  %% max is 105, doesn't hit 110
    },
    
    {ok, Pid2} = instrument_server:start_link(#{contract => BarrierContract, path => [80, 90, 100, 105]}),
    Value2 = instrument_server:value(Pid2, Env2),
    0 = Value2.

%% =========================
%% CONSTANT VALUE TESTS
%% =========================

constant_value_test() ->
    %% Constant contract always returns the same value
    Contract = {constant, 42},
    
    {ok, Pid} = instrument_server:start_link(#{contract => Contract}),
    
    Env1 = #{time => terminal},
    42 = instrument_server:value(Pid, Env1),
    
    Env2 = #{time => terminal, {stock, terminal} => 500},
    42 = instrument_server:value(Pid, Env2).

%% =========================
%% COMBINED OPTION TESTS
%% =========================

combined_option_test() ->
    %% Combined: add two constant contracts
    C1 = {constant, 100},
    C2 = {constant, 50},
    Combined = {combine, add, C1, C2},
    
    {ok, Pid} = instrument_server:start_link(#{contract => Combined}),
    
    Env = #{time => terminal},
    150 = instrument_server:value(Pid, Env),
    
    %% Choice: max of two constants
    Choice = {choice, {constant, 100}, {constant, 80}},
    {ok, Pid2} = instrument_server:start_link(#{contract => Choice}),
    100 = instrument_server:value(Pid2, Env).

%% =========================
%% PATH HANDLING TESTS
%% =========================

path_handling_test() ->
    %% Test market update adds to path
    Contract = {constant, 100},
    {ok, Pid} = instrument_server:start_link(#{contract => Contract, path => []}),
    
    %% Initial state
    InitialEnv = #{time => terminal},
    100 = instrument_server:value(Pid, InitialEnv),
    
    %% Add market update
    ok = instrument_server:update_price(Pid, 110),
    ok = instrument_server:update_price(Pid, 120),
    
    %% Describe to check internal state
    State = instrument_server:describe(Pid),
    Path = maps:get(path, State),
    
    %% Path should contain prices in reverse order (most recent first)
    [120, 110] = Path.
