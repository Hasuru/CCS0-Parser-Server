-module(lts_server).
-export([start/0, loop/0, getState/1, ccs0_to_lts/4, clean_list/1, 
    clean_list/2, translate/2, quit/1, status/1]).

%----------------------------%
% LADO DO SERVIDOR

-type ast() :: {string(), zero}
             | {string(), ast()}
             | {choice, ast(), ast()}.

% estupido, mas funciona
getState(Trans) ->
    lists:map(fun(I)->
        list_to_atom(lists:flatten(io_lib:format("s~B", [I])))
        end, lists:seq(Trans,Trans)).

% funcao de traducao ccs0 para lts
% especificar que recebe ccs0 como argumento
-spec ccs0_to_lts(ast(), string(), number(), list()) -> list().

% Teste (que nao funciona nao sei pq)
% IT WORKS PERFECTLY
ccs0_to_lts({Trans, zero}, _ , CurState, Res) ->
    [H1|_] = getState(CurState),
    Res ++ [{H1, list_to_atom(Trans), sf}];
% IT ALSO WORKS
ccs0_to_lts({Trans, Ast}, _ , CurState, Res) ->
    [H1|_] = getState(CurState),
    [H2|_] = getState(CurState+1),
    Res ++ 
    [{H1, list_to_atom(Trans), H2}] ++
    ccs0_to_lts(Ast, Trans, CurState+1, Res);
ccs0_to_lts({choice, Left, Right}, LastTrans, CurState, Res) ->
    [H1|_] = getState(CurState-1),
    [H3|_] = getState(CurState+1), % RIGHT State
    Res ++
    [{H1, list_to_atom(LastTrans), H3}] ++
    ccs0_to_lts(Left, LastTrans, CurState, Res) ++
    ccs0_to_lts(Right, LastTrans, CurState+1, Res).

clean_list(L) -> clean_list(L, []).

clean_list([], Acc) -> Acc;
clean_list([H|T], Acc) ->
    if element(2, H) == '' ->
        clean_list(T, Acc);
    true ->
        clean_list(T, Acc ++ [H])
    end.

start() ->
    spawn(fun() -> loop() end).

loop() ->
    receive
        % Pedido de paragem do servidor
        {quit, _} ->
            ok;

        % Pedido sobre o status do servidor
        {status, From} ->
            From ! {response, self()},
            loop();

        {translate, From, Ast} ->
            From ! {response, clean_list(ccs0_to_lts(Ast, "", 1, []))},
            loop();

        {Other, From} ->
            From ! {self(), {error, Other}},
            loop()
    end.

%----------------------------%
% LADO DO CLIENTE

translate(Server, Ast) ->
    Server ! {translate, self(), Ast},
    receive
        {response, Result} ->
            Result
    end.

quit(Server) ->
    Server ! {quit, self()}.

status(Server) ->
    Server ! {status, self()},
    receive
        {response, Result} ->
            Result
    end.