module HalfSpaces.Constraint
  where
import           Data.IntMap.Strict           (IntMap, mergeWithKey)
import qualified Data.IntMap.Strict           as IM
import           Data.List                    (union, nub)
import           Data.Ratio                   (Rational)
import           Data.VectorSpace
import           HalfSpaces.LinearCombination
-- import           Data.Tuple         (swap)

data Sense = Gt | Lt
  deriving Eq

instance Show Sense where
  show Gt = ">="
  show Lt = "<="

data Constraint = Constraint LinearCombination Sense LinearCombination
  deriving (Eq, Show)

(.>=) :: LinearCombination -> LinearCombination -> Constraint
(.>=) lhs rhs = Constraint lhs Gt rhs

(.<=) :: LinearCombination -> LinearCombination -> Constraint
(.<=) lhs rhs = Constraint lhs Lt rhs

normalizeConstraint :: [Var] -> Constraint -> [Rational]
normalizeConstraint vars (Constraint lhs sense rhs) =
  let terms@(x:xs) = IM.elems $
                     mergeWithKey (\_ x y -> Just (x-y)) id id lhs' rhs'
  in
  if sense == Lt
    then xs ++ [x]
    else map negate xs ++ [-x]
  where lhs' = normalizeLinearCombination vars lhs
        rhs' = normalizeLinearCombination vars rhs

varsOfConstraint :: Constraint -> [Var]
varsOfConstraint (Constraint lhs _ rhs) =
  varsOfLinearCombo lhs `union` varsOfLinearCombo rhs

normalizeConstraints :: [Constraint] -> [[Rational]] -- for qhalf
normalizeConstraints constraints = map (normalizeConstraint vars) constraints
  where
    vars = nub $ concatMap varsOfConstraint constraints

x = newVar 1
y = newVar 2
z = newVar 3
xx = asLinearCombination x
yy = asLinearCombination y
c1 = yy .>= constant 1
c2 = xx .<= yy

constraints =
  [ x' .>= ((-5)*^one)
  , x' .<= (4*^one)
  , y' .>= ((-5)*^one)
  , y' .<= (3*^one ^-^ x')
  , z' .>= ((-10)*^one)
  , z' .<= (6*^one ^-^ x' ^-^ y')]
  where
    x = newVar 1
    y = newVar 2
    z = newVar 3
    x' = asLinearCombination x
    y' = asLinearCombination y
    z' = asLinearCombination z
    one = constant 1
