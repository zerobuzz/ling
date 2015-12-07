-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module Ling.Par where
import Ling.Abs
import Ling.Lex
import Ling.ErrM

}

%name pProgram Program
%name pListName ListName
%name pDec Dec
%name pAssertion Assertion
%name pConName ConName
%name pListConName ListConName
%name pOptSig OptSig
%name pListDec ListDec
%name pVarDec VarDec
%name pChanDec ChanDec
%name pListChanDec ListChanDec
%name pBranch Branch
%name pListBranch ListBranch
%name pLiteral Literal
%name pATerm ATerm
%name pListATerm ListATerm
%name pTerm3 Term3
%name pTerm2 Term2
%name pTerm1 Term1
%name pTerm Term
%name pProc1 Proc1
%name pProc Proc
%name pListProc ListProc
%name pAct Act
%name pASession ASession
%name pTopCPatt TopCPatt
%name pCPatt CPatt
%name pListCPatt ListCPatt
%name pOptSession OptSession
%name pRSession RSession
%name pListRSession ListRSession
%name pOptRepl OptRepl
%name pCSession CSession
%name pAllocTerm AllocTerm
%name pListAllocTerm ListAllocTerm
%name pNewAlloc NewAlloc
-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype {Token}
%token
  '!' { PT _ (TS _ 1) }
  '(' { PT _ (TS _ 2) }
  ')' { PT _ (TS _ 3) }
  '**' { PT _ (TS _ 4) }
  ',' { PT _ (TS _ 5) }
  '->' { PT _ (TS _ 6) }
  '-o' { PT _ (TS _ 7) }
  '.' { PT _ (TS _ 8) }
  ':' { PT _ (TS _ 9) }
  ':]' { PT _ (TS _ 10) }
  '<' { PT _ (TS _ 11) }
  '=' { PT _ (TS _ 12) }
  '>' { PT _ (TS _ 13) }
  '?' { PT _ (TS _ 14) }
  '@' { PT _ (TS _ 15) }
  'Type' { PT _ (TS _ 16) }
  '[' { PT _ (TS _ 17) }
  '[:' { PT _ (TS _ 18) }
  '\\' { PT _ (TS _ 19) }
  ']' { PT _ (TS _ 20) }
  '^' { PT _ (TS _ 21) }
  '`' { PT _ (TS _ 22) }
  'as' { PT _ (TS _ 23) }
  'assert' { PT _ (TS _ 24) }
  'case' { PT _ (TS _ 25) }
  'data' { PT _ (TS _ 26) }
  'end' { PT _ (TS _ 27) }
  'fwd' { PT _ (TS _ 28) }
  'in' { PT _ (TS _ 29) }
  'let' { PT _ (TS _ 30) }
  'new' { PT _ (TS _ 31) }
  'new/' { PT _ (TS _ 32) }
  'of' { PT _ (TS _ 33) }
  'proc' { PT _ (TS _ 34) }
  'recv' { PT _ (TS _ 35) }
  'send' { PT _ (TS _ 36) }
  'slice' { PT _ (TS _ 37) }
  '{' { PT _ (TS _ 38) }
  '|' { PT _ (TS _ 39) }
  '}' { PT _ (TS _ 40) }
  '~' { PT _ (TS _ 41) }

L_integ  { PT _ (TI $$) }
L_doubl  { PT _ (TD $$) }
L_quoted { PT _ (TL $$) }
L_charac { PT _ (TC $$) }
L_Name { PT _ (T_Name $$) }


%%

Integer :: { Integer } : L_integ  { (read ( $1)) :: Integer }
Double  :: { Double }  : L_doubl  { (read ( $1)) :: Double }
String  :: { String }  : L_quoted {  $1 }
Char    :: { Char }    : L_charac { (read ( $1)) :: Char }
Name    :: { Name} : L_Name { Name ($1)}

Program :: { Program }
Program : ListDec { Ling.Abs.Prg $1 }
ListName :: { [Name] }
ListName : {- empty -} { [] } | Name ListName { (:) $1 $2 }
Dec :: { Dec }
Dec : Name OptSig '=' Term { Ling.Abs.DDef $1 $2 $4 }
    | Name ':' Term { Ling.Abs.DSig $1 $3 }
    | 'data' Name '=' ListConName { Ling.Abs.DDat $2 $4 }
    | 'assert' Assertion { Ling.Abs.DAsr $2 }
