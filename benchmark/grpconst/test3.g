#description Construct and test all groups of orders from 257 to 511
#author Alexander Konovalov
#timelimit 1
#cmdlineops
#packages: grpconst

Read("grpconst.g" );

has_errors:=false;

starttime:=Runtime();

for i in [257..511] do
    Print("Constructing and testing all groups of order ", i, "\n");
    ConstructAndTestAllGroups( i );
od;
    
Print("*** RUNTIME ",Runtime()-starttime,"\n");

if has_errors then
  Print("*** FAIL\n");
  QUIT_GAP(1);
else
  QUIT_GAP(0);
fi;
