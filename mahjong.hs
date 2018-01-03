import Data.List
import Data.Maybe
import Control.Monad.State
import System.Random
import Data.Array.IO
import Control.Monad

data Dragon = Red | White | Green deriving (Eq, Ord, Show)
data Wind = North | East | South | West deriving (Eq, Ord, Show)
data Tile = Dragon Dragon | Wind Wind | Bamboo Int | Character Int | Pin Int deriving (Eq, Ord, Show)
newtype Deck = Deck [Tile]
newtype Hand = Hand [Tile]
type GameState = (Deck, [Tile])


dragons = map Dragon [Red, White, Green]

winds = map Wind [North, East, South, West]

bamboos = map Bamboo  [1..9]

characters = map Character [1..9]

pins = map Pin  [1..9]

tiles = dragons ++ winds ++ bamboos ++ characters ++ pins

-- | Randomly shuffle a list
--   /O(N)/
shuffle :: [a] -> IO [a]
shuffle xs = do
        ar <- newArray n xs
        forM [1..n] $ \i -> do
            j <- randomRIO (i,n)
            vi <- readArray ar i
            vj <- readArray ar j
            writeArray ar j vi
            return vj
  where
    n = length xs
    newArray :: Int -> [a] -> IO (IOArray Int a)
    newArray n xs =  newListArray (1,n) xs


firstTenpai :: Deck -> Hand
firstTenpai deck = evalState evalTenpai (deck, [])

evalTenpai :: State GameState Hand
evalTenpai = do
  (draw, drawn) <- get
  case draw of
    Deck [] -> Hand [] --should never happen
    Deck (x:xs) ->
      case foundTenpai (x:drawn) of
        Just hand -> return hand
        Nothing -> do
          put (xs, x:drawn)
          return evalTenpai

foundTenpai _ [] = Just $ Hand []
foundTenpai numSets drawn = let
  sorted = sort drawn
  in foundPairTenpai numSets sorted [] <|> foundTankiTenpai numSets sorted [] 

foundTankiTenpai :: Int -> [Tile] -> [Tile] -> Maybe Hand
foundTankiTenpai _ [] _ = Nothing
foundTankiTenpai 0 (x:xs) unused = Just . Hand . (:[]) . head $ reverse unused ++ [x] ++ xs
foundTankiTenpai numSets (x:xs) unused =
  (do
      (set, rest) <- tryMakeRun x xs
      Hand hand <- foundTankiTenpai (numSets - 1) rest unused
      return . Hand $ set ++ hand
  ) <|>
  (do
      (set, rest) <- tryMakeTrip x xs
      Hand hand <- foundTankiTenpai (numSets - 1) rest unused
      return . Hand $ set ++ hand
  ) <|>
  (do
      foundTankiTenpai numSets xs (x:unused)
  )

findPair [] = Nothing
findPair [x] = Nothing
findPair (x:y:xs) | x == y = Just [x,y]
findPair (x:xs) = findPair xs

foundPairTenpai :: Int -> [Tile] -> [Tile] -> Maybe Hand
foundPairTenpai _ [] _ = Nothing
foundPairTenpai _ [x] _ = Nothing
foundPairTenpai 1 xs unused = do
  let rest = reverse unused ++ xs 
  (wait, restFinal) <- findKanchan rest <|> findPenchan rest <|> findRyanmen rest <|> findPairRest rest
  pair <- findPair restFinal
  return . Hand $ wait ++ pair
foundPairTenpai numSets (x:xs) unused =
  (do
      (set, rest) <- tryMakeRun x xs
      Hand hand <- foundPairTenpai (numSets - 1) rest unused
      return . Hand $ set ++ hand
  ) <|>
  (do
      (set, rest) <- tryMakeTrip x xs
      Hand hand <- foundPairTenpai (numSets - 1) rest unused
      return . Hand $ set ++ hand
  ) <|>
  (do
      foundPairTenpai numSets xs (x:unused)
  )
  
  
  

-- x:y:zs is sorted
-- returns (pair of x, rest of hand)
tryMakePair x (y:zs) | x == y = Just ([x,y], zs)
tryMakePair _ _ = Nothing

-- x:y:z:zs is sorted
-- returns (triplet of x, rest of hand
tryMakeTrip x (y:z:xs) | x == y && x == y = Just ([x,y,z], xs)
tryMakeTrip _ _ = Nothing

-- x:drawn is sorted
-- returns (set starting with x, rest of hand), with set being
-- 2 distinct tiles which fulfill cond
tryMakeCond2 cond x drawn = go x drawn []
  where
    -- go matches x with consecutive y and z, having to deal with duplicates
    go x [] _ = Nothing
    go x (y:ys) rest | x == y = go x ys (y:rest)
    go x (y:ys) rest = if cond x y then Just([x,y], reverse rest ++ ys) else Nothing

-- x:drawn is sorted
-- returns (set starting with x, rest of hand), with set being
-- 3 distinct tiles which fulfill cond
tryMakeCond3 cond x drawn = go x drawn []
  where
    -- go matches x with consecutive y and z, having to deal with duplicates
    go x [] _ = Nothing
    go x (y:ys) rest | x == y = go x ys (y:rest)
    go x (y:ys) rest = goMore x y ys rest
    -- goMore matches x and y with consecutive z, having to deal with duplicates
    goMore x y [] _ = Nothing
    goMore x y (z:zs) rest | z == y = goMore x y zs (z:rest)
    goMore x y (z:zs) rest = if cond x y z then Just([x,y,z], reverse rest ++ zs) else Nothing


completeRun x y z =
  case (x,y,z) of
    (Bamboo x', Bamboo y', Bamboo z') | y' == x'+1 && z' == y'+1 -> True
    (Character x', Character y', Character z') | y' == x'+1 && z' == y'+1 -> True
    (Pin x', Pin y', Pin z') | y' == x'+1 && z' == y'+1 -> True
    _ -> False

kanchan x y =
  case (x, y) of
    (Bamboo x', Bamboo y') | y' == x'+2 -> True
    (Pin x', Pin y') | y' == x'+2 -> True
    (Character x', Character y') | y' == x'+2 -> True
    _ -> False

penchan x y =
  case (x,y) of
    (Bamboo 1, Bamboo 2) -> True
    (Pin 1, Pin 2) -> True
    (Character 1, Character 1) -> True
    (Bamboo 8, Bamboo 9) -> True
    (Pin 8, Pin 9) -> True
    (Character 8, Character 9) -> True
    _ -> False

ryanmen x y = not (penchan x y) &&
  case (x, y) of
    (Bamboo x', Bamboo y') | y' == x'+1 -> True
    (Pin x', Pin y') | y' == x'+1 -> True
    (Character x', Character y') | y' == x'+1 -> True
    _ -> False
  

tryMakeRun = tryMakeCond3 completeRun
tryMakeKanchan = tryMakeCond2 kanchan
tryMakePenchan = tryMakeCond2 penchan
tryMakeRyanmen = tryMakeCond2 ryanmen

findWait :: (Tile -> [Tile] -> Maybe ([Tile], [Tile])) -> [Tile] -> Maybe ([Tile], [Tile])
findWait tryMake [] = Nothing
findWait tryMake (x:xs) = tryMake x xs <|> (findWait tryMake xs >>= \(wait, rest) -> Just (wait, x:rest))

findPairRest = findWait tryMakePair
findKanchan = findWait tryMakeKanchan
findPenchan = findWait tryMakePenchan
findRyanmen = findWait tryMakeRyanmen

main = do
  deck <- shuffle $ tiles ++ tiles ++ tiles ++ tiles
  tenpai <- return $ firstTenpai deck
  return ()
