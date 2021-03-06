import Lattice as L
import Scheduler as S
open import Scheduler.Security

module Concurrent.LowEq {𝓛 : L.Lattice} {𝓢 : S.Scheduler 𝓛} (A : L.Label 𝓛) (𝓝 : NIˢ 𝓛 A 𝓢) where

open import Relation.Nullary
open import Types 𝓛

open import Sequential.Calculus 𝓛 hiding (Ms ; Γ)
open import Sequential.Semantics 𝓛

open import Concurrent.Calculus 𝓛 𝓢
open import Concurrent.Erasure A 𝓝
open import Concurrent.Graph A 𝓝

open Scheduler.Security.NIˢ 𝓛 A 𝓝 renaming (State to Stateˢ)
open import Relation.Binary.PropositionalEquality
open import Data.Empty

open import Data.Product using (_×_)
import Data.Product as P

--------------------------------------------------------------------------------

_≌ᴾ⟨_⟩_ : ∀ {l} -> Pool l -> Dec (l ⊑ A) ->  Pool l -> Set
T₁ ≌ᴾ⟨ x ⟩ T₂ = εᴾ x T₁ ≡ εᴾ x T₂

-- Structural low-equivalence for Thread pool
data _≈ᴾ⟨_⟩_ {l : Label} (T₁ : Pool l) (x : Dec (l ⊑ A)) (T₂ : Pool l) : Set where
  Kᴾ : ∀ {Tᴱ : Pool l} -> Eraseᴾ x T₁ Tᴱ -> Eraseᴾ x T₂ Tᴱ -> T₁ ≈ᴾ⟨ x ⟩ T₂

⌞_⌟ᴾ : ∀ {l} {T₁ T₂ : Pool l} {x : Dec (l ⊑ A)}-> T₁ ≈ᴾ⟨ x ⟩ T₂ -> T₁ ≌ᴾ⟨ x ⟩ T₂
⌞ Kᴾ e₁ e₂ ⌟ᴾ rewrite unlift-εᴾ e₁ | unlift-εᴾ e₂ = refl

⌜_⌝ᴾ : ∀ {l} {x : Dec (l ⊑ A)} {T₁ T₂ : Pool l} -> T₁ ≌ᴾ⟨ x ⟩ T₂ -> T₁ ≈ᴾ⟨ x ⟩ T₂
⌜_⌝ᴾ {x = x} {T₁} {T₂} eq with lift-εᴾ x T₁ | lift-εᴾ x T₂
... | e₁ | e₂ rewrite eq = Kᴾ e₁ e₂

ext-≈ᴾ : ∀ {l} {x : Dec (l ⊑ A)} {T₁ T₂ : Pool l} -> T₁ ≈ᴾ⟨ x ⟩ T₂ -> (y : Dec (l ⊑ A)) -> T₁ ≈ᴾ⟨ y ⟩ T₂
ext-≈ᴾ (Kᴾ e₁ e₂) y = Kᴾ (ext-εᴾ e₁ y) (ext-εᴾ e₂ y)

open import Sequential.Security.LowEq 𝓛 A hiding (_≈ᴾ⟨_⟩_ ; _≅ᴾ_ ; refl-≈ᴾ ; sym-≈ᴾ ; trans-≈ᴾ ; _≈ˢ_ ; ⌞_⌟ᴾ ; ext-≈ᴾ )

cons≈ᴾ : ∀ {l} {t₁ t₂ : Thread l} {x : Dec (l ⊑ A)} {T₁ T₂ : Pool l} -> t₁ ≈ᵀˢ⟨ x ⟩ t₂ -> T₁ ≈ᴾ⟨ x ⟩ T₂ -> (t₁ ◅ T₁) ≈ᴾ⟨ x ⟩ (t₂ ◅ T₂)
cons≈ᴾ (Kᵀˢ e₁ e₂)  (Kᴾ (Mapᵀ x) (Mapᵀ x₁)) = Kᴾ (Mapᵀ (e₁ ◅ x)) (Mapᵀ (e₂ ◅ x₁))
cons≈ᴾ eq₁ (Kᴾ ∙ ∙) = Kᴾ ∙ ∙

--------------------------------------------------------------------------------

