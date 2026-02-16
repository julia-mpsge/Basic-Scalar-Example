import settings;
//settings.prc = false;
settings.outformat="png";
settings.render = 16;
interactiveView=false;
batchView=false;

size(300,300);


label("$X$", (0,0));
label("$t=0$", (0,0), 3*N, fontsize(10));
label("$s=0.5$", (0,0), 3*S, fontsize(10));


//outputs
picture px_box;

label(px_box, "$PX$, 120", (0,0));
//label(px_box, "$RA \Rightarrow {\rm Output\_Tax}[s]$", (0,0), 2*S);

pair PX = (0,5);
draw( (0,0)--PX, Arrow, Margin(5,5) );
add(px_box, PX);


//inputs

picture py_box;
label(py_box, "$PY$, 20", (0,0));

//picture va_box;
//label(va_box, "$PVA[va={\rm value\_added}]$, ${\rm Value\_Added}[va,s]$", (0,0));

picture pk_box;
label(pk_box, "$PK$, 60", (0,0));
label(pk_box, "$CONS \Rightarrow TX\_PK$", (0,0), 2*S);

picture pl_box;
label(pl_box, "$PL$, 40", (0,0));
label(pl_box, "$CONS \Rightarrow TX\_PL$", (0,0), 2*S);


pair PA = (-5,-5);
pair VA_nest = (5,-5);
//pair VA = (5,-10);
pair PK = (0, -10);
pair PL = (10, -10);

draw( PA -- (0, 0), Arrow, Margin(5,8) );
add(py_box, PA);

draw( VA_nest -- (0,0), Arrow, Margin(2,8) );
label("$va = 1$", VA_nest);

draw( PK -- VA_nest, Arrow, Margin(5,3) );
add(pk_box, PK);

draw( PL -- VA_nest, Arrow, Margin(5,3) );
add(pl_box, PL);