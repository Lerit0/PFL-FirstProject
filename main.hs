import Parsing
import Data.Char (isLower)

type Name = Char
type Env = [(Name, Bool)]
data Prop = Const Bool    -- constants (True/False)
          | Var Char      -- variables
          | And Prop Prop -- conjunction
          | Or Prop Prop  -- disjunction 
          | Not Prop      -- negation
          deriving (Show)

eval :: Env -> Prop -> Bool
eval env (Const b) = b
eval env (Var x) = case lookup x env of
                     Just b -> b
                     Nothing -> error "undefined variable"
eval env (Not p) = not (eval env p)
eval env (And p q) = (eval env p) && (eval env q)
eval env (Or p q) = (eval env p) || (eval env q)

vars :: Prop -> [Name]
vars p = nub (loop p [])
 where loop (Const _) acc = acc
       loop (Var x) acc = x : acc
       loop (Not p') acc = loop p' acc
       loop (And p' q') acc = loop p' (loop q' acc)
       loop (Or p' q') acc = loop p' (loop q' acc)
       
booleans :: Int -> [[Bool]]
booleans 0 = [[]]
booleans n = (map ([False]++) (booleans (n-1))) ++ (map ([True]++) (booleans (n-1)))

environments :: [Name] -> [Env]
environments xs = map (zip xs) (booleans (length xs))

-- Task 1
-- Grammar rules:
-- prop ::= term propCount
-- propCount ::= | term propCount | e

-- term ::= factor termCount
-- termCount ::= & factor termCount | e

-- factor ::= !factor | name | constant | (prop)

-- constant ::= T | F

prop :: Parser Prop
prop = do t <- term 
          propCont t

propCont :: Prop -> Parser Prop
propCont acc = do char '|'
                  t <- term
                  propCont (Or acc t)
               <|> return acc

term :: Parser Prop
term = do f <- factor
          termCont f

termCont :: Prop -> Parser Prop
termCont acc = do char '&'
                  f <- factor
                  termCont (And acc f)
               <|> return acc

factor :: Parser Prop
factor = do char '!'
            f <- factor
            return (Not f)
         <|> constant
         <|> do char '('
                p <- prop 
                char ')'
                return p
         <|> do n <- satisfy isLower
                return (Var n)

constant :: Parser Prop
constant = do char 'T'
              return (Const True)
          <|> do char 'F'
                 return (Const False)


-- Task 2 

-- Tautology => na tabela de verdade sao todos True
-- Contradiction => na tabela de verdade sao todo False
-- Contingent => Nao e tautology nem contradiction

main :: IO ()
main = do txt <- getContents
          processLines (lines txt)




nub :: Eq a => [a] -> [a]
nub [] = []
nub (x:xs) = x : nub (filter (/=x) xs) 

processLines :: [String] -> IO ()
processLines [] = return ()
processLines (l:ls) = do putStrLn (evaluateLine l)
                         processLines  ls

evaluateLine :: String -> String
evaluateLine txt = case parse prop txt of
                [(p, "")] -> classify p
                _ -> "parse error; try again" 

classify :: Prop -> String
classify p | all (\e -> eval e p) envs = "TAUTOLOGY"
           | not (any (\e -> eval e p) envs) = "CONTRADICTION"
           | otherwise = "CONTINGENT"
  where envs = environments (vars p)
       