-- Strucutral low-equivalence for Pools (point-wise)
data _map-≈ᴾ_ {ls} (P₁ P₂ : Pools ls) : Set where
  K-mapᴾ : ∀ {Pᴱ : Pools ls} -> EraseMapᴾ P₁ Pᴱ -> EraseMapᴾ P₂ Pᴱ -> P₁ map-≈ᴾ P₂

_≅ᴾ_ : ∀ {ls} (P₁ P₂ : Pools ls) -> Set
P₁ ≅ᴾ P₂ =  map-εᴾ P₁ ≡ map-εᴾ P₂

map-⌞_⌟ᴾ : ∀ {ls} {P₁ P₂ : Pools ls} -> P₁ map-≈ᴾ P₂ -> P₁ ≅ᴾ P₂
map-⌞ K-mapᴾ e₁ e₂ ⌟ᴾ rewrite unlift-map-εᴾ e₁ | unlift-map-εᴾ e₂ = refl

map-⌜_⌝ᴾ : ∀ {ls} {P₁ P₂ : Pools ls} -> P₁ ≅ᴾ P₂ -> P₁ map-≈ᴾ P₂
map-⌜_⌝ᴾ {P₁ = P₁} {P₂} eq with lift-map-εᴾ P₁ | lift-map-εᴾ P₂
... | e₁ | e₂ rewrite eq = K-mapᴾ e₁ e₂

refl-≈ᴾ : ∀ {ls} {P : Pools ls} ->  P map-≈ᴾ P
refl-≈ᴾ = map-⌜ refl ⌝ᴾ

sym-≈ᴾ :  ∀ {ls} {P₁ P₂ : Pools ls} -> P₁ map-≈ᴾ P₂ -> P₂ map-≈ᴾ P₁
sym-≈ᴾ x  = map-⌜ sym map-⌞ x ⌟ᴾ ⌝ᴾ

trans-≈ᴾ :  ∀ {ls} {P₁ P₂ P₃ : Pools ls} -> P₁ map-≈ᴾ P₂ -> P₂ map-≈ᴾ P₃ -> P₁ map-≈ᴾ P₃
trans-≈ᴾ x y = map-⌜ trans map-⌞ x ⌟ᴾ map-⌞ y ⌟ᴾ ⌝ᴾ

cons-map-≈ᵀ : ∀ {l ls} {u : Unique l ls} {T₁ T₂} {P₁ P₂ : Pools ls} -> T₁ ≈ᴾ⟨ l ⊑? A ⟩ T₂ -> P₁ map-≈ᴾ P₂ -> (T₁ ◅ P₁) map-≈ᴾ (T₂ ◅ P₂)
cons-map-≈ᵀ (Kᴾ x₁ x₂) (K-mapᴾ x₃ x₄) = K-mapᴾ (x₁ ◅ x₃) (x₂ ◅ x₄)

--------------------------------------------------------------------------------

_≅ᴳ_ : ∀ {ls} (g₁ g₂ : Global ls) -> Set
g₁ ≅ᴳ g₂ = εᴳ g₁ ≡ εᴳ g₂

lift-εᴳ : ∀ {ls} {Σ₁ Σ₂ : Stateˢ} {Γ₁ Γ₂ : Heaps ls} {P₁ P₂ : Pools ls} {Ms₁ Ms₂ : Memories ls}
           -> Σ₁ ≡ Σ₂ -> Ms₁ ≡ Ms₂ -> Γ₁ ≡ Γ₂ -> P₁ ≡ P₂ ->
           _≡_ {_} {Global ls} ⟨ Σ₁ , Ms₁ , Γ₁ , P₁ ⟩ ⟨ Σ₂ , Ms₂ , Γ₂ , P₂ ⟩
lift-εᴳ eq₁ eq₂ eq₃ eq₄ rewrite eq₁ | eq₂ | eq₃ | eq₄ = refl

-- structural low-equivalence for global configuration
record _≈ᴳ_ {ls} (g₁ g₂ : Global ls) : Set where
  constructor ⟨_,_,_,_⟩
  field
      Σ₁≈Σ₂ : (Σ g₁) ≈ˢ (Σ g₂)
      Ms₁≈Ms₂ : (Ms g₁) map-≈ᴹ (Ms g₂)
      Γ₁≈Γ₂ : (Γ g₁) map-≈ᴴ (Γ g₂)
      P₁≈P₂ : (P g₁) map-≈ᴾ (P g₂)

