#############################################################################
##
#W  reesmat.gi           GAP library                           J. D. Mitchell
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2013 The GAP Group
##
##  This file contains the implementation of Rees matrix semigroups.
##

# Notes: there are essentially 3 types of semigroups here:
# 1) the whole family Rees matrix semigroup (notice that the matrix used to
# define the semigroup may contain rows or columns consisting entirely of 0s
# so it is not guarenteed that the resulting semigroup is 0-simple)
# 2) subsemigroups U of 1), which defined by a generating set and are Rees matrix
# semigroups, i.e. U=I'xG'xJ' where the whole family if IxGxJ and I', J' subsets
# of I, J and G' a subsemigroup of G. 
# 3) subsemigroups of 1) obtained by removing an index or element of the
# underlying semigroup, and hence are also Rees matrix semigroups.
# 4) subsemigroups of 1) defined by generating sets which are not
# simple/0-simple.

# So, the methods with filters IsRees(Zero)MatrixSemigroup and
# HasGeneratorsOfSemigroup only apply to subsemigroups of type 2).
# Subsemigroups of type 3 already know the values of Rows, Columns,
# UnderlyingSemigroup, and Matrix.

# a Rees matrix semigroup over a semigroup <S> is simple if and only if <S> is
# simple.

#

#InstallMethod(\<, "for Rees 0-matrix semigroups", 
#[IsReesZeroMatrixSemigroup, IsReesZeroMatrixSemigroup], 100,
#function(R, S)
#  return Size(R)<Size(S) or (Rows(R)<Rows(S) or (Rows(R)=Rows(S) and
#  Columns(R)<Columns(S)) or (Rows(R)=Rows(S) and Columns(R)=Columns(S) 
#    and UnderlyingSemigroup(R)<UnderlyingSemigroup(S)));
#end);

InstallMethod(IsFinite, "for a Rees matrix subsemigroup",
[IsReesMatrixSubsemigroup], 
function(R)
  return IsFinite(ParentAttr(R));
end);

InstallMethod(IsFinite, "for a Rees 0-matrix subsemigroup",
[IsReesZeroMatrixSubsemigroup], 
function(R)
  return IsFinite(ParentAttr(R));
end);

#

InstallMethod(IsIdempotent, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement], 
function(x)
  local R;

  R:=ReesMatrixSemigroupOfFamily(FamilyObj(x));
  if IsGroup(UnderlyingSemigroup(R)) then 
    # only for RZMS over groups!
    return x![1]=0 or x![2]^-1=x![4][x![3]][x![1]];
  else 
    return x ^ 2 = x;
  fi;
end);

#

InstallMethod(IsOne, "for a Rees matrix semigroup element", 
[IsReesMatrixSemigroupElement],
function(x)
  local R;
  R:=ReesMatrixSemigroupOfFamily(FamilyObj(x));
  if IsIdempotent(x) then 
    if Length(Rows(R))=1 and Length(Columns(R))=1 then 
      return true;
    else 
      return ForAll(GeneratorsOfSemigroup(R), y-> x*y=y and y*x=y);
    fi;
  fi;
  return false;
end);

#

InstallMethod(IsOne, "for a Rees 0-matrix semigroup element", 
[IsReesZeroMatrixSemigroupElement],
function(x)
  local R;
  R:=ReesMatrixSemigroupOfFamily(FamilyObj(x));
  if IsIdempotent(x) then 
    if Length(Rows(R))=1 and Length(Columns(R))=1 then 
      return true;
    else 
      return ForAll(GeneratorsOfSemigroup(R), y-> x*y=y and y*x=y);
    fi;
  fi;
  return false;
end);

#

InstallTrueMethod(IsRegularSemigroup, 
IsReesMatrixSemigroup and IsSimpleSemigroup);

#

InstallMethod(IsRegularSemigroup, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup], 
function(R)
  if IsGroup(UnderlyingSemigroup(R)) then 
    return ForAll(Rows(R), i-> ForAny(Columns(R), j-> Matrix(R)[j][i]<>0))
     and ForAll(Columns(R), j-> ForAny(Rows(R), i-> Matrix(R)[j][i]<>0));
  else
    TryNextMethod();
  fi;
end);

#

InstallMethod(IsSimpleSemigroup, 
"for a subsemigroup of a Rees matrix semigroup with an underlying semigroup", 
[IsReesMatrixSubsemigroup and HasUnderlyingSemigroup],
R-> IsSimpleSemigroup(UnderlyingSemigroup(R)));

# check that the matrix has no rows or columns consisting entirely of 0s
# and that the underlying semigroup is simple

InstallMethod(IsZeroSimpleSemigroup, "for a Rees 0-matrix semigroup", 
[IsReesZeroMatrixSemigroup],
function(R)
  local i;

  for i in Columns(R) do 
    if ForAll(Rows(R), j-> Matrix(R)[i][j]=0) then 
      return false;
    fi;
  od;
  
  for i in Rows(R) do 
    if ForAll(Columns(R), j-> Matrix(R)[j][i]=0) then 
      return false;
    fi;
  od;
  
  return IsSimpleSemigroup(UnderlyingSemigroup(R));
end);

#

InstallMethod(IsReesMatrixSemigroup, "for a semigroup", [IsSemigroup], ReturnFalse);

#

