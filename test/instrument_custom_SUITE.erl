-module(instrument_custom_SUITE).
-include_lib("eunit/include/eunit.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).

%% Test functions
-export([
    digital_option_creation_test/0,
    exchange_option_creation_test/0,
    rainbow_option_creation_test/0,
    barrier_option_creation_test/0,
    forward_start_creation_test/0,
    chooser_option_creation_test/0,
    lookback_option_creation_test/0,
    vanilla_irs_creation_test/0,
    equity_swap_creation_test/0,
    vol_swap_creation_test/0
]).

all() ->
    [
        digital_option_creation_test,
        exchange_option_creation_test,
        rainbow_option_creation_test,
        barrier_option_creation_test,
        forward_start_creation_test,
        chooser_option_creation_test,
        lookback_option_creation_test,
        vanilla_irs_creation_test,
        equity_swap_creation_test,
        vol_swap_creation_test
    ].

init_per_suite(Config) ->
    %% Start the supervisor system
    {ok, _Sup} = instrument_sup:start_link(),
    Config.

end_per_suite(_Config) ->
    %% Stop the supervisor
    ok = supervisor:stop(instrument_sup).

%% =========================
%% DIGITAL OPTION TESTS
%% =========================

digital_option_creation_test() ->
    %% Create a digital option
    Pid = instrument_custom:digital(stock, 100),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {transform, {binary, 100}, {observe, {terminal, stock}}} = maps:get(contract, State).

%% =========================
%% EXCHANGE OPTION TESTS
%% =========================

exchange_option_creation_test() ->
    %% Create an exchange option
    Pid = instrument_custom:exchange(asset_a, asset_b),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {transform, diff, {observe, {multi, [asset_a, asset_b]}}} = maps:get(contract, State).

%% =========================
%% RAINBOW OPTION TESTS
%% =========================

rainbow_option_creation_test() ->
    %% Create a rainbow option (best of)
    Pid = instrument_custom:rainbow_best([stock1, stock2, stock3]),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {transform, max_of, {observe, {multi, [stock1, stock2, stock3]}}} = maps:get(contract, State).

%% =========================
%% BARRIER OPTION TESTS
%% =========================

barrier_option_creation_test() ->
    %% Create a barrier option
    InnerContract = {observe, {terminal, stock}},
    Pid = instrument_custom:barrier(up_and_in, 110, InnerContract),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {barrier, up_and_in, 110, {observe, {terminal, stock}}} = maps:get(contract, State).

%% =========================
%% FORWARD START OPTION TESTS
%% =========================

forward_start_creation_test() ->
    %% Create a forward start option
    InnerContract = {observe, {terminal, stock}},
    Pid = instrument_custom:forward_start(1.0, InnerContract),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {'when', {'after', 1.0}, {observe, {terminal, stock}}} = maps:get(contract, State).

%% =========================
%% CHOOSER OPTION TESTS
%% =========================

chooser_option_creation_test() ->
    %% Create a chooser option
    CallContract = {transform, {binary, 100}, {observe, {terminal, stock}}},
    PutContract = {transform, {binary, 100}, {observe, {terminal, stock}}},
    Pid = instrument_custom:chooser(1.0, CallContract, PutContract),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {'when', {'at', 1.0}, {choice, CallContract, PutContract}} = maps:get(contract, State).

%% =========================
%% LOOKBACK OPTION TESTS
%% =========================

lookback_option_creation_test() ->
    %% Create a lookback option
    Pid = instrument_custom:lookback(stock),
    
    %% Verify it's a valid PID
    true = is_pid(Pid),
    
    %% Describe the contract
    State = instrument_server:describe(Pid),
    
    %% Verify contract structure
    {observe, {path_max, stock}} = maps:get(contract, State).

%% =========================
%% VANILLA IRS TESTS
%% =========================

vanilla_irs_creation_test() ->
    %% Create a vanilla IRS
    Pid = instrument_custom:vanilla_irs(fixed_rate, floating_rate),
    
    %% Verify it's a valid PID
    true = is_pid(Pid).

%% =========================
%% EQUITY SWAP TESTS
%% =========================

equity_swap_creation_test() ->
    %% Create an equity swap
    Pid = instrument_custom:equity_swap(equity_return, cash_flow),
    
    %% Verify it's a valid PID
    true = is_pid(Pid).

%% =========================
%% VOL SWAP TESTS
%% =========================

vol_swap_creation_test() ->
    %% Create a volatility swap
    Pid = instrument_custom:vol_swap(realized_vol, strike_vol),
    
    %% Verify it's a valid PID
    true = is_pid(Pid).