open _≈ᴳ_ public

⌜_⌝ᴳ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≅ᴳ g₂ -> g₁ ≈ᴳ g₂
⌜ x ⌝ᴳ = ⟨ (⌜ auxˢ x ⌝) , map-⌜ auxᴹ x ⌝ᴹ , map-⌜ auxᴴ x ⌝ᴴ , map-⌜ auxᴾ x ⌝ᴾ ⟩
  where auxˢ : ∀ {ls} {Σ₁ Σ₂ : Stateˢ} {Γ₁ Γ₂ : Heaps ls} {P₁ P₂ : Pools ls} {Ms₁ Ms₂ : Memories ls} ->
                 _≡_ {_} {Global ls} ⟨ Σ₁ , Ms₁ , Γ₁ , P₁ ⟩ ⟨ Σ₂ , Ms₂ , Γ₂ , P₂ ⟩ -> Σ₁ ≡ Σ₂
        auxˢ refl = refl

        auxᴾ : ∀ {ls} {Σ₁ Σ₂ : Stateˢ} {Γ₁ Γ₂ : Heaps ls} {P₁ P₂ : Pools ls} {Ms₁ Ms₂ : Memories ls} ->
                 _≡_ {_} {Global ls} ⟨ Σ₁ , Ms₁ , Γ₁ , P₁ ⟩ ⟨ Σ₂ , Ms₂ , Γ₂ , P₂ ⟩ -> P₁ ≡ P₂
        auxᴾ refl = refl

        auxᴴ : ∀ {ls} {Σ₁ Σ₂ : Stateˢ} {Γ₁ Γ₂ : Heaps ls} {P₁ P₂ : Pools ls} {Ms₁ Ms₂ : Memories ls} ->
                 _≡_ {_} {Global ls} ⟨ Σ₁ , Ms₁ , Γ₁ , P₁ ⟩ ⟨ Σ₂ , Ms₂ , Γ₂ , P₂ ⟩ -> Γ₁ ≡ Γ₂
        auxᴴ refl = refl

        auxᴹ : ∀ {ls} {Σ₁ Σ₂ : Stateˢ} {Γ₁ Γ₂ : Heaps ls} {P₁ P₂ : Pools ls} {Ms₁ Ms₂ : Memories ls} ->
                 _≡_ {_} {Global ls} ⟨ Σ₁ , Ms₁ , Γ₁ , P₁ ⟩ ⟨ Σ₂ , Ms₂ , Γ₂ , P₂ ⟩ -> Ms₁ ≡ Ms₂
        auxᴹ refl = refl

⌞_⌟ᴳ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ g₂ -> g₁ ≅ᴳ g₂
⌞ ⟨ Σ₁≈Σ₂ , Ms₁≈Ms₁ , Γ₁≈Γ₂ , P₁≈P₂ ⟩ ⌟ᴳ = lift-εᴳ (⌞ Σ₁≈Σ₂ ⌟) map-⌞ Ms₁≈Ms₁ ⌟ᴹ map-⌞ Γ₁≈Γ₂ ⌟ᴴ map-⌞ P₁≈P₂ ⌟ᴾ

refl-≈ᴳ : ∀ {ls} {g : Global ls} -> g ≈ᴳ g
refl-≈ᴳ = ⌜ refl  ⌝ᴳ

sym-≈ᴳ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ g₂ -> g₂ ≈ᴳ g₁
sym-≈ᴳ x = ⌜ sym ⌞ x ⌟ᴳ ⌝ᴳ

trans-≈ᴳ : ∀ {ls} {g₁ g₂ g₃ : Global ls} -> g₁ ≈ᴳ g₂ -> g₂ ≈ᴳ g₃ -> g₁ ≈ᴳ g₃
trans-≈ᴳ x y = ⌜ trans ⌞ x ⌟ᴳ ⌞ y ⌟ᴳ ⌝ᴳ

--------------------------------------------------------------------------------

open import Data.Nat