InstallMethod(IsReesMatrixSemigroup, 
"for a Rees matrix subsemigroup with generators", 
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R) 
  local gens, I, J;
  
  if IsWholeFamily(R) then 
    return true;
  elif IsSimpleSemigroup(UnderlyingSemigroup(ParentAttr(R))) 
   and not IsSimpleSemigroup(R) then 
    return false;
  fi;
  
  # it is still possible that <R> is a Rees matrix semigroup, if, for example,
  # we have a subsemigroup specified by generators which equals a subsemigroup
  # obtained by removing a row, in the case that <R> is not simple.
  gens:=GeneratorsOfSemigroup(R);
  I:=Set(List(gens, x-> x![1]));
  J:=Set(List(gens, x-> x![3]));

  return ForAll(GeneratorsOfReesMatrixSemigroupNC(ParentAttr(R), I, 
    Semigroup(List(Elements(R), x-> x![2])), J), x-> x in R);
end);

#

InstallMethod(IsReesZeroMatrixSemigroup, "for a semigroup", [IsSemigroup],
ReturnFalse);

#

InstallMethod(IsReesZeroMatrixSemigroup, 
"for a Rees 0-matrix subsemigroup with generators", 
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R) 
  local gens, pos, elts, I, J;
  
  if IsWholeFamily(R) then 
    return true;
  fi;

  # it is still possible that <R> is a Rees 0-matrix semigroup, if, for
  # example, we have a subsemigroup specified by generators which equals a
  # subsemigroup obtained by removing a row, in the case that <R> is not simple.
 
  if MultiplicativeZero(R)<>MultiplicativeZero(ParentAttr(R)) then 
    return false; #Rees 0-matrix semigroups always contain the 0.
  fi;
  
  gens:=GeneratorsOfSemigroup(R);
  pos:=Position(gens, MultiplicativeZero(R));
  if pos<>fail then 
    if Size(gens) = 1 then
      return Size(ParentAttr(R)) = 1;
    fi;
    gens:=ShallowCopy(gens);
    Remove(gens, pos);
  fi;
  
  elts:=ShallowCopy(Elements(R)); 
  RemoveSet(elts, MultiplicativeZero(R));

  I:=Set(List(gens, x-> x![1]));
  J:=Set(List(gens, x-> x![3]));
  
  return ForAll(GeneratorsOfReesZeroMatrixSemigroupNC(ParentAttr(R), I, 
    Semigroup(List(elts, x-> x![2])), J), x-> x in R);
end);

#

InstallMethod(ReesMatrixSemigroup, "for a semigroup and a rectangular table",
[IsSemigroup, IsRectangularTable], 
function(S, mat)
  local fam, R, type, x;
  
  for x in mat do 
    if ForAny(x, s-> not s in S) then
      Error("usage: the entries of <mat> must belong to <S>,");
      return;
    fi;
  od;

  fam := NewFamily( "ReesMatrixSemigroupElementsFamily",
          IsReesMatrixSemigroupElement);

  # create the Rees matrix semigroup
  R := Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and
   IsReesMatrixSubsemigroup and IsAttributeStoringRep ), rec() );

  # store the type of the elements in the semigroup
  type:=NewType(fam, IsReesMatrixSemigroupElement);
  
  fam!.type:=type;
  SetTypeReesMatrixSemigroupElements(R, type); 
  SetReesMatrixSemigroupOfFamily(fam, R);

  SetMatrix(R, mat);    SetUnderlyingSemigroup(R, S);
  SetRows(R, [1..Length(mat[1])]);   
  SetColumns(R, [1..Length(mat)]);
  
  if HasIsSimpleSemigroup(S) and IsSimpleSemigroup(S) then 
    SetIsSimpleSemigroup(R, true);
  fi;
  
  if HasIsFinite(S) then 
    SetIsFinite(R, IsFinite(S));
  fi;

  SetIsZeroSimpleSemigroup(R, false);
  return R;
end);

#

InstallMethod(ReesZeroMatrixSemigroup, "for a semigroup and a dense list",
[IsSemigroup, IsDenseList], 
function(S, mat)
  local fam, R, type, x;

  if not ForAll(mat, x-> IsDenseList(x) and Length(x)=Length(mat[1])) then 
    Error("usage: <mat> must be a list of dense lists of equal length,");
    return;
  fi;

  for x in mat do 
    if ForAny(x, s-> not (s=0 or s in S)) then
      Error("usage: the entries of <mat> must be 0 or belong to <S>,");
      return;
    fi;
  od;

  fam := NewFamily( "ReesZeroMatrixSemigroupElementsFamily",
          IsReesZeroMatrixSemigroupElement);

  # create the Rees matrix semigroup
  R := Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and
   IsReesZeroMatrixSubsemigroup and IsAttributeStoringRep ), rec() );

  # store the type of the elements in the semigroup
  type:=NewType(fam, IsReesZeroMatrixSemigroupElement);
  
  fam!.type:=type;
  SetTypeReesMatrixSemigroupElements(R, type); 
  SetReesMatrixSemigroupOfFamily(fam, R);

  SetMatrix(R, mat);                 SetUnderlyingSemigroup(R, S);
  SetRows(R, [1..Length(mat[1])]);   SetColumns(R, [1..Length(mat)]);
  SetMultiplicativeZero(R, 
   Objectify(TypeReesMatrixSemigroupElements(R), [0]));

  # cannot set IsZeroSimpleSemigroup to be <true> here since the matrix may
  # contain a row or column consisting entirely of 0s!

  if HasIsFinite(S) then 
    SetIsFinite(R, IsFinite(S));
  fi;
  GeneratorsOfSemigroup(R); 
  SetIsSimpleSemigroup(R, false);
  return R;
end);

#

InstallMethod(ViewObj, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], 3, #to beat the next method
function(R)
  Print("\>\><Rees matrix semigroup \>", Length(Rows(R)), "x",
      Length(Columns(R)), "\< over \<");
  View(UnderlyingSemigroup(R));
  Print(">\<");
  return;
