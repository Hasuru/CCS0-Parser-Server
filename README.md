# Tradutor de expressões CCS0 para LTS

Projeto que consiste no desenvolvimento de um algoritmo em **erlang** que permite a tradução de CSS0 em formato AST para a sua devida forma em LTS (Label Transition System), utilizando um pequeno servidor de comunicações.

<hr>

## CCS

Expressões CSS indicam-nos como um programa deve ser executado, utilizando um sistema de **Processos** e **Ações**:

- **Exemplo** : *a.b.c.0* indica-nos que deveremos executar a ação c apenas depois da ação b ser executada, que por observação, só pode ser executada depois da ação a.
- Neste caso o conjunto *{a,b,c}* são as ações da expressão e *0* é o processo da expressão (denominado de **Processo Deadlock**). Por regra a.b.c.0 é também considerado um processo como um todo.

<br>

No caso do CSS0, temos sempre a certeza que o processo termina em **deadlock**.
Poderemos ter também múltiplas formas de executar um processo, ou seja:

- *a.(b.0 + c.0)* indica-nos que depois de executarmos a ação *a*, podemos continuar a execução do processo de duas maneiras distintas:
    - Executamos *b* e chegamos a deadlock sem nunca executar *c* ;
    - Executamos *c* e chegamos a deadlock sem nunca executar *b* .

<hr>

## Codificação de CSS0 para AST

A sintaxe codificante da expressão CSS0 poderá ser descrita como:

- *a.b.(c.0 + d.0)* => **{"a", {"b", {choice {{"c", zero}, {"d", zero}}}}}**

<br>

Indicamos cada um dos estados como uma **string()** (tipo próprio do erlang), e defenimos a divisão de caminhos com a palavra chave **choice**.

<hr>

## LTS (Label Transition System)

O LTS consiste em um triplo (S, ->, s) em que:

- S : Conjunto de estados do sistema;
- -> : Função Transição **(s{i}, alpha, s{i+1})** (podemos mudar de estado de *s{i}* para *s{i+1}* através da ação *alpha*);
- s : Estado inicial do sistema.

<br>

O servidor retorna uma lista que contem todas as funções transição recebidas em formato CCS0, ou seja, a resposta do servidor à expressão indicada em cima seria:

- **[{s1, a, s2}, {s2, b, s3}, {s3, b, s4}, {s4, c, sf}, {s4, d, sf}]** onde:
    - s1 = "a";
    - s2 = {"b", {choice, {{"c", zero}, {"d", zero}}};
    - s3 = {"c", zero};
    - s4 = {"d", zero};
    - sf = zero.

<hr>

## Compilação e Execução

Para executar o código deve:

- Tranferir o ficheiro **lts_server.erl** ;
- Abrir o intepretador erlang (erl na consola) ;
- `c(lts_server).` ;
- `Servidor = lts_server:start().` ;
- `lts_server:translate(Servidor, AST_CCS0).` ;

O termo AST_CSS0 pode ser introduzido na função translate, como pode ser associado a uma variável e introduzido na função.

- exemplo : AST_CSS0 = {"a", {"b", {choice, {{"c", zero}, {"d", zero}}}}} . 
