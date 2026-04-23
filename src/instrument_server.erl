-module(instrument_server).
-behaviour(gen_server).

-export([start_link/1, value/2, risk/2, describe/1, update_price/2]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2]).


%% API calls


start_link(State) ->
    gen_server:start_link(?MODULE, State, []).

value(Pid, Env) ->
    gen_server:call(Pid, {value, Env}).

risk(Pid, Env) ->
    gen_server:call(Pid, {risk, Env}).

describe(Pid) ->
    gen_server:call(Pid, describe).

update_price(Pid, Price) ->
    gen_server:cast(Pid, {market_update, Price}).

%% =========================
%% OTP Callbacks
%% =========================

init(State) ->
    %% NEW: ensure path exists in state why? 
    case maps:is_key(path, State) of
        true -> {ok, State};
        false -> {ok, State#{path => []}}
    end.

handle_call(describe, _From, State) ->
    {reply, State, State};

handle_call({value, Env}, _From, State) ->
    {reply, eval(State, Env), State};

%% REMOVED: old risk_eval logic tied to types
handle_call({risk, _Env}, _From, State) ->
    {reply, 0, State};

handle_call(_, _, State) ->
    {reply, error, State}.


%% MARKET UPDATE (IMPORTANT CHANGE)


%% OLD (REMOVED):
%% handle_cast({market_update, Price}, State) ->
%%     NewState = barrier_logic:transition(State, Price),
%%     {noreply, NewState};

%% NEW: store price path instead of FSM transition
handle_cast({market_update, Price}, State) ->
    Path = maps:get(path, State, []),
    NewState = State#{path => [Price | Path]},
    {noreply, NewState};

handle_cast(_, State) ->
    {noreply, State}.

terminate(_, _) ->
    ok.

%% =========================
%% CORE CHANGE: DSL EVALUATION
%% =========================

%% OLD (REMOVED):
%% eval(#{type := base_instrument, ...}) -> ...
%% eval(#{type := derivative, ...}) -> ...
%% eval(#{type := bond, ...}) -> ...

%% NEW: generic interpreter entry point
eval(#{contract := C} = State, Env) ->
    %% merge runtime path into Env
    Path = maps:get(path, State, []),
    FullEnv = Env#{path => Path},
    value_contract(C, FullEnv).


%% DSL ALGEBRA  INTERPRETER

%% -------- Observation --------

value_contract({observe, {terminal, Asset}}, Env) ->
    maps:get({Asset, terminal}, Env, 0);

value_contract({observe, {multi, Assets}}, Env) ->
    [maps:get({A, terminal}, Env, 0) || A <- Assets];

value_contract({observe, {path_max, Asset}}, Env) ->
    lists:max(maps:get(path, Env, []));

value_contract({observe, {path_min, Asset}}, Env) ->
    lists:min(maps:get(path, Env, []));

%% -------- Transformation --------

value_contract({transform, {binary, K}, C}, Env) ->
    case value_contract(C, Env) of
        V when V > K -> 1;
        _ -> 0
    end;

value_contract({transform, diff, C}, Env) ->
    [A, B] = value_contract(C, Env),
    max(A - B, 0);

value_contract({transform, max_of, C}, Env) ->
    lists:max(value_contract(C, Env));

value_contract({transform, min_of, C}, Env) ->
    lists:min(value_contract(C, Env));

%% -------- Temporal --------

value_contract({'when', {'at', T}, C}, Env) ->
    case maps:get(time, Env, undefined) of
        T -> value_contract(C, Env);
        _ -> 0
    end;

value_contract({'when', {'after', T}, C}, Env) ->
    case maps:get(time, Env, 0) >= T of
        true -> value_contract(C, Env);
        false -> 0
    end;

%% -------- Composition --------

value_contract({choice, C1, C2}, Env) ->
    max(value_contract(C1, Env), value_contract(C2, Env));

value_contract({combine, add, C1, C2}, Env) ->
    value_contract(C1, Env) + value_contract(C2, Env);

%% -------- Barrier --------

value_contract({barrier, Type, Level, C}, Env) ->
    case barrier_hit(Type, Level, Env) of
        true -> value_contract(C, Env);
        false -> 0
    end;
%% ---------- CONSTANT ----------
value_contract({constant, X}, _) ->
    X;

%% ---------- LEG ----------
value_contract({leg, pay, C}, Env) ->
    - value_contract(C, Env);

value_contract({leg, 'receive', C}, Env) ->
    value_contract(C, Env);

%% ---------- SWAP ----------
value_contract({swap, L1, L2, _OTC}, Env) ->
    value_contract(L1, Env) + value_contract(L2, Env);


%% -------- Default [always last as vanilla]--------

value_contract(_, _) ->
    0.

%% =========================
%% BARRIER HELPERS
%% =========================

barrier_hit(up_and_in, B, Env) ->
    lists:max(maps:get(path, Env, [0])) >= B;

barrier_hit(down_and_in, B, Env) ->
    lists:min(maps:get(path, Env, [0])) =< B;

barrier_hit(up_and_out, B, Env) ->
    not (lists:max(maps:get(path, Env, [0])) >= B);

barrier_hit(down_and_out, B, Env) ->
    not (lists:min(maps:get(path, Env, [0])) =< B).