end);

#

InstallMethod(ViewObj, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup], PrintObj);

#

InstallMethod(PrintObj, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R) 
  Print("\><subsemigroup of \>", Length(Rows(ParentAttr(R))), "x",
   Length(Columns(ParentAttr(R))), "\< Rees matrix semigroup \>with ");
  Print(Length(GeneratorsOfSemigroup(R)));
  Print(" generator");
  if Length(GeneratorsOfSemigroup(R))>1 then 
    Print("s");
  fi;
  Print("\<>\<");
  return;
end);

#

InstallMethod(ViewObj, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup], 3, #to beat the next method
function(R)
  Print("\>\><Rees 0-matrix semigroup \>", Length(Rows(R)), "x",
      Length(Columns(R)), "\< over \<");
  View(UnderlyingSemigroup(R));
  Print(">\<");
  return;
end);

#

InstallMethod(ViewObj, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup], PrintObj);

InstallMethod(PrintObj, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R) 
  Print("\><subsemigroup of \>", Length(Rows(ParentAttr(R))), "x",
   Length(Columns(ParentAttr(R))), "\< Rees 0-matrix semigroup \>with ");
  Print(Length(GeneratorsOfSemigroup(R)));
  Print(" generator");
  if Length(GeneratorsOfSemigroup(R))>1 then 
    Print("s");
  fi;
  Print("\<>\<");
  return;
end);

#

InstallMethod(PrintObj, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup and IsWholeFamily], 2,
function(R)
  Print("ReesMatrixSemigroup( ");
  Print(UnderlyingSemigroup(R));
  Print(", ");
  Print(Matrix(R));
  Print(" )");
end);

#

InstallMethod(PrintObj, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup and IsWholeFamily], 2,
function(R)
  Print("ReesZeroMatrixSemigroup( ");
  Print(UnderlyingSemigroup(R));
  Print(", ");
  Print(Matrix(R));
  Print(" )");
end);

#

InstallMethod(Size, "for a Rees matrix semigroup", 
[IsReesMatrixSemigroup],
function(R)
  if Size(UnderlyingSemigroup(R))=infinity then
    return infinity;
  fi;

  return Length(Rows(R))*Size(UnderlyingSemigroup(R))*Length(Columns(R));
end);

#

InstallMethod(Size, "for a Rees 0-matrix semigroup", 
[IsReesZeroMatrixSemigroup],
function(R)
  if Size(UnderlyingSemigroup(R))=infinity then
    return infinity;
  fi;

  return Length(Rows(R))*Size(UnderlyingSemigroup(R))*Length(Columns(R))+1;
end);

#

InstallMethod(Representative, 
"for a subsemigroup of Rees matrix semigroup with generators", 
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 2, 
# to beat the other method
function(R)
  return GeneratorsOfSemigroup(R)[1];
end);

#

InstallMethod(Representative, "for a Rees matrix semigroup", 
[IsReesMatrixSemigroup], 
function(R)
  return Objectify(TypeReesMatrixSemigroupElements(R), 
   [Rows(R)[1], Representative(UnderlyingSemigroup(R)), Columns(R)[1],
    Matrix(R)]);
end);

#

InstallMethod(Representative, 
"for a subsemigroup of Rees 0-matrix semigroup with generators", 
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 2, 
# to beat the other method 
function(R)
  return GeneratorsOfSemigroup(R)[1];
end);

#

InstallMethod(Representative, "for a Rees 0-matrix semigroup", 
[IsReesZeroMatrixSemigroup], 
function(R)
  return Objectify(TypeReesMatrixSemigroupElements(R), 
   [Rows(R)[1], Representative(UnderlyingSemigroup(R)), Columns(R)[1],
    Matrix(R)]);
end);


#

InstallMethod(Enumerator, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup],    
function( R )
  
  return EnumeratorByFunctions(R, rec(
    
    enum:=EnumeratorOfCartesianProduct(Rows(R),           
       Enumerator(UnderlyingSemigroup(R)), Columns(R), [Matrix(R)]),
    
    NumberElement:=function(enum, x)
      return Position(enum!.enum, [x![1], x![2], x![3], x![4]]);
    end,
    
    ElementNumber:=function(enum, n)
      return Objectify(TypeReesMatrixSemigroupElements(R), enum!.enum[n]);
    end,
    
    Length:=enum-> Length(enum!.enum),

    PrintObj:=function(enum) 
      Print("<enumerator of Rees matrix semigroup>");
      return;
    end));
end);

#

InstallMethod(Enumerator, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],    
function( R )
  
  return EnumeratorByFunctions(R, rec(
    
    enum:=EnumeratorOfCartesianProduct(Rows(R),           
       Enumerator(UnderlyingSemigroup(R)), Columns(R), [Matrix(R)]),
    
    NumberElement:=function(enum, x)
      local pos;
      if IsMultiplicativeZero(R, x) then 
        return 1;
      fi;
      
      pos:=Position(enum!.enum, [x![1], x![2], x![3], x![4]]);
      if pos=fail then 
        return fail;
      fi;
      return pos+1;
    end,
    
    ElementNumber:=function(enum, n)
      if n=1 then 
        return MultiplicativeZero(R);
      fi;
      return Objectify(TypeReesMatrixSemigroupElements(R), enum!.enum[n-1]);
    end,
    
    Length:=enum-> Length(enum!.enum)+1,

    PrintObj:=function(enum) 
      Print("<enumerator of Rees 0-matrix semigroup>");
      return;
    end));
end);

