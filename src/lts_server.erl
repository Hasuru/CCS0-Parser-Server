-module(lts_server).
-export([start/0, loop/0, join/1, ccs0_to_lts/4, translate/2]).

%----------------------------%
% LADO DO SERVIDOR

-type ccs0() :: {string(), zero}
              | {string(), ccs0()}
              | {choice, ccs0(), ccs0()}.

% estupido, mas funciona
join(State) ->
    lists:map(fun(I)->
        list_to_atom(lists:flatten(io_lib:format("s~B", [I])))
        end, lists:seq(State,State)).

% funcao de traducao ccs0 para lts
% especificar que recebe ccs0 como argumento
-spec ccs0_to_lts(ccs0(), string(), number(), Res) -> Res.

% Teste (que nao funciona nao sei pq)
ccs0_to_lts(Ast, LastRead, CurState, Res) ->
    io_lib:format(Ast),
    Res.
%ccs0_to_lts({State, zero}, LastRead, CurState, Res) ->
%    [H1|_] = join(CurState),
%    Res ++ [{H1, 
%            list_to_atom(State), 
%            s0}].
%ccs0_to_lts({State, AST}, LastRead, CurState, Res) ->
%    [H1|_] = join(CurState),
%    [H2|_] = join(CurState+1),
%    Res ++ 
%    [{H1, list_to_atom(State), H2}] ++
%    ccs0_to_lts(AST, State, CurState+1, Res).
%ccs0_to_lts({choice, Left, Right}, LastRead, CurState, Res) ->
%    [H1|_] = join(CurState),
%    [H2|_] = join(CurState+1),
%    [H3|_] = join(CurState+2),
%    Res ++
%    [{H1, list_to_atom(LastRead), H2}, {H1, list_to_atom(LastRead), H3}] ++
%    ccs0_to_lts(Left, LastRead, CurState+1, Res) ++
%    ccs0_to_lts(Right, LastRead, CurState+2, Res).

start() ->
    spawn(fun() -> loop() end).

loop() ->
    receive
        % Pedido de paragem do servidor
        {quit, From} ->
            ok;

        % Pedido sobre o status do servidor
        {status, From} ->
            From ! {self()},
            loop();

        {translate, From, AST} ->
            From ! {response, ccs0_to_lts(AST, "", 1, [])},
            loop();

        {Other, From} ->
            From ! {self(), {error, Other}},
            loop()
    end.

%----------------------------%
% LADO DO CLIENTE

translate(Server, AST) ->
    Server ! {translate, self(), AST},
    receive
        {response, Result} ->
            Result
    end.