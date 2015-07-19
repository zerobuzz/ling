

module Ling.Abs where

-- Haskell module generated by the BNF converter




newtype Name = Name String deriving (Eq, Ord, Show, Read)
data Program = Prg [Dec]
  deriving (Eq, Ord, Show, Read)

data Dec = DDef Name OptChanDecs Proc | DSig Name Term OptDef
  deriving (Eq, Ord, Show, Read)

data OptDef = NoDef | SoDef Term
  deriving (Eq, Ord, Show, Read)

data VarDec = VD Name Term
  deriving (Eq, Ord, Show, Read)

data OptChanDecs = NoChanDecs | SoChanDecs [ChanDec]
  deriving (Eq, Ord, Show, Read)

data ChanDec = CD Name OptSession
  deriving (Eq, Ord, Show, Read)

data ATerm
    = Var Name | Lit Integer | TTyp | TProto [RSession] | Paren Term
  deriving (Eq, Ord, Show, Read)

data DTerm = DTTyp Name [ATerm] | DTBnd Name Term
  deriving (Eq, Ord, Show, Read)

data Term
    = RawApp ATerm [ATerm]
    | TFun VarDec [VarDec] Term
    | TSig VarDec [VarDec] Term
    | TProc [ChanDec] Proc
  deriving (Eq, Ord, Show, Read)

data Proc = Act [Pref] Procs
  deriving (Eq, Ord, Show, Read)

data Procs
    = ZeroP
    | Ax Session [Name]
    | At ATerm [Name]
    | NewSlice [Name] ATerm Name Proc
    | Prll [Proc]
  deriving (Eq, Ord, Show, Read)

data Pref
    = Nu ChanDec ChanDec
    | ParSplit Name [ChanDec]
    | TenSplit Name [ChanDec]
    | SeqSplit Name [ChanDec]
    | Send Name ATerm
    | Recv Name VarDec
  deriving (Eq, Ord, Show, Read)

data OptSession = NoSession | SoSession RSession
  deriving (Eq, Ord, Show, Read)

data Session
    = Atm Name
    | End
    | Par [RSession]
    | Ten [RSession]
    | Seq [RSession]
    | Sort ATerm ATerm
    | Log Session
    | Fwd Integer Session
    | Snd DTerm CSession
    | Rcv DTerm CSession
    | Dual Session
    | Loli Session Session
  deriving (Eq, Ord, Show, Read)

data RSession = Repl Session OptRepl
  deriving (Eq, Ord, Show, Read)

data OptRepl = One | Some ATerm
  deriving (Eq, Ord, Show, Read)

data CSession = Cont Session | Done
  deriving (Eq, Ord, Show, Read)