# these methods (Matrix, Rows, Columns, UnderlyingSemigroup) should only apply
# to subsemigroups defined by a generating set, which happen to be
# simple/0-simple.

InstallMethod(Matrix, "for a Rees matrix semigroup with generators", 
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  if not IsReesMatrixSemigroup(R) then 
    return fail;
  fi;
  return Matrix(ParentAttr(R));
end);

InstallMethod(Matrix, "for a Rees 0-matrix semigroup with generators", 
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  if not IsReesZeroMatrixSemigroup(R) then 
    return fail;
  fi;
  return Matrix(ParentAttr(R));
end);

#

InstallMethod(Rows, "for a Rees matrix semigroup with generators", 
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  if not IsReesMatrixSemigroup(R) then 
    return fail;
  fi;
  return SetX(GeneratorsOfSemigroup(R), x-> x![1]);
end);

InstallMethod(Rows, "for a Rees 0-matrix semigroup with generators", 
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  local out;
  if not IsReesZeroMatrixSemigroup(R) then 
    return fail;
  fi;
  out:=SetX(GeneratorsOfSemigroup(R), x-> x![1]);
  if out[1]=0 then 
    Remove(out, 1);
  fi;
  return out;
end);

#

InstallMethod(Columns, "for a Rees matrix semigroup with generators", 
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  if not IsReesMatrixSemigroup(R) then 
    return fail;
  fi;
  return SetX(GeneratorsOfSemigroup(R), x-> x![3]);
end);

InstallMethod(Columns, "for a Rees 0-matrix semigroup with generators", 
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  local out, x;
  
  if not IsReesZeroMatrixSemigroup(R) then 
    return fail;
  fi;

  out:=[];
  for x in GeneratorsOfSemigroup(R) do 
    if x![1]<>0 then 
      AddSet(out, x![3]);
    fi;
  od;

  return out;
end);

# these methods only apply to subsemigroups which happen to be Rees matrix
# semigroups

InstallMethod(UnderlyingSemigroup, 
"for a Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  local gens, i, S, U;
   
  if not IsReesMatrixSemigroup(R) then 
    return fail;
  fi;

  gens:=List(Elements(R), x-> x![2]);

  if IsGeneratorsOfMagmaWithInverses(gens) then 
    i:=1;
    S:=UnderlyingSemigroup(ParentAttr(R)); 
    U:=Group(gens[1]);
    while Size(U)<Size(S) and i<Length(gens) do 
      i:=i+1;
      U:=ClosureGroup(U, gens[i]);
    od;
  else
    U:=Semigroup(gens);
  fi;

  SetIsSimpleSemigroup(U, true);
  return U;
end);

# these methods only apply to subsemigroups which happen to be Rees matrix
# semigroups

InstallMethod(UnderlyingSemigroup, 
"for a Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 
function(R)
  local gens, i, S, U;
   
  if not IsReesZeroMatrixSemigroup(R) then 
    return fail;
  fi;

  #remove the 0
  gens:=Filtered(Elements(R), x-> x![1]<>0);
  Apply(gens, x-> x![2]);
  gens := Set(gens);
  
  if IsGeneratorsOfMagmaWithInverses(gens) then 
    i:=1;
    S:=UnderlyingSemigroup(ParentAttr(R)); 
    U:=Group(gens[1]);
    while Size(U)<Size(S) and i<Length(gens) do 
      i:=i+1;
      U:=ClosureGroup(U, gens[i]);
    od;
  else
    U:=Semigroup(gens);
  fi;

  return U;
end);

# again only for subsemigroups defined by generators...

InstallMethod(TypeReesMatrixSemigroupElements, 
"for a subsemigroup of Rees matrix semigroup",
[IsReesMatrixSubsemigroup],
R -> TypeReesMatrixSemigroupElements(ParentAttr(R)));

InstallMethod(TypeReesMatrixSemigroupElements, 
"for a subsemigroup of Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
R -> TypeReesMatrixSemigroupElements(ParentAttr(R)));

# Elements...

InstallGlobalFunction(RMSElement,
function(R, i, s, j)
  local out;

  if not (IsReesMatrixSubsemigroup(R) 
     or IsReesZeroMatrixSubsemigroup(R)) then
    Error("usage: the first argument must be a Rees matrix semigroup", 
    " or Rees 0-matrix semigroup,");
    return;
  fi;

  if (HasIsReesMatrixSemigroup(R) and IsReesMatrixSemigroup(R)) or
    (HasIsReesZeroMatrixSemigroup(R) and IsReesZeroMatrixSemigroup(R)) then 
    if not i in Rows(R) then 
      Error("usage: the second argument <i> does not belong to the rows of\n", 
      "the first argument <R>,");
      return;
    fi;
    if not j in Columns(R) then 
      Error("usage: the fourth argument <j> does not belong to the columns\n",  
      "of the first argument <R>,");
      return;
    fi;
    if not s in UnderlyingSemigroup(R) then 
      Error("usage: the second argument <s> does not belong to the\n",  
      "underlying semigroup of the first argument <R>,");
      return;
    fi;
    return Objectify(TypeReesMatrixSemigroupElements(R), [i, s, j, Matrix(R)]);
  fi;

  out:=Objectify(TypeReesMatrixSemigroupElements(R), 
   [i, s, j, Matrix(ParentAttr(R))]);

  if not out in R then # for the case R is defined by a generating set
    Error("the arguments do not describe an element of <R>,");
    return;
  fi;
  return out;
end);

#

InstallMethod(RowOfReesMatrixSemigroupElement, 
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement], 
x-> x![1]);

#

InstallMethod(RowOfReesZeroMatrixSemigroupElement, 
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement], 
x-> x![1]);

