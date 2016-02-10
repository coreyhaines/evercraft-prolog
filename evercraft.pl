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

sum(List, Sum) :-
  sumRec(List, 0, Sum).
sumRec([], Value, Value).
sumRec([H|T], Value, Accum) :-
  sumRec(T, Value, OldAccum),
  Accum is OldAccum + H.

%% Add up all the damages that have been done
damageSoFar(Name, Damage) :-
  findall(DamagePoint, damageIncurred(Name, DamagePoint), Damages),
  sum(Damages, Damage).

%% Current hitpoints is starting hit points minus damage done so far, bounded at one
currentHitPoints(Name, CurrentHP) :-
  abilities(Name, _, _, Constitution, _, _, _),
  defaultHP(BaseHP),
  adjustedHitPoint(Constitution, BaseHP, CharacterHP),
  damageSoFar(Name, Damage),
  RawHP is CharacterHP - Damage,
  boundAtOne(RawHP, CurrentHP).


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
  currentHitPoints(DefenderName, DefenderHP),
  abilities(AttackerName, AttackerStrength, _, _, _, _, _), !.

modifiedAttackNumbers(Roll, AttackerName, DefenderName, ModifiedAC, ModifiedRoll) :-
  relevantCharacterAttributes(AttackerName, AttackerStrength, DefenderName, DefenderDexterity, DefenderAC, _),
  modifier(DefenderDexterity, ACModifier),
  modifier(AttackerStrength, RollModifier),
  ModifiedRoll is Roll + RollModifier,
  ModifiedAC is DefenderAC + ACModifier.

registerDamage(_, miss, _) :-
  format("Missed~n").
registerDamage(Name, hit, Damage) :-
  format("Hit. ~p incurred ~p damage~n", [Name, Damage]),
  asserta(damageIncurred(Name, Damage)).

attackCharacter(AttackerName, DefenderName, Roll) :-
  relevantCharacterAttributes(AttackerName, AttackerStrength, DefenderName, _, _, _),
  modifiedAttackNumbers(Roll, AttackerName, DefenderName, ModifiedAC, ModifiedRoll),
  attack(ModifiedRoll, ModifiedAC, AttackResult),
  damage(AttackResult, Roll, AttackerStrength, Damage),
  registerDamage(DefenderName, AttackResult, Damage),
  newExperience(AttackerName, AttackResult, NewXP),
  asserta(experience(AttackerName, NewXP)),
  showCharacter(AttackerName),
  showCharacter(DefenderName), !.

  %% Trying to figure out how to update the character
:- dynamic character/3.
:- dynamic abilities/7.
:- dynamic experience/2.
:- dynamic damageIncurred/2.

can(Roll) :-
  attackCharacter('corey', 'nate', Roll).

nac(Roll) :-
  attackCharacter('nate', 'corey', Roll).

showCharacter(Name) :-
  character(Name, _A, _AC),
  abilities(Name, _Strength, _Dexterity, _Constitution, _Wisdom, _Intelligence, _Charisma),
  currentHitPoints(Name, HP),
  characterLevel(Name, Level),
  experience(Name, XP), !,
  format("~p HP: ~p XP: ~p Level: ~p~n", [Name, HP, XP, Level]).


%% defaultAC(DefaultAC),
%% defaultXP(DefaultXP),
%% asserta(abilities('corey', 5, 12, 6, 10, 4, 3)),
%% abilities('corey', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% asserta(character('corey', good, DefaultAC)),
%% asserta(experience('corey', DefaultXP)),
%% character('corey', A, AC), !.

%% defaultAC(DefaultAC),
%% defaultXP(DefaultXP),
%% asserta(abilities('nate', 6, 6, 16, 20, 6, 9)),
%% abilities('nate', Strength, Dexterity, Constitution, Wisdom, Intelligence, Charisma), !,
%% asserta(character('nate', good, DefaultAC)),
%% asserta(experience('nate', DefaultXP)),
%% character('nate', A, AC), !.
%%
%% attackCharacter('corey', 'nate', 10).
