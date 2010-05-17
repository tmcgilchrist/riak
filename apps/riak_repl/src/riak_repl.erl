%% Riak EnterpriseDS
%% Copyright 2007-2009 Basho Technologies, Inc. All Rights Reserved.
-module(riak_repl).
-author('Andy Gross <andy@basho.com>').
-include("riak_repl.hrl").
-export([start/0, stop/0]).
-export([install_hook/0]).

start() ->
    ensure_started(sasl),
    ensure_started(crypto),
    ensure_started(riak_core),
    ensure_started(riak_kv),
    application:start(riak_repl).

%% @spec stop() -> ok
stop() -> 
    application:stop(riak_repl).

%% @spec ensure_started(Application :: atom()) -> ok
%% @doc Start the named application if not already started.
ensure_started(App) ->
    case application:start(App) of
	ok ->
	    ok;
	{error, {already_started, App}} ->
	    ok
    end.

install_hook() ->
    {ok, DefaultBucketProps} = application:get_env(riak_core, 
                                                   default_bucket_props),
    application:set_env(riak_core, default_bucket_props, 
                        proplists:delete(postcommit, DefaultBucketProps)),
    riak_core_bucket:append_bucket_defaults([{postcommit, [?REPL_HOOK]}]),
    ok.
    
