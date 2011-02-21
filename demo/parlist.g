#
# Workers communicate
#
#

ParList1 := function(l, f, n)
    local   inch,  outch,  worker,  threads,  count,  res,  i,  x,  t;
    inch := CreateChannel();
    outch := CreateChannel();
    worker := function()
        local   x;
        while true do
            x := ReceiveChannel(inch);
            # x should be mine now since it has come through the channel
            # x[1] is always a public object
            if x[1] = fail then
                return;
            fi;
            atomic readonly x[2] do    
                x[2] := f(x[2]);    
            od;
            SendChannel(outch, x);
        od;
    end;
    threads := List([1..n], i->CreateThread(worker));
    count := 0;
    res := [];
    for i in [1..Length(l)] do
        SHARE(l[i]);
        atomic readonly l[i] do
            SendChannel(inch, [i,l[i]]);
        od;
        while true do
            x := TryReceiveChannel(outch,fail);
            if x = fail then
                break;
            fi;
            res[x[1]] := x[2];
            count := count+1;
        od;
    od;
    for i in [1..n] do
        SendChannel(inch, [fail]);
    od;
    while count < Length(l) do
        x := ReceiveChannel(outch);
        if x = fail then
            break;
        fi;
        res[x[1]] := x[2];
        count := count+1;
    od;
    for t in threads do
        WaitThread(t);
    od;
    DestroyChannel(inch);
    DestroyChannel(outch);
    return res;
end;

ParList2 := function(l, f, n)
    local   inch,  worker,  threads,  res,  i,  t;
    inch := CreateChannel();
    worker := function()
        local   x;
        while true do
            x := ReceiveChannel(inch);
            if x = fail then
                    return;
            fi;
            res[x] := f(res[x]);    
        od;
    end;    
    threads := List([1..n], i->CreateThread(worker));
    res := PlainListCopy(l);
    for i in [1..Length(l)] do
        SendChannel(inch, i);
    od;
    for i in [1..n] do
        SendChannel(inch, fail);
    od;
    for t in threads do
        WaitThread(t);
    od;
    DestroyChannel(inch);
    return res;
end;

BlockedParlist:= function(ParListFun, blocking)
    return function(l,f,n)
        local   len,  blocks,  i,  j;
        len := Length(l);
        blocks := [];
        i := 1;
        j := i+blocking-1;
        while j <= len do
            Add(blocks, l{[i..j]});
            i := i+blocking;
            j := j+blocking;
        od;
        if i <= len then
            Add(blocks,l{[i..len]});
        fi;
        return Concatenation(ParListFun(blocks, block -> List(block, f), n));
    end;
end;
            