#

InstallMethod(UnderlyingElementOfReesMatrixSemigroupElement, 
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement], 
x-> x![2]);

#

InstallMethod(UnderlyingElementOfReesZeroMatrixSemigroupElement, 
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement], 
x-> x![2]);

#

InstallMethod(ColumnOfReesMatrixSemigroupElement, 
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement], 
x-> x![3]);

#

InstallMethod(ColumnOfReesZeroMatrixSemigroupElement, 
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement], 
x-> x![3]);

#

InstallMethod(PrintObj, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement],
function(x)
  Print("(", x![1],",", x![2], ",", x![3], ")");
end);

#

InstallMethod(PrintObj, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1]=0 then 
    Print("0");
    return;
  fi;
  Print("(", x![1],",", x![2], ",", x![3], ")");
end);


#

InstallMethod(ELM_LIST, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement, IsPosInt], 
function(x, i)
  if i<4 then 
    return x![i];
  else
    Error("usage: the second argument <i> must equal 1, 2, or 3,");
    return;
  fi;
end);

#

InstallMethod(ELM_LIST, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement, IsPosInt], 
function(x, i)
  if i<4 and x![1]<>0 then 
    return x![i];
  else
    Error("usage: the first argument <x> must be non-zero and the\n",     
     "second argument <i> must equal 1, 2, or 3,"); 
    return;
  fi;
end);

#

InstallMethod(ZeroOp, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement], ReturnFail);

#

InstallMethod(ZeroOp, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement], 
function(x)
  return MultiplicativeZero(ReesMatrixSemigroupOfFamily(FamilyObj(x)));
end);

#

InstallMethod(MultiplicativeZeroOp, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], ReturnFail);

#

InstallMethod(\*, "for elements of a Rees matrix semigroup",
IsIdenticalObj, 
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return Objectify(FamilyObj(x)!.type, 
   [x![1], x![2]*x![4][x![3]][y![1]]*y![2], y![3], x![4]]);
end);

#

InstallMethod(\*, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj, 
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  local p;
  
  if x![1]=0 then 
    return x; 
  elif y![1]=0 then 
    return y;
  fi;
  
  p:=x![4][x![3]][y![1]]; 
  if p=0 then 
    return Objectify(FamilyObj(x)!.type, [0]);
  fi;
  return Objectify(FamilyObj(x)!.type, [x![1], x![2]*p*y![2], y![3], x![4]]);
end);

#

InstallMethod(\<, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return x![1]<y![1] or (x![1]=y![1] and x![2]<y![2]) 
    or (x![1]=y![1] and x![2]=y![2] and x![3]<y![3]);
end);

# 0 is less than everything!

InstallMethod(\<, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  if x![1]=0 then 
    return y![1]<>0;
  elif y![1]=0 then 
    return false;
  fi;

  return x![1]<y![1] or (x![1]=y![1] and x![2]<y![2]) 
    or (x![1]=y![1] and x![2]=y![2] and x![3]<y![3]);
end);

#

InstallMethod(\=, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return x![1]=y![1] and x![2]=y![2] and x![3]=y![3];
end);

#

InstallMethod(\=, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  if x![1]=0 then 
    return y![1]=0;
  fi;
  return x![1]=y![1] and x![2]=y![2] and x![3]=y![3];
end);

#

InstallMethod(ParentAttr, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup],
function(R)
  return ReesMatrixSemigroupOfFamily(FamilyObj(Representative(R)));
end);

#

InstallMethod(ParentAttr, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
function(R)
  return ReesMatrixSemigroupOfFamily(FamilyObj(Representative(R)));
end);

#

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees matrix semigroup", 
[IsReesMatrixSubsemigroup], 
function(R)
  local S;

  if Size(R)=Size(ReesMatrixSemigroupOfFamily(ElementsFamily(FamilyObj(R))))
   then 
    if not HasMatrix(R) then # <R> is defined by generators 
      S:=ParentAttr(R);
      SetMatrix(R, Matrix(S));  
      SetUnderlyingSemigroup(R, UnderlyingSemigroup(S));
      SetRows(R, Rows(S));            
      SetColumns(R, Columns(S));
    fi;
    return true;
  else
    return false;
  fi;
end);

#

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees 0-matrix semigroup", 
[IsReesZeroMatrixSubsemigroup], 
function(R)
  local S;

  if Size(R)=Size(ReesMatrixSemigroupOfFamily(ElementsFamily(FamilyObj(R))))
   then 
    if not HasMatrix(R) then # <R> is defined by generators 
      S:=ParentAttr(R);
      SetMatrix(R, Matrix(S));  
      SetUnderlyingSemigroup(R, UnderlyingSemigroup(S));
      SetRows(R, Rows(S));            
      SetColumns(R, Columns(S));
    fi;
    return true;
  else
    return false;
  fi;
