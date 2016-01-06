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
  Roll < 20.
damage(hit, 20, 2).

%% Can adjust hit points
newHitPoints(HP, Damage, 0) :-
  HP =< Damage.
newHitPoints(HP, Damage, NHP) :-
  HP > Damage,
  NHP is HP - Damage.

%% Can create a character with an alignment
character('corey', good).
