%% We have alignments
alignment(good).
alignment(neutral).
alignment(evil).

%% Can attack
attack(Roll, AC, hit) :-
  Roll >= AC.
attack(Roll, AC, miss) :-
  Roll < AC.

%% Can get damage
damage(miss, _, 0).
damage(hit, Roll, 1) :-
  Roll < 20, !.
damage(hit, 20, 2).

%% Can adjust hit points
newHitPoints(HP, Damage, 0) :-
  HP =< Damage, !.
newHitPoints(HP, Damage, NHP) :-
  HP > Damage,
  NHP is HP - Damage.

  %% Trying to figure out how to update the character
:- dynamic character/4.

%% asserta(character('corey', good, 10, 5)).
%%
%% Roll = 10, character('corey', Alignment, AC, HP), attack(Roll, AC, AttackResult), damage(AttackResult, Roll, Damage), newHitPoints(HP, Damage, NHP), !, asserta(character('corey', Alignment, AC, NHP)).
%%
%% character('corey', A, AC, HP), !.