end);

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallGlobalFunction(GeneratorsOfReesMatrixSemigroupNC, 
function(R, I, U, J)
  local P, type, i, j, gens, u;
  
  P:=Matrix(R);   type:=TypeReesMatrixSemigroupElements(R);
  
  if IsGroup(U) then 
    i:=I[1];   j:=J[1];
    if IsTrivial(U) then 
      gens:=[Objectify(type, [i, P[j][i]^-1, j, P])];
    else
      gens:=List(GeneratorsOfGroup(U), x-> 
       Objectify( type, [i, x*P[j][i]^-1, j, P]));
    fi;
    
    if Length(I)>Length(J) then 
      for i in [2..Length(J)] do 
        Add(gens, Objectify(type, [I[i], One(U), J[i], P]));
      od;
      for i in [Length(J)+1..Length(I)] do 
        Add(gens, Objectify(type, [I[i], One(U), J[1], P]));
      od;
    else
      for i in [2..Length(I)] do 
        Add(gens, Objectify(type, [I[i], One(U), J[i], P]));
      od;
      for i in [Length(I)+1..Length(J)] do 
        Add(gens, Objectify(type, [I[1], One(U), J[i], P]));
      od;
    fi;
  else
    gens:=[];
    for i in I do 
      for u in U do 
        for j in J do 
          Add(gens, Objectify(type, [i, u, j, P]));
        od;
      od;
    od;
  fi;
  return gens;
end);

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallGlobalFunction(GeneratorsOfReesZeroMatrixSemigroupNC, 
function(R, I, U, J)
  local P, type, i, j, gens, k, u;

  P:=Matrix(R);   type:=TypeReesMatrixSemigroupElements(R);
  i:=I[1];        j:=First(J, j-> P[j][i]<>0);

  if IsGroup(U) and IsRegularSemigroup(R) and not j=fail then 
    if IsTrivial(U) then 
      gens:=[Objectify(type, [i, P[j][i]^-1, j, P])];
    else
      gens:=List(GeneratorsOfGroup(U), x-> 
        Objectify(type, [i, x*P[j][i]^-1, j, P]));
    fi;

    for k in J do 
      if k<>j then 
        Add(gens, Objectify(type, [i, One(U), k, P]));
      fi;
    od;
    
    for k in I do 
      if k<>i then 
        Add(gens, Objectify(type, [k, One(U), j, P]));
      fi;
    od;
  else 
    gens:=[];
    for i in I do 
      for u in U do 
        for j in J do 
          Add(gens, Objectify(type, [i, u, j, P]));
        od;
      od;
    od;
  fi;
  return gens;
end);

# you can't do this operation on arbitrary subsemigroup of Rees matrix
# semigroups since they don't have to be simple and so don't have to have rows,
# columns etc.

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallMethod(GeneratorsOfReesMatrixSemigroup, 
"for a Rees matrix subsemigroup, rows, semigroup, columns",
[IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList], 
function(R, I, U, J)

  if not IsReesMatrixSemigroup(R) then 
    Error("usage: <R> must be a Rees matrix semigroup,");
    return;
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then 
    Error("usage: <I> must be a non-empty subset of the rows of <R>,");
    return;
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then 
    Error("usage: <J> must be a non-empty subset of the columns of <R>,");
    return;
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then 
    Error("usage: <U> must be a subsemigroup of the underlying semigroup", 
    " of <R>,");
    return;
  fi;
  
  return GeneratorsOfReesMatrixSemigroupNC(R, I, U, J);
end);

# you can't do this operation on arbitrary subsemigroup of Rees matrix
# semigroups since they don't have to be simple and so don't have to have rows,
# columns etc.

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallMethod(GeneratorsOfReesZeroMatrixSemigroup, 
"for a Rees 0-matrix semigroup, rows, semigroup, columns",
[IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList], 
function(R, I, U, J)

  if not IsReesZeroMatrixSemigroup(R) then 
    Error("usage: <R> must be a Rees 0-matrix semigroup,");
    return;
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then 
    Error("usage: <I> must be a non-empty subset of the rows of <R>,");
    return;
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then 
    Error("usage: <J> must be a non-empty subset of the columns of <R>,");
    return;
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then 
    Error("usage: <T> must be a subsemigroup of the underlying semigroup", 
    " of <R>,");
    return;
  fi;

  return GeneratorsOfReesZeroMatrixSemigroupNC(R, I, U, J);
end);

#

InstallMethod(GeneratorsOfSemigroup, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], 
function(R)
  return GeneratorsOfReesMatrixSemigroupNC(R, Rows(R), UnderlyingSemigroup(R),
   Columns(R));
end);

#

InstallMethod(GeneratorsOfSemigroup, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup], 
function(R)
  local gens;

  gens:=GeneratorsOfReesZeroMatrixSemigroupNC(R, Rows(R),
   UnderlyingSemigroup(R), Columns(R));
  if ForAll(Rows(R), i-> ForAll(Columns(R), j-> Matrix(R)[j][i]<>0)) then 
    Add(gens, MultiplicativeZero(R));
  fi;
  return gens;
end);

# Note that it is possible that the rows and columns of the matrix only contain 
# the zero element, if the resulting semigroup were taken to be in 
# IsReesMatrixSemigroup then it would belong to IsReesMatrixSemigroup and 
# IsReesZeroMatrixSubsemigroup, so that its elements belong to 
# IsReesZeroMatrixSemigroupElement but not to IsReesMatrixSemigroupElement 
# (since this makes reference to the whole family used to create the 
# semigroups). On the other hand, if we simply exclude the 0, then every method 
# for IsReesZeroMatrixSemigroup is messed up because we assume that they always 
# contain the 0.  
# 
# Hence we always include the 0 element, even if all the matrix 
# entries corresponding to I and J are non-zero. 

InstallMethod(ReesZeroMatrixSubsemigroup, 
"for a Rees 0-matrix semigroup, rows, semigroup, columns",
[IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList], 
function(R, I, U, J)
  local S;
   
  if not IsReesZeroMatrixSemigroup(R) then 
    Error("usage: <R> must be a Rees 0-matrix semigroup,");
    return;
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then 
    Error("usage: <I> must be a non-empty subset of the rows of <R>,");
    return;
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then 
    Error("usage: <J> must be a non-empty subset of the columns of <R>,");
    return;
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then 
    Error("usage: <T> must be a subsemigroup of the underlying semigroup", 
    " of <R>,");
    return;
  fi;

  return ReesZeroMatrixSubsemigroupNC(R, I, U, J);
end);

