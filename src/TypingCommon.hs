module TypingCommon
  ( TypingContext,
    emptyContext,
    lookupVar,
    pushVar,
    (?>>),
    (||=),
    (>>=?),
    (<<=),
    Result,
    failure,
    success,
    (|++),
    (///),
  )
where

import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe, isNothing)
import LambdaTerm
import TypeTerm
import Debug.Trace (traceShow)

(///) :: Show a => b -> a -> b
(///) x y = if debugEnabled then traceShow y x else x
  where
    debugEnabled = True

type TypingContext a = Map.Map String [a]

type Result a = Either String a

failure :: String -> Result a
failure s = Left s /// s

success :: a -> Result a
success = Right

-- | If Left and Right are failure, prepend Right to Left.
--   Otherwise, return Left.
(|++) :: Result a -> Result b -> Result a
(|++) (Left s) (Left s') = Left (s' ++ "\n" ++ s)
(|++) l _ = l

emptyContext = Map.empty

lookupVar :: TypingContext a -> String -> Maybe a
lookupVar g v = head <$> Map.lookup v g

pushVar :: TypingContext a -> String -> a -> TypingContext a
pushVar g v t = Map.insert v (t : fromMaybe [] (Map.lookup v g)) g

-- | If the condition is true, return right
--   otherwise return nothing
(?>>) :: Bool -> Maybe a -> Maybe a
(?>>) p x = if p then x else Nothing

-- | Return left if Just, otherwise return right
(||=) :: Maybe a -> Maybe a -> Maybe a
(||=) Nothing d = d
(||=) x _ = x

-- | If given Nothing, return False; If given Just, apply function
(>>=?) :: Maybe a -> (a -> Bool) -> Bool
(>>=?) Nothing _ = False
(>>=?) (Just x) f = f x

-- | Either the left term should be nothing,
--   or the terms should be equal.
(<<=) :: Eq a => Maybe a -> Maybe a -> Bool
(<<=) x y = isNothing x || x == y
