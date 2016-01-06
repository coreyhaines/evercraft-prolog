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


%% Calculating modifier
modifier(AttributeValue, Modifier) :-
  Modifier is div(AttributeValue - 10, 2).


attackCharacter(AttackerName, DefenderName, Roll) :-
  character(AttackerName, _, _, _),
  character(DefenderName, DefenderAlignment, DefenderAC, DefenderHP),
  abilities(DefenderName, _, DefenderDexterity, _, _, _, _),
  modifier(DefenderDexterity, ACModifier),
  attack(Roll, (DefenderAC+ACModifier), AttackResult),
  damage(AttackResult, Roll, Damage),
  newHitPoints(DefenderHP, Damage, NHP), !,
  asserta(character(DefenderName, DefenderAlignment, DefenderAC, NHP)).

  %% Trying to figure out how to update the character
:- dynamic character/4.
:- dynamic abilities/7.

%% asserta(abilities('corey', 5, 12, 6, 10, 4, 3)),
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% modifier(Constitution, Modifier),
%% NewHP is 5 + Modifier,
%% asserta(character('corey', good, 10, NewHP)),
%% character('corey', A, AC, HP), !.

%% asserta(abilities('nate', 6, 6, 16, 20, 6, 9)),
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% modifier(Constitution, Modifier),
%% NewHP is 5 + Modifier,
%% asserta(character('nate', good, 10, NewHP)),
%% character('nate', A, AC, HP), !.
%%
%% attackCharacter('corey', 'nate', 10).
%%
%% character('corey', A, AC, HP), !.
%% character('nate', A, AC, HP), !.
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !.
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !.