InstallGlobalFunction(ReesZeroMatrixSubsemigroupNC, 
function(R, I, U, J)
  local S;

  if U=UnderlyingSemigroup(R) and ForAny(Matrix(R){J}{I}, x-> 0 in x) then 
    S:=Objectify( NewType( FamilyObj(R),
     IsReesZeroMatrixSubsemigroup and IsAttributeStoringRep ), rec() );
    SetTypeReesMatrixSemigroupElements(S, TypeReesMatrixSemigroupElements(R));

    SetMatrix(S, Matrix(R));  SetUnderlyingSemigroup(S, UnderlyingSemigroup(R));
    SetRows(S, I);            SetColumns(S, J);
    SetParentAttr(S, R);

    #it might be that all the matrix entries corresponding to I and J are zero
    #and so we can't set IsZeroSimpleSemigroup here. 
    SetMultiplicativeZero(S, MultiplicativeZero(R));
    SetIsSimpleSemigroup(S, false);
    SetIsReesZeroMatrixSemigroup(S, true);
    return S;
  fi;

  return Semigroup(GeneratorsOfReesZeroMatrixSemigroupNC(R, I, U, J));
end);

#

InstallMethod(ReesMatrixSubsemigroup, 
"for a Rees matrix semigroup, rows, semigroup, columns",
[IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList], 
function(R, I, U, J)
  
  if not IsReesMatrixSemigroup(R) then 
    Error("usage: <R> must be a Rees matrix semigroup,");
    return;
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then 
    Error("usage: <I> must be a non-empty subset of the rows of <R>,");
    return;
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then 
    Error("usage: <J> must be a non-empty subset of the columns of <R>,");
    return;
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then 
    Error("usage: <U> must be a subsemigroup of the underlying semigroup", 
    " of <R>,");
    return;
  fi;

  return ReesMatrixSubsemigroupNC(R, I, U, J);
end);

#

InstallGlobalFunction(ReesMatrixSubsemigroupNC, 
function(R, I, U, J)
  local S;
    
  if U=UnderlyingSemigroup(R) then 
    S:=Objectify( NewType( FamilyObj(R),
      IsReesMatrixSubsemigroup and IsAttributeStoringRep ), rec() );
    SetTypeReesMatrixSemigroupElements(S, TypeReesMatrixSemigroupElements(R));

    SetMatrix(S, Matrix(R));  SetUnderlyingSemigroup(S, UnderlyingSemigroup(R));
    SetRows(S, I);            SetColumns(S, J);
    SetParentAttr(S, R);

    if HasIsSimpleSemigroup(R) and IsSimpleSemigroup(R) then
      SetIsSimpleSemigroup(S, true);
    fi;
    SetIsReesMatrixSemigroup(S, true);
    SetIsZeroSimpleSemigroup(S, false); 
    return S;
  fi;
  return Semigroup(GeneratorsOfReesMatrixSemigroupNC(R, I, U, J));
end);

#

InstallMethod(IsomorphismReesMatrixSemigroup, 
"for a finite simple or 0-simple semigroup", [IsSemigroup], 
function(S)
  local iso_trans, T, iter, rep, H, R, iso, inv, iso_perm, inv_perm, lreps, rreps, mat, invl, invr, x, lclasses, rclasses, i, j;
  
  if not (IsSimpleSemigroup(S) or IsZeroSimpleSemigroup(S)) or not IsFinite(S)
   then 
    TryNextMethod();
  fi;
  
  if not IsTransformationSemigroup(S) then  
    iso_trans:=IsomorphismTransformationSemigroup(S);
    T:=Range(IsomorphismTransformationSemigroup(S));
  else
    iso_trans:=MappingByFunction(S, S, IdFunc, IdFunc);
    T:=S;
  fi;

  # a group H-class
  iter:=Iterator(T);
  rep:=NextIterator(iter);
  if IsZeroSimpleSemigroup(T) and rep=MultiplicativeZero(T) then 
    rep:=NextIterator(iter);
  fi;

  H:=GroupHClassOfGreensDClass(GreensDClassOfElement(T, rep));
  rep:=Representative(H);
  iso_perm:=IsomorphismPermGroup(H); inv_perm:=InverseGeneralMapping(iso_perm);
  
  lreps:=List(GreensHClasses(GreensRClassOfElement(T, rep)), Representative);
  rreps:=List(GreensHClasses(GreensLClassOfElement(T, rep)), Representative);
  
  mat:=[]; invl:=[]; invr:=[]; 
  
  for i in [1..Length(lreps)] do
    mat[i]:=[];
    for j in [1..Length(rreps)] do
      x:=lreps[i]*rreps[j];
      if IsZeroSimpleSemigroup(S) and x=MultiplicativeZero(T) then 
        mat[i][j]:=0;
      else
        mat[i][j]:=x^iso_perm;
        if not IsBound(invr[j]) then 
          invr[j]:=(mat[i][j]^-1)^inv_perm*lreps[i];
        fi;
        if not IsBound(invl[i]) then 
          invl[i]:=rreps[j]*(mat[i][j]^-1)^inv_perm;
        fi;
      fi;
    od;
  od;

  if IsZeroSimpleSemigroup(S) then
    R:=ReesZeroMatrixSemigroup(Range(iso_perm), mat);
  else
    R:=ReesMatrixSemigroup(Range(iso_perm), mat);
  fi;

  lclasses:=List(lreps, x-> GreensLClassOfElement(T, x));
  rclasses:=List(rreps, x-> GreensRClassOfElement(T, x));
  
  iso:=function(x)
    local i, j;
    x:=x^iso_trans;
    i:=PositionProperty(lclasses, L -> L=GreensLClassOfElement(T, x));
    if i=fail then 
      return fail;
    fi;
    j:=PositionProperty(rclasses, R -> R=GreensRClassOfElement(T, x));
    if j=fail then 
      return fail;
    fi;
    return Objectify(TypeReesMatrixSemigroupElements(R), 
     [j, (invr[j]*x*invl[i])^iso_perm, i, mat]);
  end;

  inv:=function(x)
    if x![1]=0 then
      return MultiplicativeZero(S);
    fi;
    return 
    (rreps[x![1]]*(x![2]^inv_perm)*lreps[x![3]])
    ^InverseGeneralMapping(iso_trans);
  end;

  return MagmaIsomorphismByFunctionsNC(S, R, iso, inv);
end);

