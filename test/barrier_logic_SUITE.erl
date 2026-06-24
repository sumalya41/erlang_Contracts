-module(barrier_logic_SUITE).
-include_lib("eunit/include/eunit.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).

%% Test functions
-export([
    up_and_in_activation_test/0,
    down_and_in_activation_test/0,
    up_and_out_expiry_test/0,
    down_and_out_expiry_test/0,
    no_transition_test/0,
    barrier_boundary_conditions_test/0
]).

all() ->
    [
        up_and_in_activation_test,
        down_and_in_activation_test,
        up_and_out_expiry_test,
        down_and_out_expiry_test,
        no_transition_test,
        barrier_boundary_conditions_test
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

%% =========================
%% UP-AND-IN TESTS
%% =========================

up_and_in_activation_test() ->
    %% Barrier at 110, price 100 -> stays dormant
    S1 = #{type => up_and_in, state => dormant, barrier => 110},
    S1 = barrier_logic:transition(S1, 100),
    
    %% Price hits barrier 110 -> becomes active
    S2 = barrier_logic:transition(S1, 110),
    active = maps:get(state, S2),
    
    %% Price exceeds barrier -> stays active
    S3 = barrier_logic:transition(S2, 120),
    active = maps:get(state, S3).

%% =========================
%% DOWN-AND-IN TESTS
%% =========================

down_and_in_activation_test() ->
    %% Barrier at 90, price 100 -> stays dormant
    S1 = #{type => down_and_in, state => dormant, barrier => 90},
    S1 = barrier_logic:transition(S1, 100),
    
    %% Price hits barrier 90 -> becomes active
    S2 = barrier_logic:transition(S1, 90),
    active = maps:get(state, S2),
    
    %% Price goes below barrier -> stays active
    S3 = barrier_logic:transition(S2, 80),
    active = maps:get(state, S3).

%% =========================
%% UP-AND-OUT TESTS
%% =========================

up_and_out_expiry_test() ->
    %% Start active, barrier at 120
    S1 = #{type => up_and_out, state => active, barrier => 120},
    
    %% Price below barrier -> stays active
    S2 = barrier_logic:transition(S1, 100),
    active = maps:get(state, S2),
    
    %% Price hits barrier 120 -> expires
    S3 = barrier_logic:transition(S2, 120),
    expired = maps:get(state, S3),
    
    %% Once expired, stays expired
    S4 = barrier_logic:transition(S3, 100),
    expired = maps:get(state, S4).

%% =========================
%% DOWN-AND-OUT TESTS
%% =========================

down_and_out_expiry_test() ->
    %% Start active, barrier at 80
    S1 = #{type => down_and_out, state => active, barrier => 80},
    
    %% Price above barrier -> stays active
    S2 = barrier_logic:transition(S1, 100),
    active = maps:get(state, S2),
    
    %% Price hits barrier 80 -> expires
    S3 = barrier_logic:transition(S2, 80),
    expired = maps:get(state, S3),
    
    %% Once expired, stays expired
    S4 = barrier_logic:transition(S3, 100),
    expired = maps:get(state, S4).

%% =========================
%% NO TRANSITION TESTS
%% =========================

no_transition_test() ->
    %% State without matching conditions stays unchanged
    S = #{type => up_and_in, state => active, barrier => 110},
    S = barrier_logic:transition(S, 100),
    
    %% Unknown barrier type
    S2 = #{type => unknown_barrier, state => dormant, barrier => 100},
    S2 = barrier_logic:transition(S2, 150).

%% =========================
%% BOUNDARY CONDITIONS
%% =========================

barrier_boundary_conditions_test() ->
    %% Exact barrier hit for up-and-in
    S1 = #{type => up_and_in, state => dormant, barrier => 100},
    S1_new = barrier_logic:transition(S1, 100),
    active = maps:get(state, S1_new),
    
    %% Exact barrier hit for down-and-in
    S2 = #{type => down_and_in, state => dormant, barrier => 100},
    S2_new = barrier_logic:transition(S2, 100),
    active = maps:get(state, S2_new),
    
    %% Just below up-and-in barrier
    S3 = #{type => up_and_in, state => dormant, barrier => 100},
    S3 = barrier_logic:transition(S3, 99.99),
    
    %% Just above down-and-in barrier
    S4 = #{type => down_and_in, state => dormant, barrier => 100},
    S4 = barrier_logic:transition(S4, 100.01).
