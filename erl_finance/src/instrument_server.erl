-module(instrument_server).
-behaviour(gen_server).

-export([start_link/1, value/2, risk/2, describe/1]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2]).

start_link(State) ->
    gen_server:start_link(?MODULE, State, []).

value(Pid, Env) ->
    gen_server:call(Pid, {value, Env}).

risk(Pid, Env) ->
    gen_server:call(Pid, {risk, Env}).

describe(Pid) ->
    gen_server:call(Pid, describe).

init(State) ->
    {ok, State}.

handle_call(describe, _From, State) ->
    {reply, State, State};

handle_call({value, Env}, _From, State) ->
    {reply, eval(State, Env), State};

handle_call({risk, Env}, _From, State) ->
    {reply, risk_eval(State, Env), State};

handle_call(_, _, State) ->
    {reply, error, State}.

handle_cast(_, State) ->
    {noreply, State}.

terminate(_, _) ->
    ok.

%% ===== Logic =====

eval(#{type := base_instrument, data := Data}, _) ->
    maps:get(value, Data, 0);

eval(#{type := derivative, data := Data, children := [Underlying]}, Env) ->
    UnderVal = gen_server:call(Underlying, {value, Env}),
    Strike = maps:get(strike, Data, 0),
    erlang:max(UnderVal - Strike, 0);

eval(#{type := bond, data := Data}, _) ->
    Notional = maps:get(notional, Data, 0),
    Rate = maps:get(rate, Data, 0),
    Notional * (1 + Rate);

eval(#{type := custom_contract, data := Data}, Env) ->
    Fun = maps:get(payout_logic, Data),
    Fun(Env).

risk_eval(#{type := base_instrument}, _) ->
    0;

risk_eval(#{type := derivative, children := [Underlying]}, Env) ->
    gen_server:call(Underlying, {risk, Env});

risk_eval(#{type := bond, data := Data}, _) ->
    maps:get(notional, Data, 0) * 0.01;

risk_eval(#{type := custom_contract}, _) ->
    0.