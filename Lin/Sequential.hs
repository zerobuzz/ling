{-# LANGUAGE TemplateHaskell, RankNTypes #-}
module Lin.Sequential where

{-
  programs have parameters
  the meaning is that no synch is expected
  namely if the protocol can "recv" an int on chan c, then
  it means we can read this location, similarily for send.

  TODO, so far only a naive approach is selected

  For each external location either:
    Single read
    Single write
    Read then write
-}

import Control.Lens hiding (act,acts,op)

import Data.Maybe
import qualified Data.Map as Map
import Data.Map (Map)
import qualified Data.Set as Set
import Data.Set (Set)
import Lin.Utils
import Lin.Print.Instances ()
import Lin.Session
import Lin.Proc
import Lin.Norm

data Status = Full | Empty deriving (Eq,Read,Show)

data Location
  = Root Channel
  | Proj Location Int
  deriving (Read,Show,Ord,Eq)

data Env = Env { _chans :: Map Channel (Location, Session)
               , _locs  :: Set Location }
  deriving (Show)

$(makeLenses ''Env)

emptyEnv :: Env
emptyEnv = Env Map.empty Set.empty

addChans :: [(Channel, (Location, Session))] -> Env -> Env
addChans xys = chans %~ Map.union (Map.fromList xys)

rmChan :: Channel -> Env -> Env
rmChan c = chans . at c .~ Nothing

(!) :: Env -> Channel -> (Location, Session)
env ! i = fromMaybe err (env ^. chans . at i)
  where err = error $ "lookup/env " ++ show i ++ " in "
                   ++ show (map unName (Map.keys (env ^. chans)))

addLocs :: [(Location, Status)] -> Env -> Env
addLocs xys = locs %~ Set.union         (Set.fromList [l | (l,Full)  <- xys])
                    . (`Set.difference`  Set.fromList [l | (l,Empty) <- xys])

{-
statusStep :: Status -> Status
statusStep Full  = Empty
statusStep Empty = Full
-}

mnot :: Maybe () -> Maybe ()
mnot Nothing   = Just ()
mnot (Just ()) = Nothing

actEnv :: Channel -> Env -> Env
actEnv c env = env & chans . at c . mapped . _2 %~ sessionStep
                   & locs  . at l %~ mnot
  where l = fst (env!c)

sessionsStatus :: (Session -> Status) -> Location -> Sessions -> [(Location,Status)]
sessionsStatus dflt l ss = [ ls
                      | (i,s) <- zip [0..] (flatSessions ss)
                      , ls <- sessionStatus dflt (Proj l i) s ]

sessionStatus :: (Session -> Status) -> Location -> Session -> [(Location,Status)]
sessionStatus dflt l x = case x of
  Ten ss -> sessionsStatus dflt l ss
  Par ss -> sessionsStatus dflt l ss
  Seq ss -> sessionsStatus dflt l ss
  _      -> [(l, dflt x)]

statusAt :: Channel -> Env -> Status
statusAt c env = env ^. locs . at l . to f
  where
    l   = fst (env ! c)
    f Nothing    = Empty
    f (Just  ()) = Full

-- TODO generalize by looking deeper at what is ready now
isReady :: Env -> [Pref] -> Maybe ([Pref], [Pref])
isReady _ [] = error "isReady: impossible"
isReady env (pref : prefs)
  | isReadyPref env pref = Just ([pref], prefs)
  | otherwise            = Nothing

isReadyPref :: Env -> Pref -> Bool
isReadyPref env pref =
  case pref of
    Split{}    -> True
    NewSlice{} -> True
    Nu{}       -> True
    Send c _   -> statusAt c env == Empty
    Recv c _   -> statusAt c env == Full

transPi :: Channel -> [ChanDec] -> Env -> Env
transPi c dOSs env =
  rmChan c $
  addChans [ (d, (Proj l n, projSession (fromIntegral n) session))
           | (d, n) <- zip ds [(0 :: Int)..] ] env
  where (l, session) = env ! c
        ds = map _argName dOSs

transProc :: Env -> Proc -> [Pref]
transProc env x = case x of
  Ax{} ->
    error $ "transProc" ++ show x
  At{} ->
    error $ "transProc" ++ show x
  Act acts procs ->
    transAct env acts procs

-- prefixes about different channels can be reordered
transAct :: Env -> [Pref] -> [Proc] -> [Pref]
transAct env prefs0 procs =
  case prefs0 of
    []         -> transProcs env (filter0s procs) []
    pref:prefs -> pref : transAct (transPref pref env) prefs procs

transPref :: Pref -> Env -> Env
transPref pref =
  case pref of
    Nu (Arg c0 c0OS) (Arg c1 c1OS) ->
      let Just (c0S , c1S) = extractDuals (c0OS, c1OS)
          l = Root c0
      in
      addLocs  (sessionStatus (const Empty) l c0S) .
      addChans [(c0,(l,c0S)),(c1,(l,c1S))]
    Split _ c ds ->
      transPi c ds
    Send c _ ->
      actEnv c
    Recv c _ ->
      actEnv c
    NewSlice{} ->
      id

-- Assumption input processes should not have zeros (filter0s)
transProcs :: Env -> [Proc] -> [Proc] -> [Pref]
transProcs _   []       []      = []
transProcs _   []       waiting = error $ "transProcs: impossible all the processes are stuck: " ++ pretty waiting
transProcs env [p]      []      = transProc env p
transProcs env (p0:p0s) waiting =
  case p0 of
    Act acts@(_:_) procs0 ->
      case isReady env acts of
        Nothing ->
          transProcs env p0s (p0 : waiting)
        Just (readyPis,restPis) ->
          transAct env readyPis (p0s ++ reverse waiting ++ [restPis `actP` procs0])

    At{} ->
      error "transProcs: At"

    -- One should expand the forwarders
    Ax{} ->
      error "transProcs: Ax"

    Act [] _procs0 ->
      error "transProcs: impossible" -- filter0s prevents that

transDec :: Dec -> Dec
transDec x = case x of
  Sig _d _t -> x
  Dec d cs proc -> Dec d cs (transProc env proc `actP` [])
    where
      decSt Snd{} = Empty
      decSt Rcv{} = Full
      decSt End{} = Empty
      decSt _     = error "transDec.decSt: impossible"
      env = addLocs  [ ls          | Arg c (Just s) <- cs, ls <- sessionStatus decSt (Root c) s ] $
            addChans [ (c, (l, s)) | Arg c (Just s) <- cs, let l = Root c ]
            emptyEnv

transProgram :: Program -> Program
transProgram (Program decs) = Program (map transDec decs)
-- -}
-- -}
-- -}
-- -}