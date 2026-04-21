-module(instrument_custom).
-export([start/0, base/1, derivative/3, bond/3, custom/1]).

start() ->
    instrument_sup:start_link().

start_instrument(State) ->
    case supervisor:start_child(instrument_sup, [State]) of
        {ok, Pid} -> Pid;
        {error, Reason} -> exit(Reason)
    end.

base(Value) ->
    State = #{
        type => base_instrument,
        data => #{value => Value},
        children => []
    },
    start_instrument(State).

derivative(UnderlyingPid, Strike, Expiry) ->
    State = #{
        type => derivative,
        data => #{
            strike => Strike,
            expiry => Expiry
        },
        children => [UnderlyingPid]
    },
    start_instrument(State).

bond(Notional, Rate, Subtype) ->
    State = #{
        type => bond,
        data => #{
            notional => Notional,
            rate => Rate,
            subtype => Subtype
        },
        children => []
    },
    start_instrument(State).

custom(Fun) ->
    State = #{
        type => custom_contract,
        data => #{
            payout_logic => Fun
        },
        children => []
    },
    start_instrument(State).