Assertion :: { Assertion }
Assertion : Term '=' Term OptSig { Ling.Abs.AEq $1 $3 $4 }
ConName :: { ConName }
ConName : '`' Name { Ling.Abs.CN $2 }
ListConName :: { [ConName] }
ListConName : {- empty -} { [] }
            | ConName { (:[]) $1 }
            | ConName '|' ListConName { (:) $1 $3 }
OptSig :: { OptSig }
OptSig : {- empty -} { Ling.Abs.NoSig }
       | ':' Term { Ling.Abs.SoSig $2 }
ListDec :: { [Dec] }
ListDec : {- empty -} { [] }
        | Dec { (:[]) $1 }
        | Dec ',' ListDec { (:) $1 $3 }
VarDec :: { VarDec }
VarDec : '(' Name OptSig ')' { Ling.Abs.VD $2 $3 }
ChanDec :: { ChanDec }
ChanDec : Name OptSession { Ling.Abs.CD $1 $2 }
ListChanDec :: { [ChanDec] }
ListChanDec : {- empty -} { [] }
            | ChanDec { (:[]) $1 }
            | ChanDec ',' ListChanDec { (:) $1 $3 }
Branch :: { Branch }
Branch : ConName '->' Term { Ling.Abs.Br $1 $3 }
ListBranch :: { [Branch] }
ListBranch : {- empty -} { [] }
           | Branch { (:[]) $1 }
           | Branch ',' ListBranch { (:) $1 $3 }
Literal :: { Literal }
Literal : Integer { Ling.Abs.LInteger $1 }
        | Double { Ling.Abs.LDouble $1 }
        | String { Ling.Abs.LString $1 }
        | Char { Ling.Abs.LChar $1 }
ATerm :: { ATerm }
ATerm : Name { Ling.Abs.Var $1 }
      | Literal { Ling.Abs.Lit $1 }
      | ConName { Ling.Abs.Con $1 }
      | 'Type' { Ling.Abs.TTyp }
      | '<' ListRSession '>' { Ling.Abs.TProto $2 }
      | '(' Term OptSig ')' { Ling.Abs.Paren $2 $3 }
      | 'end' { Ling.Abs.End }
      | '{' ListRSession '}' { Ling.Abs.Par $2 }
      | '[' ListRSession ']' { Ling.Abs.Ten $2 }
      | '[:' ListRSession ':]' { Ling.Abs.Seq $2 }
ListATerm :: { [ATerm] }
ListATerm : {- empty -} { [] } | ListATerm ATerm { flip (:) $1 $2 }
Term3 :: { Term }
Term3 : ATerm ListATerm { Ling.Abs.RawApp $1 (reverse $2) }
Term2 :: { Term }
Term2 : 'case' Term 'of' '{' ListBranch '}' { Ling.Abs.Case $2 $5 }
      | '!' Term3 CSession { Ling.Abs.Snd $2 $3 }
      | '?' Term3 CSession { Ling.Abs.Rcv $2 $3 }
      | '~' Term2 { Ling.Abs.Dual $2 }
      | Term3 { $1 }
Term1 :: { Term }
Term1 : Term2 '-o' Term1 { Ling.Abs.Loli $1 $3 }
      | Term2 '->' Term1 { Ling.Abs.TFun $1 $3 }
      | Term2 '**' Term1 { Ling.Abs.TSig $1 $3 }
      | 'let' Name OptSig '=' Term 'in' Term { Ling.Abs.Let $2 $3 $5 $7 }
      | Term2 { $1 }
Term :: { Term }
Term : '\\' Term2 '->' Term { Ling.Abs.Lam $2 $4 }
     | 'proc' '(' ListChanDec ')' Proc { Ling.Abs.TProc $3 $5 }
     | Term1 { $1 }
Proc1 :: { Proc }
Proc1 : Act { Ling.Abs.PAct $1 }
      | '(' ListProc ')' { Ling.Abs.PPrll $2 }
