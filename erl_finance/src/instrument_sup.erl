-module(instrument_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => simple_one_for_one,
        intensity => 5,
        period => 10
    },

    ChildSpec = #{
        id => instrument_server,
        start => {instrument_server, start_link, []},
        restart => transient,
        shutdown => 5000,
        type => worker,
        modules => [instrument_server]
    },

    {ok, {SupFlags, [ChildSpec]}}.