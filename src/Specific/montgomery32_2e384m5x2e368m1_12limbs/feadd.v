Require Import Crypto.Arithmetic.PrimeFieldTheorems.
Require Import Crypto.Specific.montgomery32_2e384m5x2e368m1_12limbs.Synthesis.

(* TODO : change this to field once field isomorphism happens *)
Definition add :
  { add : feBW_small -> feBW_small -> feBW_small
  | forall a b, phiM_small (add a b) = F.add (phiM_small a) (phiM_small b) }.
Proof.
  Set Ltac Profiling.
  Time synthesize_add ().
  Show Ltac Profile.
Time Defined.

Print Assumptions add.