-- Lifts annotations in the scheduler to configurations
record _≈ᴳ-⟨_,_⟩_ {ls} (g₁ : Global ls) (n₁ : ℕ) (n₂ : ℕ) (g₂ : Global ls) : Set where
  constructor ⟨_,_,_,_⟩
  field
      Σ₁≈Σ₂′ : (Σ g₁) ≈ˢ-⟨ n₁ , n₂ ⟩ (Σ g₂)
      Ms₁≈Ms₂′ : (Ms g₁) map-≈ᴹ (Ms g₂)
      Γ₁≈Γ₂′ : (Γ g₁) map-≈ᴴ (Γ g₂)
      Ps₁≈Ps₂′ : (P g₁) map-≈ᴾ (P g₂)

alignᴳ : ∀ {ls} {g₁ g₂ : Global ls} -> (g₁≈g₂ : g₁ ≈ᴳ g₂) -> g₁ ≈ᴳ-⟨ offset₁ (Σ₁≈Σ₂ g₁≈g₂) , offset₂ (Σ₁≈Σ₂ g₁≈g₂) ⟩ g₂
alignᴳ ⟨ Σ₁≈Σ₂ , Ms₁≈Ms₂ , Γ₁≈Γ₂ , P₁≈P₂ ⟩ = ⟨ (align Σ₁≈Σ₂) , Ms₁≈Ms₂ , Γ₁≈Γ₂ , P₁≈P₂ ⟩

forgetᴳ : ∀ {ls n₁ n₂} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ-⟨ n₁ , n₂ ⟩ g₂ -> g₁ ≈ᴳ g₂
forgetᴳ ⟨ Σ₁≈Σ₂ , Ms₁≈Ms₂ , Γ₁≈Γ₂ , P₁≈P₂ ⟩ = ⟨ (forget Σ₁≈Σ₂) , Ms₁≈Ms₂ , Γ₁≈Γ₂ , P₁≈P₂ ⟩

open _≈ᴳ-⟨_,_⟩_ public

-- TODO not needed
-- get≈ˢ : ∀ {ls n₁ n₂} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ-⟨ n₁ , n₂ ⟩ g₂ -> (Σ g₁) ≈ˢ-⟨ n₁ , n₂ ⟩ (Σ g₂)
-- get≈ˢ ⟨ Σ₁≈Σ₂ , Ms₁≈Ms₂ , Γ₁≈Γ₂ , P₁≈P₂ ⟩ = Σ₁≈Σ₂

-- get≈ᴹ : ∀ {ls n₁ n₂} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ-⟨ n₁ , n₂ ⟩ g₂ -> (Ms g₁) map-≈ᴹ (Ms g₂)
-- get≈ᴹ ⟨ Σ₁≈Σ₂′ , Ms₁≈Ms₂′ , Γ₁≈Γ₂′ , Ps₁≈Ps₂′ ⟩ = Ms₁≈Ms₂′

-- get≈ᴴ : ∀ {ls n₁ n₂} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ-⟨ n₁ , n₂ ⟩ g₂ -> (Γ g₁) map-≈ᴴ (Γ g₂)
-- get≈ᴴ ⟨ Σ₁≈Σ₂′ , Ms₁≈Ms₂′ , Γ₁≈Γ₂′ , Ps₁≈Ps₂′ ⟩ = Γ₁≈Γ₂′

-- get≈ᴾ : ∀ {ls n₁ n₂} {g₁ g₂ : Global ls} -> g₁ ≈ᴳ-⟨ n₁ , n₂ ⟩ g₂ -> (P g₁) map-≈ᴾ (P g₂)
-- get≈ᴾ ⟨ Σ₁≈Σ₂′ , Ms₁≈Ms₂′ , Γ₁≈Γ₂′ , Ps₁≈Ps₂′ ⟩ = Ps₁≈Ps₂′

--------------------------------------------------------------------------------

open import Function
open import Data.Product

memberᴾ-≈ : ∀ {ls L} {T₁ : Pool L} {P₁ P₂ : Pools ls} -> (x : Dec (L ⊑ A)) -> L ↦ T₁ ∈ᴾ P₁ -> P₁ map-≈ᴾ P₂ -> ∃ (λ T₂ -> T₁ ≈ᴾ⟨ x ⟩ T₂ × L ↦ T₂ ∈ᴾ P₂)
memberᴾ-≈ x here (K-mapᴾ (e₁ ◅ e₂) (e₃ ◅ e₄)) = _ , ext-≈ᴾ (Kᴾ e₁ e₃) x , here
memberᴾ-≈ x (there L∈P) (K-mapᴾ (x₁ ◅ x₂) (x₃ ◅ x₄)) = P.map id (P.map id there) (memberᴾ-≈ x L∈P (K-mapᴾ x₂ x₄))