Proc :: { Proc }
Proc : Proc1 Proc { Ling.Abs.PNxt $1 $2 }
     | Proc1 '.' Proc { Ling.Abs.PDot $1 $3 }
     | 'slice' '(' ListChanDec ')' ATerm 'as' Name Proc { Ling.Abs.NewSlice $3 $5 $7 $8 }
     | Proc1 { $1 }
ListProc :: { [Proc] }
ListProc : {- empty -} { [] }
         | Proc { (:[]) $1 }
         | Proc '|' ListProc { (:) $1 $3 }
Act :: { Act }
Act : NewAlloc { Ling.Abs.Nu $1 }
    | Name '{' ListChanDec '}' { Ling.Abs.ParSplit $1 $3 }
    | Name '[' ListChanDec ']' { Ling.Abs.TenSplit $1 $3 }
    | Name '[:' ListChanDec ':]' { Ling.Abs.SeqSplit $1 $3 }
    | 'send' Name ATerm { Ling.Abs.Send $2 $3 }
    | 'recv' Name VarDec { Ling.Abs.Recv $2 $3 }
    | 'fwd' ASession '(' ListChanDec ')' { Ling.Abs.Ax $2 $4 }
    | 'fwd' Integer ASession Name { Ling.Abs.SplitAx $2 $3 $4 }
    | '@' ATerm TopCPatt { Ling.Abs.At $2 $3 }
    | 'let' Name OptSig '=' ATerm { Ling.Abs.LetA $2 $3 $5 }
ASession :: { ASession }
ASession : ATerm { Ling.Abs.AS $1 }
TopCPatt :: { TopCPatt }
TopCPatt : '(' ListChanDec ')' { Ling.Abs.OldTopPatt $2 }
         | '{' ListCPatt '}' { Ling.Abs.ParTopPatt $2 }
         | '[' ListCPatt ']' { Ling.Abs.TenTopPatt $2 }
         | '[:' ListCPatt ':]' { Ling.Abs.SeqTopPatt $2 }
CPatt :: { CPatt }
CPatt : ChanDec { Ling.Abs.ChaPatt $1 }
      | '{' ListCPatt '}' { Ling.Abs.ParPatt $2 }
      | '[' ListCPatt ']' { Ling.Abs.TenPatt $2 }
      | '[:' ListCPatt ':]' { Ling.Abs.SeqPatt $2 }
ListCPatt :: { [CPatt] }
ListCPatt : {- empty -} { [] }
          | CPatt { (:[]) $1 }
          | CPatt ',' ListCPatt { (:) $1 $3 }
OptSession :: { OptSession }
OptSession : {- empty -} { Ling.Abs.NoSession }
           | ':' RSession { Ling.Abs.SoSession $2 }
RSession :: { RSession }
RSession : Term OptRepl { Ling.Abs.Repl $1 $2 }
ListRSession :: { [RSession] }
ListRSession : {- empty -} { [] }
             | RSession { (:[]) $1 }
             | RSession ',' ListRSession { (:) $1 $3 }
OptRepl :: { OptRepl }
OptRepl : {- empty -} { Ling.Abs.One }
        | '^' ATerm { Ling.Abs.Some $2 }
CSession :: { CSession }
CSession : '.' Term1 { Ling.Abs.Cont $2 }
         | {- empty -} { Ling.Abs.Done }
AllocTerm :: { AllocTerm }
AllocTerm : Name ListAllocTerm { Ling.Abs.AVar $1 (reverse $2) }
          | Literal { Ling.Abs.ALit $1 }
          | '(' Term OptSig ')' { Ling.Abs.AParen $2 $3 }
ListAllocTerm :: { [AllocTerm] }
ListAllocTerm : {- empty -} { [] }
              | ListAllocTerm AllocTerm { flip (:) $1 $2 }
NewAlloc :: { NewAlloc }
NewAlloc : 'new' '[' ListChanDec ']' { Ling.Abs.New $3 }
         | 'new' '(' ListChanDec ')' { Ling.Abs.OldNew $3 }
         | 'new/' AllocTerm '[' ListChanDec ']' { Ling.Abs.NewAnn $2 $4 }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map (id . prToken) (take 4 ts))

myLexer = tokens
}

