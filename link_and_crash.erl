-module(link_and_crash).
-export([worker/0, test_worker/0]).
-export([chain/1, test_chain/0]).

%%
worker() ->
    io:format("Process: ~p . This is worker.~n", [self()]),
    timer:sleep(5000),
    exit(some_reason).

test_worker() ->
    link(spawn(fun link_and_crash:worker/0)).


chain(1) ->
    io:format("Process number: ~p, PID: ~p~n", [1, self()]),
    receive
        _ -> ok
    after 2000 ->
        exit("chain is broken")
    end;
chain(N) ->
    Pid = spawn(fun() -> chain(N - 1) end),
    io:format("Process number: ~p, PID: ~p~n", [N, self()]),
    link(Pid),
    receive
        _ -> ok
    end.

test_chain() ->
    link(spawn(link_and_crash, chain, [10])).