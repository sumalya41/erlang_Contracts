-module(instruments_SUITE).
-include_lib("eunit/include/eunit.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).

%% Test functions
-export([
    terminal_observation_test/0,
    path_observation_test/0,
    constant_test/0,
    binary_transformation_test/0,
    diff_transformation_test/0,
    max_of_transformation_test/0,
    min_of_transformation_test/0,
    add_composition_test/0,
    choice_composition_test/0
]).

all() ->
    [
        terminal_observation_test,
        path_observation_test,
        constant_test,
        binary_transformation_test,
        diff_transformation_test,
        max_of_transformation_test,
        min_of_transformation_test,
        add_composition_test,
        choice_composition_test
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

%% =========================
%% OBSERVATION TESTS
%% =========================

terminal_observation_test() ->
    %% Verify terminal observation structure
    Obs = instruments:terminal(stock),
    {observe, {terminal, stock}} = Obs,
    
    %% Multiple assets
    Obs2 = instruments:terminal(a),
    {observe, {terminal, a}} = Obs2.

path_observation_test() ->
    %% Verify path observation structure
    Obs = instruments:path(stock),
    {observe, {path, stock}} = Obs,
    
    %% Different asset
    Obs2 = instruments:path(commodity),
    {observe, {path, commodity}} = Obs2.

%% =========================
%% CONSTANT TEST
%% =========================

constant_test() ->
    %% Verify constant wrapping
    C1 = instruments:constant(100),
    {constant, 100} = C1,
    
    C2 = instruments:constant(50.5),
    {constant, 50.5} = C2,
    
    C3 = instruments:constant(0),
    {constant, 0} = C3.

%% =========================
%% BINARY TRANSFORMATION TESTS
%% =========================

binary_transformation_test() ->
    %% Digital option: 1 if S > K
    Obs = instruments:terminal(stock),
    Binary = instruments:binary(100, Obs),
    
    {transform, {binary, 100}, {observe, {terminal, stock}}} = Binary.

%% =========================
%% DIFF TRANSFORMATION TESTS
%% =========================

diff_transformation_test() ->
    %% Spread: max(A - B, 0)
    Diff = instruments:diff(a, b),
    {transform, diff, {observe, {multi, [a, b]}}} = Diff.

%% =========================
%% MAX_OF TRANSFORMATION TESTS
%% =========================

max_of_transformation_test() ->
    %% Rainbow best: max of assets
    MaxOf = instruments:max_of([a, b, c]),
    {transform, max_of, {observe, {multi, [a, b, c]}}} = MaxOf.

%% =========================
%% MIN_OF TRANSFORMATION TESTS
%% =========================

min_of_transformation_test() ->
    %% Minimum of multiple assets
    MinOf = instruments:min_of([x, y, z]),
    {transform, min_of, {observe, {multi, [x, y, z]}}} = MinOf.

%% =========================
%% COMPOSITION TESTS
%% =========================

add_composition_test() ->
    %% Combine two contracts with addition
    C1 = instruments:constant(100),
    C2 = instruments:constant(50),
    Add = instruments:add(C1, C2),
    
    {combine, add, {constant, 100}, {constant, 50}} = Add.

choice_composition_test() ->
    %% Choice between two contracts
    C1 = instruments:constant(100),
    C2 = instruments:constant(50),
    Choice = instruments:choice(C1, C2),
    
    {choice, {constant, 100}, {constant, 50}} = Choice.