memberᵀ-≈ : ∀ {n L} {T₁ T₂ : Pool L} {t₁ : Thread L} {L⊑A : L ⊑ A} -> n ↦ t₁ ∈ᵀ T₁ -> T₁ ≈ᴾ⟨ yes L⊑A ⟩ T₂
              -> ∃ (λ t₂ → (t₁ ≈ᵀˢ⟨ yes L⊑A ⟩ t₂) × n ↦ t₂ ∈ᵀ T₂)
memberᵀ-≈ here (Kᴾ (Mapᵀ (e ◅ e₁)) (Mapᵀ (e' ◅ e₁'))) = _ , (Kᵀˢ e e') , here
memberᵀ-≈ (there n∈T) (Kᴾ (Mapᵀ (e ◅ e₁)) (Mapᵀ (e' ◅ e₁'))) = P.map id (P.map id there) (memberᵀ-≈ n∈T (Kᴾ (Mapᵀ e₁) (Mapᵀ e₁')))

updateᵀ-≈ : ∀ {n L} {T₁ T₁' T₂ : Pool L} {t₁ t₂ : Thread L} {L⊑A : L ⊑ A}  ->
            T₁ ≈ᴾ⟨ yes L⊑A ⟩ T₂ -> t₁ ≈ᵀˢ⟨ yes L⊑A ⟩ t₂ -> T₁' ≔ T₁ [ n ↦ t₁ ]ᵀ
            -> ∃ (λ T₂' → T₁' ≈ᴾ⟨ yes L⊑A ⟩ T₂'  × T₂' ≔ T₂ [ n ↦ t₂ ]ᵀ)
updateᵀ-≈ (Kᴾ (Mapᵀ (_ ◅ e₁)) (Mapᵀ (_ ◅ e₁'))) (Kᵀˢ e e') here = _ , (Kᴾ (Mapᵀ (e ◅ e₁)) (Mapᵀ (e' ◅ e₁'))) , here
updateᵀ-≈ (Kᴾ (Mapᵀ (e ◅ e₁)) (Mapᵀ (e' ◅ e₁'))) eq₂ (there u)
  = P.map (_◅_ _) (P.map (cons≈ᴾ (Kᵀˢ e e')) there) (updateᵀ-≈ (Kᴾ (Mapᵀ e₁) (Mapᵀ e₁')) eq₂ u)

updateᴾ-≈ : ∀ {l ls} {P₁ P₂ P₁' : Pools ls} {T₁ T₂ : Pool l} {x : Dec (l ⊑ A)} ->
             P₁ map-≈ᴾ P₂ -> T₁ ≈ᴾ⟨ x ⟩ T₂  ->  P₁' ≔ P₁ [ l ↦ T₁ ]ᴾ -> ∃ (λ P₂' → P₁' map-≈ᴾ P₂' × P₂' ≔ P₂ [ l ↦ T₂ ]ᴾ)
updateᴾ-≈ {l} (K-mapᴾ (_ ◅ e₁) (_ ◅ e₁')) (Kᴾ e e') here = _ , K-mapᴾ (ext-εᴾ e (l ⊑? A) ◅ e₁) (ext-εᴾ e' (l ⊑? A) ◅ e₁') , here
updateᴾ-≈ (K-mapᴾ (e ◅ e₁) (e' ◅ e₁')) eq₂ (there u₁)  = P.map (_◅_ _) (P.map (cons-map-≈ᵀ (Kᴾ e e')) there) (updateᴾ-≈  (K-mapᴾ e₁ e₁') eq₂ u₁)

-- In the fork case we need to produce a low-eq proof
-- updateᵀ-≈ : ∀ {n L} {T₁ T₁' T₂ : Pool L} {t₁ t₂ : Thread L} {L⊑A : L ⊑ A} -> T₁' ≔ T₁ [ n ↦ t₁ ]ᵀ ->
--             T₁ ≈ᴾ⟨ yes L⊑A ⟩ T₂ -> ∃ (λ T₂' → T₂' ≔ T₂ [ n ↦ t₂ ]ᵀ)
-- updateᵀ-≈ here (Kᴾ (Mapᵀ (_ ◅ e₁)) (Mapᵀ (_ ◅ e₁'))) = _ , here
-- updateᵀ-≈ (there u) (Kᴾ (Mapᵀ (e ◅ e₁)) (Mapᵀ (e' ◅ e₁')))
--   = P.map (_◅_ _) there (updateᵀ-≈ u (Kᴾ (Mapᵀ e₁) (Mapᵀ e₁')))

-- updateᴾ-≈ : ∀ {l ls} {P₁ P₂ P₁' : Pools ls} {T₁ T₂ : Pool l} -> P₁' ≔ P₁ [ l ↦ T₁ ]ᴾ ->
--              P₁ map-≈ᴾ P₂ -> ∃ (λ P₂' → P₂' ≔ P₂ [ l ↦ T₂ ]ᴾ)
-- updateᴾ-≈ {l} here (K-mapᴾ (_ ◅ e₁) (_ ◅ e₁')) = _  , here
-- updateᴾ-≈ (there u₁) (K-mapᴾ (e ◅ e₁) (e' ◅ e₁')) = P.map (_◅_ _) there (updateᴾ-≈ u₁ (K-mapᴾ e₁ e₁'))

lengthᵀ-≈ : ∀ {l} {T₁ T₂ : Pool l} -> (l⊑A : l ⊑ A) -> T₁ ≈ᴾ⟨ yes l⊑A ⟩ T₂ -> lengthᵀ T₁ ≡ lengthᵀ T₂
lengthᵀ-≈ {_} {T₁} {T₂} l⊑A T₁≈T₂ rewrite lengthᵀ-ε-≡ l⊑A T₁ | lengthᵀ-ε-≡ l⊑A T₂ | ⌞ T₁≈T₂ ⌟ᴾ = refl

newᵀ-≈ : ∀ {l} {T₁ T₂ : Pool l} {t₁ t₂ : Thread l} {x : Dec _} -> T₁ ≈ᴾ⟨ x ⟩ T₂ -> t₁ ≈ᵀˢ⟨ x ⟩ t₂ -> (T₁ ▻ t₁) ≈ᴾ⟨ x ⟩ (T₂ ▻ t₂)
newᵀ-≈ (Kᴾ (Mapᵀ []) (Mapᵀ [])) (Kᵀˢ e₁ e₂) = Kᴾ (Mapᵀ (e₁ ◅ [])) (Mapᵀ (e₂ ◅ []))
newᵀ-≈ (Kᴾ (Mapᵀ (x₁ ◅ x)) (Mapᵀ (x₂ ◅ x₃))) t₁≈t₂ with newᵀ-≈ (Kᴾ (Mapᵀ x) (Mapᵀ x₃)) t₁≈t₂
... | Kᴾ (Mapᵀ e₁) (Mapᵀ e₂) = Kᴾ (Mapᵀ (x₁ ◅ e₁)) (Mapᵀ (x₂ ◅ e₂))
newᵀ-≈ (Kᴾ (Mapᵀ ∙) (Mapᵀ ∙)) t₁≈t₂ = Kᴾ (Mapᵀ ∙) (Mapᵀ ∙)
newᵀ-≈ (Kᴾ ∙ ∙) t₁≈t₂ = Kᴾ ∙ ∙


open import Scheduler.Base 𝓛
open import Scheduler.Security 𝓛 A as S₁

forkᴱ-≈  : ∀ {l h} {T₁ T₂ : Pool h} {l⊑A : l ⊑ A} {l⊑h : l ⊑ h} ->
             (x : Dec (h ⊑ A)) -> T₁ ≈ᴾ⟨ x ⟩ T₂ -> ( Fork h (lengthᵀ T₁) l⊑h ) S₁.≈ᴱ⟨ yes l⊑A ⟩ ( Fork h (lengthᵀ T₂) l⊑h )
forkᴱ-≈ (yes p) T₁≈T₂ rewrite lengthᵀ-≈ p T₁≈T₂ = S₁.Forkᴸ p
forkᴱ-≈ (no ¬p) eq = S₁.Forkᴴ ¬p

--------------------------------------------------------------------------------
