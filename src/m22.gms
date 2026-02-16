$TITLE Model M22: Closed Economy 2X2 with Intermediate Inputs and Nesting
$ONTEXT
 Production Sectors Consumers
 Markets | X Y W | CONS
 ------------------------------------------------------
 PX | 120 -20 -100 |
 PY | -20 120 -100 |
 PW | 200 | -200
 PL | -40 -60 | 100
 PK | -60 -40 | 100
 ------------------------------------------------------

$OFFTEXT
PARAMETERS
    TX_PL,
    TX_PK;

TX_PL = 0;
TX_PK = 0;

$ONTEXT
$MODEL: M22

$SECTORS:
    X ! Activity level for sector X
    Y ! Activity level for sector Y
    W ! Activity level for sector W (Hicksian welfare index)

$COMMODITIES:
    PX ! Price index for commodity X
    PY ! Price index for commodity Y
    PL ! Price index for primary factor L
    PK ! Price index for primary factor K
    PW ! Price index for welfare (expenditure function)

$CONSUMERS:
    CONS ! Income level for consumer CONS

$PROD:X s:0.5 va:1
    O:PX Q:120
    I:PY Q: 20
    I:PL Q: 40 va: A:CONS T:TX_PL
    I:PK Q: 60 va: A:CONS T:TX_PK

$PROD:Y s:0.75 va:1
    O:PY Q:120
    I:PX Q: 20
    I:PL Q: 60 va:
    I:PK Q: 40 va:

$PROD:W s:1
    O:PW Q:200
    I:PX Q:100
    I:PY Q:100

$DEMAND:CONS
    D:PW Q:200
    E:PL Q:100
    E:PK Q:100
$OFFTEXT
$SYSINCLUDE mpsgeset M22

PW.FX = 1;
M22.iterlim = 0;
$INCLUDE M22.GEN
SOLVE M22 USING MCP;

* Counterfactual
TX_PL = .8;
TX_PK = .5;

M22.iterlim = 10000;
$INCLUDE M22.GEN
SOLVE M22 USING MCP;
