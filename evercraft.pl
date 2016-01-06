%% We have alignments
alignment(good).
alignment(neutral).
alignment(evil).

defaultHP(5).
defaultAC(10).

%% Can attack
attack(Roll, AC, hit) :-
  Roll >= AC.
attack(Roll, AC, miss) :-
  Roll < AC.

%% Can get damage
damage(miss, _, _, 0).
damage(hit, Roll, Strength, Damage) :-
  Roll < 20,
  modifier(Strength, DamageModifier),
  ModifiedDamage is 1 + DamageModifier,
  boundAtOne(ModifiedDamage, Damage), !.
damage(hit, 20, Strength, Damage) :-
  modifier(Strength, DamageModifier),
  ModifiedDamage is 2 + 2*DamageModifier,
  boundAtOne(ModifiedDamage, Damage), !.

%% Can adjust hit points
newHitPoints(HP, Damage, 0) :-
  HP =< Damage, !.
newHitPoints(HP, Damage, NHP) :-
  HP > Damage,
  NHP is HP - Damage.


%% Calculating modifier
modifier(AttributeValue, Modifier) :-
  Modifier is div(AttributeValue - 10, 2).

%% Calculate Hit Point with Modifier
adjustedHitPoint(Constitution, HP, AdjustedHP) :-
  modifier(Constitution, Modifier),
  Modified is HP + Modifier,
  boundAtOne(Modified, AdjustedHP).

boundAtOne(Value, NewValue) :-
  Value < 1,
  NewValue is 1, !.
boundAtOne(Value, NewValue) :-
  Value >= 1,
  NewValue is Value.


relevantCharacterAbilities(Attacker, AttackerStrength, Defender, DefenderDexterity) :-
  abilities(Defender, _, DefenderDexterity, _, _, _, _),
  abilities(Attacker, AttackerStrength, _, _, _, _, _), !.

attackCharacter(AttackerName, DefenderName, Roll) :-
  character(DefenderName, DefenderAlignment, DefenderAC, DefenderHP),
  relevantCharacterAbilities(AttackerName, AttackerStrength, DefenderName, DefenderDexterity),
  modifier(DefenderDexterity, ACModifier),
  modifier(AttackerStrength, RollModifier),
  ModifiedRoll is Roll + RollModifier,
  ModifiedAC is DefenderAC + ACModifier,
  attack(ModifiedRoll, ModifiedAC, AttackResult),
  damage(AttackResult, Roll, AttackerStrength, Damage),
  format("~p~n", [Damage]),
  newHitPoints(DefenderHP, Damage, NHP), !,
  asserta(character(DefenderName, DefenderAlignment, DefenderAC, NHP)).

  %% Trying to figure out how to update the character
:- dynamic character/4.
:- dynamic abilities/7.


can(Roll) :-
  attackCharacter('corey', 'nate', Roll).

nac(Roll) :-
  attackCharacter('nate', 'corey', Roll).

%% defaultHP(DefaultHP),
%% defaultAC(DefaultAC),
%% asserta(abilities('corey', 5, 12, 6, 10, 4, 3)),
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% adjustedHitPoint(Constitution, DefaultHP, AdjustedHP),
%% asserta(character('corey', good, DefaultAC, AdjustedHP)),
%% character('corey', A, AC, HP), !.

%% defaultHP(DefaultHP),
%% defaultAC(DefaultAC),
%% asserta(abilities('nate', 6, 6, 16, 20, 6, 9)),
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% adjustedHitPoint(Constitution, DefaultHP, AdjustedHP),
%% asserta(character('nate', good, DefaultAC, AdjustedHP)),
%% character('nate', A, AC, HP), !.
%%
%% attackCharacter('corey', 'nate', 10).
%%
%% character('corey', A, AC, HP), !.
%% character('nate', A, AC, HP), !.
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !.
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !.
