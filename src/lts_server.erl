-module(lts_server).
-export([start/0, loop/0, parse_ccs0/1, parse/2]).

%----------------------------%
% LADO DO SERVIDOR

% funcao de traducao ccs0 para lts
parse_ccs0(CCS0) -> CCS0+1.

start() ->
    spawn(fun() -> loop() end).

loop() ->
    receive
        % cliente pede que o servidor feche a comunicacao
        {quit, From} ->
            From ! {response, io:format("Server will close down")};

        {parse, From, CCS0} ->
            From ! {response, parse_ccs0(CCS0)},
            loop();

        {Other, From} ->
            From ! {self(), {error, Other}},
            loop()
    end.

%----------------------------%
% LADO DO CLIENTE

parse(Server, CCS0) ->
    Server ! {parse, self(), CCS0},
    receive
        {response, Result} ->
            Result
    end.