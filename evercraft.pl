%% We have alignments
alignment(good).
alignment(neutral).
alignment(evil).

defaultHP(5).
defaultAC(10).
defaultXP(0).

experienceGainPerAttack(10).

%% Calculating Level
level(Experience, Level) :-
  Level is div(Experience,1000) + 1.

characterLevel(Name, Level) :-
  experience(Name, XP),
  level(XP, Level).

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

newExperience(Name, miss, NewXP) :-
  experience(Name, NewXP), !.
newExperience(Name, hit, NewXP) :-
  experience(Name, PreviousXP),
  experienceGainPerAttack(AdditionalXP),
  NewXP is PreviousXP + AdditionalXP, !.


relevantCharacterAttributes(AttackerName, AttackerStrength, DefenderName, DefenderDexterity, DefenderAC, DefenderHP) :-
  abilities(DefenderName, _, DefenderDexterity, _, _, _, _),
  character(DefenderName, _, DefenderAC),
  hitpoints(DefenderName, DefenderHP),
  abilities(AttackerName, AttackerStrength, _, _, _, _, _), !.

modifiedAttackNumbers(Roll, AttackerName, DefenderName, ModifiedAC, ModifiedRoll) :-
  relevantCharacterAttributes(AttackerName, AttackerStrength, DefenderName, DefenderDexterity, DefenderAC, _),
  modifier(DefenderDexterity, ACModifier),
  modifier(AttackerStrength, RollModifier),
  ModifiedRoll is Roll + RollModifier,
  ModifiedAC is DefenderAC + ACModifier.

attackCharacter(AttackerName, DefenderName, Roll) :-
  relevantCharacterAttributes(AttackerName, AttackerStrength, DefenderName, _, _, DefenderHP),
  modifiedAttackNumbers(Roll, AttackerName, DefenderName, ModifiedAC, ModifiedRoll),
  attack(ModifiedRoll, ModifiedAC, AttackResult),
  damage(AttackResult, Roll, AttackerStrength, Damage),
  format("~p Damage ~p~n", [AttackResult, Damage]),
  newHitPoints(DefenderHP, Damage, NHP),
  asserta(hitpoints(DefenderName, NHP)),
  newExperience(AttackerName, AttackResult, NewXP),
  asserta(experience(AttackerName, NewXP)),
  showCharacter(AttackerName),
  showCharacter(DefenderName), !.

  %% Trying to figure out how to update the character
:- dynamic character/3.
:- dynamic abilities/7.
:- dynamic hitpoints/2.
:- dynamic experience/2.

can(Roll) :-
  attackCharacter('corey', 'nate', Roll).

nac(Roll) :-
  attackCharacter('nate', 'corey', Roll).

showCharacter(Name) :-
  character(Name, A, AC),
  abilities(Name, Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma),
  hitpoints(Name, HP),
  characterLevel(Name, Level),
  experience(Name, XP), !,
  format("~p HP: ~p XP: ~p Level: ~p~n", [Name, HP, XP, Level]).


%% defaultHP(DefaultHP),
%% defaultAC(DefaultAC),
%% defaultXP(DefaultXP),
%% asserta(abilities('corey', 5, 12, 6, 10, 4, 3)),
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% adjustedHitPoint(Constitution, DefaultHP, AdjustedHP),
%% asserta(character('corey', good, DefaultAC)),
%% asserta(hitpoints('corey', AdjustedHP)),
%% asserta(experience('corey', DefaultXP)),
%% character('corey', A, AC), !.

%% defaultHP(DefaultHP),
%% defaultAC(DefaultAC),
%% defaultXP(DefaultXP),
%% asserta(abilities('nate', 6, 6, 16, 20, 6, 9)),
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% adjustedHitPoint(Constitution, DefaultHP, AdjustedHP),
%% asserta(character('nate', good, DefaultAC)),
%% asserta(hitpoints('nate', AdjustedHP)),
%% asserta(experience('nate', DefaultXP)),
%% character('nate', A, AC), !.
%%
%% attackCharacter('corey', 'nate', 10).
