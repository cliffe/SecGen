#!/usr/bin/env escript
%%! -sname ssh_runner -noinput

main([PortStr]) ->
    Port = list_to_integer(PortStr),
    
    io:format("Starting Erlang SSH daemon on port ~p~n", [Port]),
    
    case application:ensure_all_started(ssh) of
        {ok, _StartedApps} ->
            ok;
        {error, StartReason} ->
            io:format("Failed to start ssh application dependencies: ~p~n", [StartReason]),
            halt(1)
    end,

    KeyDir = "/opt/erlang_ssh/ssh_keys",
    
    case ssh:daemon(Port, [
        {system_dir, KeyDir},
        {idle_time, infinity}
    ]) of
        {ok, Pid} ->
            io:format("SSH daemon started successfully on port ~p, pid: ~p~n", [Port, Pid]),
            receive
                stop -> ok
            end;
        {error, DaemonReason} ->
            io:format("Failed to start SSH daemon: ~p~n", [DaemonReason]),
            halt(1)
    end.