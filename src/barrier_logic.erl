-module(barrier_logic).

-export([transition/2]).


%% Barrier State Transitions


%% Up-and-In: Dormant → Active when Price ≥ Barrier
transition(#{type := up_and_in, state := dormant, barrier := B} = S, Price)
    when Price >= B ->
    S#{state => active};

%% Down-and-In: Dormant → Active when Price ≤ Barrier
transition(#{type := down_and_in, state := dormant, barrier := B} = S, Price)
    when Price =< B ->
    S#{state => active};

%% Up-and-Out: Active → Expired when Price ≥ Barrier
transition(#{type := up_and_out, state := active, barrier := B} = S, Price)
    when Price >= B ->
    S#{state => expired};

%% Down-and-Out: Active → Expired when Price ≤ Barrier
transition(#{type := down_and_out, state := active, barrier := B} = S, Price)
    when Price =< B ->
    S#{state => expired};

%% Default: No change
transition(S, _) ->
    S.