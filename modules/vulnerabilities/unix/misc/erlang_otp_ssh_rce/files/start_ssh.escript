#!/usr/bin/env escript
%%! -sname ssh_runner

main([PortStr]) ->
    Port = list_to_integer(PortStr),
    
    io:format("Starting Erlang SSH daemon on port ~p~n", [Port]),
    
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssh),

    KeyDir = "/opt/erlang_ssh/ssh_keys",
    
    case ssh:daemon(Port, [
        {system_dir, KeyDir},
        {auth_methods, "password"},
        {user_passwords, [{"admin", "admin123"}]},
        {idle_time, infinity}
    ]) of
        {ok, Pid} ->
            io:format("SSH daemon started successfully on port ~p, pid: ~p~n", [Port, Pid]),
            receive
                stop -> ok
            end;
        {error, Reason} ->
            io:format("Failed to start SSH daemon: ~p~n", [Reason]),
            halt(1)
    end.