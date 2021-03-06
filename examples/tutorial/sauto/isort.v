(******************************************************************)
(* Insertion sort *)

From Hammer Require Import Tactics.
(* CoqHammer tactics v1.3 or later *)
(* Installation:
     opam repo add coq-released https://coq.inria.fr/opam/released
     opam install coq-hammer-tactics *)
(* Alternatively, download the latest release form
   https://github.com/lukaszcz/coqhammer, and after unpacking run
   `make tactics` and `make install-tactics` *)
(* Documentation is available at: https://github.com/lukaszcz/coqhammer. *)

Require List.
Import List.ListNotations.
Open Scope list_scope.

Require Import Arith.
Require Import Lia.

Inductive Sorted : list nat -> Prop :=
| Sorted_0 : Sorted []
| Sorted_1 : forall x, Sorted [x]
| Sorted_2 : forall x y l, Sorted (y :: l) -> x <= y ->
                           Sorted (x :: y :: l).

(* insert a number into a sorted list preserving the sortedness *)
Fixpoint insert (l : list nat) (x : nat) : list nat :=
  match l with
  | [] => [x]
  | h :: t => if x <=? h then x :: l else h :: insert t x
  end.

(* insertion sort *)
Fixpoint isort (l : list nat) : list nat :=
  match l with
  | [] => []
  | h :: t => insert (isort t) h
  end.

Lemma lem_insert_sorted_hlp :
  forall l y z, y <= z -> Sorted (y :: l) ->
    Sorted (y :: insert l z).
Proof.
  intro l.
  induction l as [|a l IH].
  - intros; simpl; auto using Sorted.
  - intros x y H1 H2.
    simpl.
    destruct (Nat.leb_spec y a) as [H|H].
    + repeat constructor; auto.
      inversion H2; auto.
    + inversion_clear H2.
      auto using Sorted with arith.
Qed.

Lemma lem_insert_sorted_hlp' :
  forall l y z, y <= z -> Sorted (y :: l) ->
    Sorted (y :: insert l z).
Proof.
  (* "sauto" will *never* try "induction" - one needs to first invoke
     "induction" manually *)
  time (induction l; sauto db: arith).
  (* "db: db1, .., dbn" instructs "sauto" to use the given hint or
     rewriting databases *)
  Undo.
  time (induction l; sauto db: arith inv: Sorted ctrs: Sorted).
  (* "inv: ind1, .., indn" instructs "sauto" to try inversion (case
     reasoning) only on elements of the given inductive types *)
  (* "ctrs: ind1, .., indn" instructs "sauto" to try using
     constructors of only the given inductive types *)
  (* "-" stands for an empty list,
     "*" for a list of all possible inductive types *)
  (* By default "sauto" tries inversion on elements of and uses
     constructors of all possible inductive types *)
  (* I.e. the defaults are: "inv: *" and "ctrs: *" *)
Qed.

Lemma lem_insert_sorted (l : list nat) (x : nat) :
  Sorted l -> Sorted (insert l x).
Proof.
  destruct l as [|y l].
  - simpl; auto using Sorted.
  - intro H.
    simpl.
    destruct (Nat.leb_spec x y);
      auto using Sorted, lem_insert_sorted_hlp with arith.
Qed.

Lemma lem_insert_sorted' (l : list nat) (x : nat) :
  Sorted l -> Sorted (insert l x).
Proof.
  (* sauto use: lem_insert_sorted_hlp db: arith. *)
  (* "use: lem1, .., lemn" adds the given lemmas to the context *)
  (* The default is "use: -" *)
  (* "sauto" above does not find a proof in reasonable time *)
  (* Sometimes it is enough to help "sauto" just by providing a few
     initial steps (particularly when the first step is "destruct" or
     "inversion") *)
  time (destruct l; sauto use: lem_insert_sorted_hlp db: arith).
  Undo.
  time (destruct l;
        sauto use: lem_insert_sorted_hlp inv: - ctrs: Sorted db: arith).
  (* Providing the "inv:" and "ctrs:" options with only the necessary
     inductive types often noticeably decreases the running time *)
  (* There is a shorthand for this common use case:
     "hauto" is "sauto inv: - ctrs: -" *)
Qed.

Lemma lem_isort_sorted : forall l, Sorted (isort l).
Proof.
  induction l; simpl; auto using Sorted, lem_insert_sorted.
Qed.

Lemma lem_isort_sorted' : forall l, Sorted (isort l).
Proof.
  induction l; sauto use: lem_insert_sorted.
Qed.

(* We have proven that the result of "isort" is a sorted list. Now we
   prove that the result is a permutation of the argument. *)

Require Import Sorting.Permutation.

Lemma lem_insert_perm :
  forall l x, Permutation (insert l x) (x :: l).
Proof.
  induction l as [|y ? ?].
  - eauto using Permutation.
  - intro x.
    simpl.
    destruct (Nat.leb_spec x y) as [H|H];
      eauto using Permutation.
Qed.

Lemma lem_insert_perm' :
  forall l x, Permutation (insert l x) (x :: l).
Proof.
  induction l; sauto.
Qed.

Lemma lem_isort_perm : forall l, Permutation (isort l) l.
Proof.
  induction l; simpl; eauto using Permutation, lem_insert_perm.
Qed.

Lemma lem_isort_perm' : forall l, Permutation (isort l) l.
Proof.
  induction l; sauto use: lem_insert_perm.
Qed.