#JDM this should be replaced with InjectionPrincipalFactor, and PrincipalFactor.

InstallMethod(AssociatedReesMatrixSemigroupOfDClass, 
"for a Green's D-class of a semigroup",
[IsGreensDClass],
function( D )
  local h, r, l, phi, iszerosimple, mat, x, i, j;

  if not IsFinite(Parent(D)) then
    TryNextMethod();
  fi;

  if not IsRegularDClass(D) then
    Error("usage: the argument should be a regular D-class,");
    return;
  fi;

  h:=GroupHClassOfGreensDClass(D);
  l:=GreensRClassOfElement(Parent(D), Representative(h));
  r:=GreensLClassOfElement(Parent(D), Representative(h));
  
  r:= List(GreensHClasses(r), Representative);
  l:= List(GreensHClasses(l), Representative);
  
  phi:=IsomorphismPermGroup(h);

  iszerosimple:=false;    
  mat:=[];
  for i in [1..Length(l)] do 
    mat[i]:=[];
    for j in [1..Length(r)] do 
      x:=l[i]*r[j]; 
      if x in D then 
        mat[i][j]:=x^phi;
      else
        iszerosimple:=true;
        mat[i][j]:=0;
      fi;
    od;
  od;

  if iszerosimple then
    return ReesZeroMatrixSemigroup(Range(phi), mat);
  else
    return ReesMatrixSemigroup(Range(phi), mat);
  fi;
end);

# so that we can find Green's relations etc

InstallMethod(MonoidByAdjoiningIdentity, [IsReesMatrixSubsemigroup], 
function(R)
  local M;
  M:=Monoid(List(GeneratorsOfSemigroup(R), MonoidByAdjoiningIdentityElt));
  SetUnderlyingSemigroupOfMonoidByAdjoiningIdentity(M, R);
  return M;
end);

# so that we can find Green's relations etc

InstallMethod(MonoidByAdjoiningIdentity, [IsReesZeroMatrixSubsemigroup], 
function(R)
  local M;
  M:=Monoid(List(GeneratorsOfSemigroup(R), MonoidByAdjoiningIdentityElt));
  SetUnderlyingSemigroupOfMonoidByAdjoiningIdentity(M, R);
  return M;
end);

# the next two methods by Michael Torpey and Thomas Bourne.

InstallMethod(IsomorphismReesMatrixSemigroup, 
"for a Rees 0-matrix subsemigroup", [IsReesZeroMatrixSubsemigroup],
function(U)
  local V, iso, inv, hom;

  if not IsReesZeroMatrixSemigroup(U) then
    TryNextMethod();
  elif IsWholeFamily(U) then 
    return MagmaIsomorphismByFunctionsNC(U, U, IdFunc, IdFunc);
  fi;

  V:=ReesZeroMatrixSemigroup(UnderlyingSemigroup(U),
   Matrix(U){Columns(U)}{Rows(U)});

  iso := function(u)
    if u = MultiplicativeZero(U) then
      return MultiplicativeZero(V);
    fi;
    return RMSElement(V, Position(Rows(U),u![1]), u![2], 
    Position(Columns(U),u![3]));
  end;
  
  inv := function(v)
    if v = MultiplicativeZero(V) then
      return MultiplicativeZero(U);
    fi;
    return RMSElement(U, Rows(U)[v![1]], v![2], Columns(U)[v![3]]);
  end;
  
  return MagmaIsomorphismByFunctionsNC(U, V, iso, inv);
end);

InstallMethod(IsomorphismReesMatrixSemigroup, "for a Rees matrix subsemigroup",
[IsReesMatrixSubsemigroup],
function(U)
  local P, V, iso, inv, hom;
    
    if not IsReesMatrixSemigroup(U) then
      TryNextMethod();
    elif IsWholeFamily(U) then 
      return MagmaIsomorphismByFunctionsNC(U, U, IdFunc, IdFunc);
    fi;
    
    V:=ReesMatrixSemigroup(UnderlyingSemigroup(U), 
     List(Matrix(U){Columns(U)}, x-> x{Rows(U)}));
   #JDM doing Matrix(U){Columns(U)}{Rows(U)} the resulting object does not know
   #IsRectangularTable, and doesn't store this after it is calculated.
    
    iso := function(u)
      return RMSElement(V, Position(Rows(U),u![1]), u![2], 
       Position(Columns(U),u![3]));
    end;

    inv := function(v)
      return RMSElement(U, Rows(U)[v![1]], v![2], Columns(U)[v![3]]);
    end;

    return MagmaIsomorphismByFunctionsNC(U, V, iso, inv);
end);

#EOF
