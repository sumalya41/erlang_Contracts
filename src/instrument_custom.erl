-module(instrument_custom).
-export([
    start/0, digital/2, exchange/2, rainbow_best/1, forward_start/2,
    chooser/3, lookback/1,barrier/3, %% /N args taken by the function
    vanilla_irs/2, equity_swap/2, vol_swap/2,bilateral_swap/3 ]). %% New: added bilateral swap with 3 args (counterparty risk)

%% =========================
%% START SUPERVISOR
%% =========================

start() ->
    instrument_sup:start_link().

%% =========================
%% INTERNAL HELPER
%% =========================

start_instrument(State) ->
    case supervisor:start_child(instrument_sup, [State]) of
        {ok, Pid} -> Pid;
        {error, Reason} -> exit(Reason)
    end.

%% =========================
%% DSL CONSTRUCTORS
%% =========================

%% -------------------------
%% Digital Option
%% -------------------------
%% Payoff: 1 if S_T > K else 0
digital(Asset, K) ->
    C =
        {transform, {binary, K},
            {observe, {terminal, Asset}}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Exchange Option
%% -------------------------
%% Payoff: max(S1 - S2, 0)
exchange(A1, A2) ->
    C =
        {transform, diff,
            {observe, {multi, [A1, A2]}}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Rainbow Option (Best-of)
%% -------------------------
rainbow_best(Assets) ->
    C =
        {transform, max_of,
            {observe, {multi, Assets}}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Forward Start Option
%% -------------------------
forward_start(T, Contract) ->
    C =
        {'when', {'after', T}, Contract},
    start_instrument(#{contract => C}).

%% -------------------------
%% Chooser Option
%% -------------------------
chooser(T, Call, Put) ->
    C =
        {'when', {'at', T},
            {choice, Call, Put}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Lookback Option
%% -------------------------
lookback(Asset) ->
    C =
        {observe, {path_max, Asset}},
    start_instrument(#{contract => C}).

%% -------------------------
%% Barrier Option
%% -------------------------
barrier(Type, Level, Contract) ->
    C =
        {barrier, Type, Level, Contract},
    start_instrument(#{contract => C}).

%% =========================
%% 🔥 SWAP CONTRACTS (NEW)
%% =========================

%% -------------------------
%% Vanilla IRS
%% -------------------------
vanilla_irs(FixedRate, FloatRateTag) ->
    C =
        {swap,
            {leg, pay,
                {constant, FixedRate}},
            {leg, 'receive',
                {observe, {rate, FloatRateTag}}},
            {otc, csa}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Equity Swap
%% -------------------------
equity_swap(Asset, FloatTag) ->
    C =
        {swap,
            {leg, pay,
                {observe, {rate, FloatTag}}},
            {leg, 'receive',
                {combine, add,
                    {transform, return,
                        {observe, {path, Asset}}},
                    {transform, dividend,
                        {observe, {path, Asset}}}
                }},
            {otc, dividend_pass_through}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Volatility Swap
%% -------------------------
vol_swap(Asset, FixedVol) ->
    C =
        {swap,
            {leg, pay,
                {constant, FixedVol}},
            {leg, 'receive',
                {transform, realized_vol,
                    {observe, {path, Asset}}}},
            {otc, variance}
        },
    start_instrument(#{contract => C}).

%% -------------------------
%% Bilateral Swap (Generic)
%% -------------------------
bilateral_swap(C1, C2, OTC) ->
    C =
        {swap,
            {leg, pay, C1},
            {leg, 'receive', C2},
            OTC
        },
    start_instrument(#{contract => C}).