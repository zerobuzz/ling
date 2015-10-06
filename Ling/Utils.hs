{-# LANGUAGE CPP             #-}
{-# LANGUAGE LambdaCase      #-}
{-# LANGUAGE Rank2Types      #-}
{-# LANGUAGE TemplateHaskell #-}
module Ling.Utils
  ( module Ling.Utils
  , (<>)
  , pure
  , (<$>)
  , (<*>)) where

#if !(MIN_VERSION_base(4,8,0))
import           Control.Applicative
#endif
import           Control.Lens
import           Data.Map            (Map)
import qualified Data.Map            as Map
import           Data.Monoid
import           Data.Set            (Set, intersection, union)
import qualified Data.Set            as Set
import           Debug.Trace
import           Ling.Abs

type Endom a = a -> a
type EndoM m a = a -> m a
type Msg = String
type Verbosity = Bool

data Arg a = Arg { _argName :: Name, _unArg :: a }
  deriving (Eq,Ord,Show,Read)

$(makeLenses ''Arg)

data Abs a b = Abs { _argAbs :: Arg a, _bodyAbs :: b }

$(makeLenses ''Abs)

data Telescope a b = Telescope { _argsTele :: [Arg a], _bodyTele :: b }

$(makeLenses ''Telescope)

type Channel = Name

ø :: Monoid a => a
ø = mempty

nameString :: Iso' Name String
nameString = iso unName Name

prefName :: String -> Endom Name
prefName s n = n & nameString %~ (s ++)

suffName :: String -> Endom Name
suffName s n = n & nameString %~ (++ s)

traceShow :: Show a => String -> a -> a
traceShow msg x = trace (msg ++ " " ++ show x) x

debugTraceWhen :: Bool -> Msg -> a -> a
debugTraceWhen b s =
  if b then trace (unlines . map ("[DEBUG]  "++) . lines $ s) else id

unName :: Name -> String
unName (Name x) = x

l2s :: Ord a => [a] -> Set a
l2s = Set.fromList
s2l :: Ord a => Set a -> [a]
s2l = Set.toList
l2m :: Ord k => [(k,a)] -> Map k a
l2m = Map.fromList
m2l :: Ord k => Map k a -> [(k,a)]
m2l = Map.toList

countMap :: (a -> Bool) -> Map k a -> Int
countMap p = Map.size . Map.filter p

singletons :: Ord a => [a] -> Set (Set a)
singletons = l2s . map Set.singleton

infixr 3 ||>
(||>) :: Monad m => Bool -> m Bool -> m Bool
True  ||> _  = return True
False ||> my = my

infixr 3 <||>
(<||>) :: Monad m => m Bool -> m Bool -> m Bool
mx <||> my = do x <- mx
                if x then return True
                     else my

infixr 3 &&>
(&&>) :: Monad m => Bool -> m Bool -> m Bool
True  &&> my = my
False &&> _  = return False

infixr 3 <&&>
(<&&>) :: Monad m => m Bool -> m Bool -> m Bool
mx <&&> my = do x <- mx
                if x then my
                     else return False

-- Given a list of sets, return the set of elements which are
-- redundant, namely appear more than once.
-- `redudant` can be used to check the disjointness of sets.
-- Indeed if the result is empty all the sets are disjoint,
-- a non-empty result can be used to report errors.
redundant :: Ord a => [Set a] -> Set a
redundant = snd . foldr f (Set.empty, Set.empty)
  where
    f xs (acc, res) =
      (acc `union` xs, (acc `intersection` xs) `union` res)

subList :: Eq a => [a] -> [a] -> Bool
subList []    _  = True
subList (_:_) [] = False
subList (x:xs) (y:ys)
  | x == y    = xs     `subList` ys
  | otherwise = (x:xs) `subList` ys

rmDups :: Eq a => [a] -> [a]
rmDups (x1:x2:xs)
  | x1 == x2  = rmDups (x1:xs)
  | otherwise = x1 : rmDups (x2:xs)
rmDups xs = xs

substMember :: Ord a => (Set a,a) -> Endom a
substMember (xs,y) z | z `Set.member` xs = y
                     | otherwise         = z

subst1 :: Eq a => (a,a) -> Endom a
subst1 (x,y) z | x == z    = y
               | otherwise = z

hasKey :: At m => Index m -> Getter m Bool
hasKey k = at k . to (isn't _Nothing)

hasNoKey :: At m => Index m -> Getter m Bool
hasNoKey k = at k . to (isn't _Just)

-- The two setters must not overlap.
-- If they do we can break the composition law:
-- Given l, f, g such that: f.g.f.g =/= f.f.g.g
-- ll = mergeSetters l l
-- (ll %~ f) . (ll %~ g)
-- ==
-- l %~ f.f.g.g
-- =/=
-- l %~ f.g.f.g
-- ==
-- ll %~ (f.g)
mergeSetters :: (Profunctor p, Settable f)
             => Setting p s t a b
             -> Setting p t u a b
             -> Over p f s u a b
mergeSetters l0 l1 = sets $ \f -> over l1 f . over l0 f

-- There must be something equivalent in lens
composeMap :: (a -> Endom b) -> [a] -> Endom b
composeMap f = foldr ((.) . f) id
