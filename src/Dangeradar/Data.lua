-- Stolen from Spy add-on by Immolation.
-- https://www.curseforge.com/wow/addons/spy

-- Class enum. Values as provided by the game API.
--
local DRUID = "DRUID";
local HUNTER = "HUNTER";
local MAGE = "MAGE";
local PALADIN = "PALADIN";
local PRIEST = "PRIEST";
local ROGUE = "ROGUE";
local SHAMAN = "SHAMAN";
local WARLOCK = "WARLOCK";
local WARRIOR = "WARRIOR";
local DEATHKNIGHT = "DEATHKNIGHT";

-- Race enum. Values as provided by the game API.
--
local DWARF = "Dwarf";
local GNOME = "Gnome";
local HUMAN = "Human";
local NIGHTELF = "NightElf";
local ORC = "Orc";
local SCOURGE = "Scourge";
local TAUREN = "Tauren";
local TROLL = "Troll";
local BLOODELF = "BloodElf";
local DRAENEI = "Draenei";

-- Static data.
--
-- Adapted from Spy add-on by Immolation.
-- https://www.curseforge.com/wow/addons/spy
--
local DATA = {
	races = {
		[DWARF] = {
			id = 3,
		},
		[GNOME] = {
			id = 7,
		},
		[HUMAN] = {
			id = 1,
		},
		[NIGHTELF] = {
			id = 4,
		},
		[ORC] = {
			id = 2,
		},
		[SCOURGE] = {
			id = 5,
		},
		[TAUREN] = {
			id = 6,
		},
		[TROLL] = {
			id = 8,
		},
		[BLOODELF] = {
			id = 10,
		},
		[DRAENEI] = {
			id = 11,
		},
	},
	classes = {
		[DRUID] = {
			id = 11,
			order = 5,
			textureCoords = CLASS_ICON_TCOORDS["DRUID"],
			spells = {
				["Abolish Poison"] = { reqLevel = 26 },
				["Aquatic Form"] = { reqLevel = 16 },
				["Barkskin"] = { reqLevel = 44 },
				["Bash"] = { reqLevel = 14 },
				["Bear Form"] = { reqLevel = 10 },
				["Cat Form"] = { reqLevel = 20 },
				["Challenging Roar"] = { reqLevel = 28 },
				["Claw"] = { reqLevel = 20 },
				["Cower"] = { reqLevel = 28 },
				["Cure Poison"] = { reqLevel = 14 },
				["Cyclone"] = { reqLevel = 70 },
				["Dash"] = { reqLevel = 26 },
				["Demoralizing Roar"] = { reqLevel = 10 },
				["Dire Bear Form"] = { reqLevel = 40 },
				["Enrage"] = { reqLevel = 12 },
				["Entangling Roots"] = { reqLevel = 8 },
				["Faerie Fire (Feral)"] = { reqLevel = 30 },
				["Faerie Fire"] = { reqLevel = 18 },
				["Feline Grace"] = { reqLevel = 40 },
				["Feral Charge"] = { reqLevel = 20 },
				["Ferocious Bite"] = { reqLevel = 32 },
				["Flight Form"] = { reqLevel = 68 },
				["Force of Nature"] = { reqLevel = 50 },
				["Frenzied Regeneration"] = { reqLevel = 36 },
				["Furor"] = { reqLevel = 10 },
				["Gift of the Wild"] = { reqLevel = 50 },
				["Growl"] = { reqLevel = 10 },
				["Healing Touch"] = { reqLevel = 1 },
				["Hibernate"] = { reqLevel = 18 },
				["Hurricane"] = { reqLevel = 40 },
				["Innervate"] = { reqLevel = 40 },
				["Insect Swarm"] = { reqLevel = 30 },
				["Lacerate"] = { reqLevel = 66 },
				["Leader of the Pack"] = { reqLevel = 40 },
				["Lifebloom"] = { reqLevel = 64 },
				["Maim"] = { reqLevel = 62 },
				["Mangle (Bear)"] = { reqLevel = 50 },
				["Mangle (Cat)"] = { reqLevel = 50 },
				["Mangle"] = { reqLevel = 50 },
				["Mark of the Wild"] = { reqLevel = 1 },
				["Maul"] = { reqLevel = 10 },
				["Moonfire"] = { reqLevel = 4 },
				["Moonkin Form"] = { reqLevel = 40 },
				["Nature's Grasp"] = { reqLevel = 10 },
				["Nature's Swiftness"] = { reqLevel = 35 },
				["Omen of Clarity"] = { reqLevel = 20 },
				["Pounce"] = { reqLevel = 36 },
				["Prowl"] = { reqLevel = 20 },
				["Rake"] = { reqLevel = 24 },
				["Ravage"] = { reqLevel = 32 },
				["Rebirth"] = { reqLevel = 20 },
				["Regrowth"] = { reqLevel = 12 },
				["Rejuvenation"] = { reqLevel = 4 },
				["Remove Curse"] = { reqLevel = 24 },
				["Rip"] = { reqLevel = 20 },
				["Shred"] = { reqLevel = 22 },
				["Soothe Animal"] = { reqLevel = 22 },
				["Starfire"] = { reqLevel = 20 },
				["Swift Flight Form"] = { reqLevel = 70 },
				["Swiftmend"] = { reqLevel = 40 },
				["Swipe"] = { reqLevel = 16 },
				["Teleport: Moonglade"] = { reqLevel = 10 },
				["Thorns"] = { reqLevel = 6 },
				["Tiger's Fury"] = { reqLevel = 24 },
				["Track Humanoids"] = { reqLevel = 32 },
				["Tranquility"] = { reqLevel = 30 },
				["Travel Form"] = { reqLevel = 30 },
				["Tree of Life"] = { reqLevel = 50 },
				["Wrath"] = { reqLevel = 1 },
			}
		},
		[HUNTER] = {
			id = 3,
			order = 4,
			textureCoords = CLASS_ICON_TCOORDS["HUNTER"],
			spells = {
				["Aimed Shot"] = { reqLevel = 20 },
				["Arcane Resistance"] = { reqLevel = 20 },
				["Arcane Shot"] = { reqLevel = 6 },
				["Aspect of the Beast"] = { reqLevel = 30 },
				["Aspect of the Cheetah"] = { reqLevel = 20 },
				["Aspect of the Hawk"] = { reqLevel = 10 },
				["Aspect of the Monkey"] = { reqLevel = 4 },
				["Aspect of the Pack"] = { reqLevel = 40 },
				["Aspect of the Viper"] = { reqLevel = 64 },
				["Aspect of the Wild"] = { reqLevel = 46 },
				["Auto Shot"] = { reqLevel = 1 },
				["Beast Lore"] = { reqLevel = 24 },
				["Bestial Wrath"] = { reqLevel = 40 },
				["Call Pet"] = { reqLevel = 10 },
				["Concussive Shot"] = { reqLevel = 8 },
				["Counterattack"] = { reqLevel = 30 },
				["Deterrence"] = { reqLevel = 20 },
				["Disengage"] = { reqLevel = 20 },
				["Dismiss Pet"] = { reqLevel = 10 },
				["Distracting Shot"] = { reqLevel = 12 },
				["Eagle Eye"] = { reqLevel = 14 },
				["Explosive Trap"] = { reqLevel = 34 },
				["Eyes of the Beast"] = { reqLevel = 14 },
				["Feed Pet Effect"] = { reqLevel = 10 },
				["Feed Pet"] = { reqLevel = 10 },
				["Feign Death"] = { reqLevel = 30 },
				["Fire Resistance"] = { reqLevel = 20 },
				["Flare"] = { reqLevel = 32 },
				["Freezing Trap"] = { reqLevel = 20 },
				["Frost Resistance"] = { reqLevel = 20 },
				["Frost Trap"] = { reqLevel = 28 },
				["Great Stamina"] = { reqLevel = 10 },
				["Growl"] = { reqLevel = 20 },
				["Hunter's Mark"] = { reqLevel = 6 },
				["Immolation Trap"] = { reqLevel = 16 },
				["Intimidation"] = { reqLevel = 30 },
				["Kill Command"] = { reqLevel = 66 },
				["Mend Pet"] = { reqLevel = 12 },
				["Misdirection"] = { reqLevel = 70 },
				["Mongoose Bite"] = { reqLevel = 16 },
				["Multi-Shot"] = { reqLevel = 18 },
				["Natural Armor"] = { reqLevel = 10 },
				["Nature Resistance"] = { reqLevel = 20 },
				["Rapid Fire"] = { reqLevel = 26 },
				["Raptor Strike"] = { reqLevel = 1 },
				["Readiness"] = { reqLevel = 50 },
				["Revive Pet"] = { reqLevel = 10 },
				["Scare Beast"] = { reqLevel = 14 },
				["Scatter Shot"] = { reqLevel = 30 },
				["Scorpid Sting"] = { reqLevel = 22 },
				["Serpent Sting"] = { reqLevel = 4 },
				["Shadow Resistance"] = { reqLevel = 20 },
				["Silencing Shot"] = { reqLevel = 50 },
				["Snake Trap"] = { reqLevel = 68 },
				["Steady Shot"] = { reqLevel = 62 },
				["Tame Beast"] = { reqLevel = 10 },
				["Throw"] = { reqLevel = 20 },
				["Track Beasts"] = { reqLevel = 1 },
				["Track Demons"] = { reqLevel = 32 },
				["Track Dragonkin"] = { reqLevel = 50 },
				["Track Elementals"] = { reqLevel = 26 },
				["Track Giants"] = { reqLevel = 40 },
				["Track Hidden"] = { reqLevel = 24 },
				["Track Humanoids"] = { reqLevel = 10 },
				["Track Undead"] = { reqLevel = 18 },
				["Tranquilizing Shot"] = { reqLevel = 60 },
				["Trueshot Aura"] = { reqLevel = 40 },
				["Viper Sting"] = { reqLevel = 36 },
				["Volley"] = { reqLevel = 40 },
				["Wing Clip"] = { reqLevel = 12 },
				["Wyvern Sting"] = { reqLevel = 40 },
			}
		},
		[MAGE] = {
			id = 8,
			order = 8,
			textureCoords = CLASS_ICON_TCOORDS["MAGE"],
			spells = {
				["Amplify Magic"] = { reqLevel = 18 },
				["Arcane Blast"] = { reqLevel = 64 },
				["Arcane Brilliance"] = { reqLevel = 56 },
				["Arcane Explosion"] = { reqLevel = 14 },
				["Arcane Intellect"] = { reqLevel = 1 },
				["Arcane Missiles"] = { reqLevel = 8 },
				["Arcane Power"] = { reqLevel = 40 },
				["Blast Wave"] = { reqLevel = 30 },
				["Blink"] = { reqLevel = 20 },
				["Blizzard"] = { reqLevel = 20 },
				["Cold Snap"] = { reqLevel = 20 },
				["Combustion"] = { reqLevel = 40 },
				["Cone of Cold"] = { reqLevel = 26 },
				["Conjure Food"] = { reqLevel = 6 },
				["Conjure Mana Agate"] = { reqLevel = 28 },
				["Conjure Mana Citrine"] = { reqLevel = 48 },
				["Conjure Mana Emerald"] = { reqLevel = 68 },
				["Conjure Mana Jade"] = { reqLevel = 38 },
				["Conjure Mana Ruby"] = { reqLevel = 58 },
				["Conjure Water"] = { reqLevel = 4 },
				["Counterspell"] = { reqLevel = 24 },
				["Dampen Magic"] = { reqLevel = 12 },
				["Detect Magic"] = { reqLevel = 16 },
				["Dragon's Breath"] = { reqLevel = 50 },
				["Evocation"] = { reqLevel = 20 },
				["Fire Blast"] = { reqLevel = 6 },
				["Fire Ward"] = { reqLevel = 20 },
				["Fireball"] = { reqLevel = 1 },
				["Flamestrike"] = { reqLevel = 16 },
				["Frost Armor"] = { reqLevel = 1 },
				["Frost Nova"] = { reqLevel = 10 },
				["Frost Ward"] = { reqLevel = 22 },
				["Frostbolt"] = { reqLevel = 4 },
				["Ice Armor"] = { reqLevel = 30 },
				["Ice Barrier"] = { reqLevel = 40 },
				["Ice Block"] = { reqLevel = 30 },
				["Ice Lance"] = { reqLevel = 66 },
				["Icy Veins"] = { reqLevel = 20 },
				["Invisibility"] = { reqLevel = 68 },
				["Mage Armor"] = { reqLevel = 34 },
				["Mana Shield"] = { reqLevel = 20 },
				["Molten Armor"] = { reqLevel = 62 },
				["Polymorph: Cow"] = { reqLevel = 60 },
				["Polymorph: Pig"] = { reqLevel = 60 },
				["Polymorph: Turtle"] = { reqLevel = 60 },
				["Polymorph"] = { reqLevel = 8 },
				["Portal: Darnassus"] = { reqLevel = 50 },
				["Portal: Exodar"] = { reqLevel = 40 },
				["Portal: Ironforge"] = { reqLevel = 40 },
				["Portal: Orgrimmar"] = { reqLevel = 40 },
				["Portal: Shattrath"] = { reqLevel = 65 },
				["Portal: Silvermoon"] = { reqLevel = 40 },
				["Portal: Stonard"] = { reqLevel = 35 },
				["Portal: Stormwind"] = { reqLevel = 40 },
				["Portal: Theramore"] = { reqLevel = 35 },
				["Portal: Thunder Bluff"] = { reqLevel = 50 },
				["Portal: Undercity"] = { reqLevel = 40 },
				["Presence of Mind"] = { reqLevel = 30 },
				["Pyroblast"] = { reqLevel = 20 },
				["Remove Lesser Curse"] = { reqLevel = 18 },
				["Ritual of Refreshment"] = { reqLevel = 70 },
				["Scorch"] = { reqLevel = 22 },
				["Slow Fall"] = { reqLevel = 12 },
				["Slow"] = { reqLevel = 50 },
				["Spellsteal"] = { reqLevel = 70 },
				["Summon Water Elemental"] = { reqLevel = 50 },
				["Teleport: Darnassus"] = { reqLevel = 30 },
				["Teleport: Exodar"] = { reqLevel = 20 },
				["Teleport: Ironforge"] = { reqLevel = 20 },
				["Teleport: Orgrimmar"] = { reqLevel = 20 },
				["Teleport: Shattrath"] = { reqLevel = 60 },
				["Teleport: Silvermoon"] = { reqLevel = 20 },
				["Teleport: Stonard"] = { reqLevel = 35 },
				["Teleport: Stormwind"] = { reqLevel = 20 },
				["Teleport: Theramore"] = { reqLevel = 35 },
				["Teleport: Thunder Bluff"] = { reqLevel = 30 },
				["Teleport: Undercity"] = { reqLevel = 20 },
			}
		},
		[PALADIN] = {
			id = 2,
			order = 2,
			textureCoords = CLASS_ICON_TCOORDS["PALADIN"],
			spells = {
				["Avenger's Shield"] = { reqLevel = 50 },
				["Avenging Wrath"] = { reqLevel = 70 },
				["Blessing of Freedom"] = { reqLevel = 18 },
				["Blessing of Kings"] = { reqLevel = 20 },
				["Blessing of Light"] = { reqLevel = 40 },
				["Blessing of Might"] = { reqLevel = 4 },
				["Blessing of Protection"] = { reqLevel = 10 },
				["Blessing of Sacrifice"] = { reqLevel = 46 },
				["Blessing of Salvation"] = { reqLevel = 26 },
				["Blessing of Sanctuary"] = { reqLevel = 30 },
				["Blessing of Wisdom"] = { reqLevel = 14 },
				["Blood Corruption"] = { reqLevel = 64 },
				["Cleanse"] = { reqLevel = 42 },
				["Concentration Aura"] = { reqLevel = 22 },
				["Consecration"] = { reqLevel = 20 },
				["Crusader Aura"] = { reqLevel = 62 },
				["Crusader Strike"] = { reqLevel = 50 },
				["Devotion Aura"] = { reqLevel = 1 },
				["Divine Favor"] = { reqLevel = 30 },
				["Divine Illumination"] = { reqLevel = 50 },
				["Divine Intervention"] = { reqLevel = 30 },
				["Divine Protection"] = { reqLevel = 6 },
				["Divine Shield"] = { reqLevel = 34 },
				["Exorcism"] = { reqLevel = 20 },
				["Fire Resistance Aura"] = { reqLevel = 36 },
				["Flash of Light"] = { reqLevel = 20 },
				["Frost Resistance Aura"] = { reqLevel = 32 },
				["Greater Blessing of Kings"] = { reqLevel = 60 },
				["Greater Blessing of Light"] = { reqLevel = 60 },
				["Greater Blessing of Might"] = { reqLevel = 52 },
				["Greater Blessing of Salvation"] = { reqLevel = 60 },
				["Greater Blessing of Sanctuary"] = { reqLevel = 60 },
				["Greater Blessing of Wisdom"] = { reqLevel = 54 },
				["Hammer of Justice"] = { reqLevel = 8 },
				["Hammer of Wrath"] = { reqLevel = 44 },
				["Holy Light"] = { reqLevel = 1 },
				["Holy Shield"] = { reqLevel = 40 },
				["Holy Shock"] = { reqLevel = 40 },
				["Holy Wrath"] = { reqLevel = 50 },
				["Judgement of Corruption"] = { reqLevel = 64 },
				["Judgement of the Crusader"] = { reqLevel = 6 },
				["Judgement"] = { reqLevel = 4 },
				["Lay on Hands"] = { reqLevel = 10 },
				["Purify"] = { reqLevel = 8 },
				["Redemption"] = { reqLevel = 12 },
				["Repentance"] = { reqLevel = 40 },
				["Retribution Aura"] = { reqLevel = 16 },
				["Righteous Defense"] = { reqLevel = 14 },
				["Righteous Fury"] = { reqLevel = 16 },
				["Sanctity Aura"] = { reqLevel = 30 },
				["Seal of Blood"] = { reqLevel = 64 },
				["Seal of Command"] = { reqLevel = 20 },
				["Seal of Corruption"] = { reqLevel = 70 },
				["Seal of Justice"] = { reqLevel = 22 },
				["Seal of Light"] = { reqLevel = 30 },
				["Seal of Righteousness"] = { reqLevel = 1 },
				["Seal of the Crusader"] = { reqLevel = 6 },
				["Seal of the Martyr"] = { reqLevel = 70 },
				["Seal of Vengeance"] = { reqLevel = 64 },
				["Seal of Wisdom"] = { reqLevel = 38 },
				["Sense Undead"] = { reqLevel = 20 },
				["Shadow Resistance Aura"] = { reqLevel = 28 },
				["Spiritual Attunement"] = { reqLevel = 18 },
				["Summon Charger"] = { reqLevel = 60 },
				["Summon Warhorse"] = { reqLevel = 30 },
				["Turn Evil"] = { reqLevel = 52 },
				["Turn Undead"] = { reqLevel = 24 },
			}
		},
		[PRIEST] = {
			id = 5,
			order = 7,
			textureCoords = CLASS_ICON_TCOORDS["PRIEST"],
			spells = {
				["Abolish Disease"] = { reqLevel = 32 },
				["Binding Heal"] = { reqLevel = 64 },
				["Chastise"] = { reqLevel = 20 },
				["Circle of Healing"] = { reqLevel = 50 },
				["Consume Magic"] = { reqLevel = 20 },
				["Cure Disease"] = { reqLevel = 14 },
				["Desperate Prayer"] = { reqLevel = 10 },
				["Devouring Plague"] = { reqLevel = 20 },
				["Dispel Magic"] = { reqLevel = 18 },
				["Divine Spirit"] = { reqLevel = 30 },
				["Elune's Grace"] = { reqLevel = 20 },
				["Fade"] = { reqLevel = 8 },
				["Fear Ward"] = { reqLevel = 20 },
				["Feedback"] = { reqLevel = 20 },
				["Flash Heal"] = { reqLevel = 20 },
				["Greater Heal"] = { reqLevel = 40 },
				["Heal"] = { reqLevel = 16 },
				["Hex of Weakness"] = { reqLevel = 10 },
				["Holy Fire"] = { reqLevel = 20 },
				["Holy Nova"] = { reqLevel = 20 },
				["Inner Fire"] = { reqLevel = 12 },
				["Inner Focus"] = { reqLevel = 20 },
				["Lesser Heal"] = { reqLevel = 1 },
				["Levitate"] = { reqLevel = 34 },
				["Lightwell"] = { reqLevel = 40 },
				["Mana Burn"] = { reqLevel = 24 },
				["Mass Dispel"] = { reqLevel = 70 },
				["Mind Blast"] = { reqLevel = 10 },
				["Mind Control"] = { reqLevel = 30 },
				["Mind Flay"] = { reqLevel = 20 },
				["Mind Soothe"] = { reqLevel = 20 },
				["Mind Vision"] = { reqLevel = 22 },
				["Pain Suppression"] = { reqLevel = 50 },
				["Power Infusion"] = { reqLevel = 40 },
				["Power Word: Fortitude"] = { reqLevel = 1 },
				["Power Word: Shield"] = { reqLevel = 6 },
				["Prayer of Fortitude"] = { reqLevel = 48 },
				["Prayer of Healing"] = { reqLevel = 30 },
				["Prayer of Mending"] = { reqLevel = 68 },
				["Prayer of Shadow Protection"] = { reqLevel = 56 },
				["Prayer of Spirit"] = { reqLevel = 60 },
				["Psychic Scream"] = { reqLevel = 14 },
				["Renew"] = { reqLevel = 8 },
				["Resurrection"] = { reqLevel = 10 },
				["Shackle Undead"] = { reqLevel = 20 },
				["Shadow Protection"] = { reqLevel = 30 },
				["Shadow Word: Death"] = { reqLevel = 62 },
				["Shadow Word: Pain"] = { reqLevel = 4 },
				["Shadowfiend"] = { reqLevel = 66 },
				["Shadowform"] = { reqLevel = 40 },
				["Shadowguard"] = { reqLevel = 20 },
				["Silence"] = { reqLevel = 30 },
				["Smite"] = { reqLevel = 1 },
				["Starshards"] = { reqLevel = 10 },
				["Symbol of Hope"] = { reqLevel = 10 },
				["Touch of Weakness"] = { reqLevel = 10 },
				["Vampiric Embrace"] = { reqLevel = 30 },
				["Vampiric Touch"] = { reqLevel = 50 },
			}
		},
		[ROGUE] = {
			id = 4,
			order = 3,
			textureCoords = CLASS_ICON_TCOORDS["ROGUE"],
			spells = {
				["Adrenaline Rush"] = { reqLevel = 40 },
				["Ambush"] = { reqLevel = 18 },
				["Anesthetic Poison"] = { reqLevel = 68 },
				["Backstab"] = { reqLevel = 4 },
				["Blade Flurry"] = { reqLevel = 30 },
				["Blind"] = { reqLevel = 34 },
				["Blinding Powder"] = { reqLevel = 34 },
				["Cheap Shot"] = { reqLevel = 26 },
				["Cloak of Shadows"] = { reqLevel = 66 },
				["Cold Blood"] = { reqLevel = 30 },
				["Crippling Poison"] = { reqLevel = 20 },
				["Deadly Poison"] = { reqLevel = 30 },
				["Deadly Throw"] = { reqLevel = 64 },
				["Detect Traps"] = { reqLevel = 24 },
				["Disarm Trap"] = { reqLevel = 30 },
				["Distract"] = { reqLevel = 22 },
				["Envenom"] = { reqLevel = 62 },
				["Evasion"] = { reqLevel = 8 },
				["Eviscerate"] = { reqLevel = 1 },
				["Expose Armor"] = { reqLevel = 14 },
				["Feint"] = { reqLevel = 16 },
				["Find Weakness"] = { reqLevel = 45 },
				["Garrote"] = { reqLevel = 14 },
				["Ghostly Strike"] = { reqLevel = 20 },
				["Gouge"] = { reqLevel = 6 },
				["Hemorrhage"] = { reqLevel = 30 },
				["Instant Poison II"] = { reqLevel = 28 },
				["Instant Poison III"] = { reqLevel = 36 },
				["Instant Poison IV"] = { reqLevel = 44 },
				["Instant Poison V"] = { reqLevel = 52 },
				["Instant Poison VI"] = { reqLevel = 60 },
				["Instant Poison"] = { reqLevel = 20 },
				["Kick"] = { reqLevel = 12 },
				["Kidney Shot"] = { reqLevel = 30 },
				["Mind-numbing Poison"] = { reqLevel = 24 },
				["Mutilate"] = { reqLevel = 50 },
				["Pick Lock"] = { reqLevel = 1 },
				["Pick Pocket"] = { reqLevel = 4 },
				["Poisons"] = { reqLevel = 20 },
				["Premeditation"] = { reqLevel = 40 },
				["Preparation"] = { reqLevel = 30 },
				["Relentless Strike Effect"] = { reqLevel = 20 },
				["Riposte"] = { reqLevel = 20 },
				["Rupture"] = { reqLevel = 20 },
				["Safe Fall"] = { reqLevel = 40 },
				["Sap"] = { reqLevel = 10 },
				["Shadowstep"] = { reqLevel = 50 },
				["Shiv"] = { reqLevel = 70 },
				["Sinister Strike"] = { reqLevel = 1 },
				["Slice and Dice"] = { reqLevel = 10 },
				["Sprint"] = { reqLevel = 10 },
				["Stealth"] = { reqLevel = 1 },
				["Vanish"] = { reqLevel = 22 },
				["Wound Poison"] = { reqLevel = 32 },
			}
		},
		[SHAMAN] = {
			id = 7,
			order = 6,
			textureCoords = CLASS_ICON_TCOORDS["SHAMAN"],
			spells = {
				["Ancestral Spirit"] = { reqLevel = 12 },
				["Astral Recall"] = { reqLevel = 30 },
				["Bloodlust"] = { reqLevel = 70 },
				["Chain Heal"] = { reqLevel = 40 },
				["Chain Lightning"] = { reqLevel = 32 },
				["Cure Disease"] = { reqLevel = 22 },
				["Cure Poison"] = { reqLevel = 16 },
				["Disease Cleansing Totem"] = { reqLevel = 38 },
				["Earth Elemental Totem"] = { reqLevel = 66 },
				["Earth Shield"] = { reqLevel = 50 },
				["Earth Shock"] = { reqLevel = 4 },
				["Earthbind Totem"] = { reqLevel = 6 },
				["Elemental Mastery"] = { reqLevel = 40 },
				["Far Sight"] = { reqLevel = 26 },
				["Fire Elemental Totem"] = { reqLevel = 68 },
				["Fire Nova Totem"] = { reqLevel = 12 },
				["Fire Resistance Totem"] = { reqLevel = 28 },
				["Flame Shock"] = { reqLevel = 10 },
				["Flametongue Totem"] = { reqLevel = 28 },
				["Flametongue Weapon"] = { reqLevel = 10 },
				["Flurry"] = { reqLevel = 30 },
				["Frost Resistance Totem"] = { reqLevel = 24 },
				["Frost Shock"] = { reqLevel = 20 },
				["Frostbrand Weapon"] = { reqLevel = 20 },
				["Ghost Wolf"] = { reqLevel = 20 },
				["Grace of Air Totem"] = { reqLevel = 42 },
				["Grounding Totem"] = { reqLevel = 30 },
				["Healing Stream Totem"] = { reqLevel = 20 },
				["Healing Wave"] = { reqLevel = 1 },
				["Heroism"] = { reqLevel = 70 },
				["Lesser Healing Wave"] = { reqLevel = 20 },
				["Lightning Bolt"] = { reqLevel = 1 },
				["Lightning Shield"] = { reqLevel = 8 },
				["Magma Totem"] = { reqLevel = 26 },
				["Mana Spring Totem"] = { reqLevel = 26 },
				["Mana Tide Totem"] = { reqLevel = 40 },
				["Nature Resistance Totem"] = { reqLevel = 30 },
				["Nature's Swiftness"] = { reqLevel = 30 },
				["Parry"] = { reqLevel = 30 },
				["Poison Cleansing Totem"] = { reqLevel = 22 },
				["Purge"] = { reqLevel = 12 },
				["Reincarnation"] = { reqLevel = 30 },
				["Rockbiter Weapon"] = { reqLevel = 1 },
				["Searing Totem"] = { reqLevel = 10 },
				["Sentry Totem"] = { reqLevel = 34 },
				["Shamanistic Rage"] = { reqLevel = 50 },
				["Spirit Weapons"] = { reqLevel = 30 },
				["Stoneclaw Totem"] = { reqLevel = 8 },
				["Stoneskin Totem"] = { reqLevel = 4 },
				["Stormstrike"] = { reqLevel = 40 },
				["Strength of Earth Totem"] = { reqLevel = 10 },
				["Totem of Wrath"] = { reqLevel = 50 },
				["Totemic Call"] = { reqLevel = 30 },
				["Tranquil Air Totem"] = { reqLevel = 50 },
				["Tremor Totem"] = { reqLevel = 18 },
				["Water Breathing"] = { reqLevel = 22 },
				["Water Shield"] = { reqLevel = 62 },
				["Water Walking"] = { reqLevel = 28 },
				["Windfury Totem"] = { reqLevel = 32 },
				["Windfury Weapon"] = { reqLevel = 30 },
				["Windwall Totem"] = { reqLevel = 36 },
				["Wrath of Air Totem"] = { reqLevel = 64 },
			}
		},
		[WARLOCK] = {
			id = 9,
			order = 9,
			textureCoords = CLASS_ICON_TCOORDS["WARLOCK"],
			spells = {
				["Amplify Curse"] = { reqLevel = 20 },
				["Banish"] = { reqLevel = 28 },
				["Conflagrate"] = { reqLevel = 40 },
				["Corruption"] = { reqLevel = 4 },
				["Create Firestone (Greater)"] = { reqLevel = 46 },
				["Create Firestone (Lesser)"] = { reqLevel = 28 },
				["Create Firestone (Major)"] = { reqLevel = 56 },
				["Create Firestone"] = { reqLevel = 28 },
				["Create Healthstone (Greater)"] = { reqLevel = 46 },
				["Create Healthstone (Lesser)"] = { reqLevel = 22 },
				["Create Healthstone (Major)"] = { reqLevel = 58 },
				["Create Healthstone (Minor)"] = { reqLevel = 10 },
				["Create Healthstone"] = { reqLevel = 10 },
				["Create Soulstone (Greater)"] = { reqLevel = 50 },
				["Create Soulstone (Lesser)"] = { reqLevel = 30 },
				["Create Soulstone (Major)"] = { reqLevel = 60 },
				["Create Soulstone (Minor)"] = { reqLevel = 18 },
				["Create Soulstone"] = { reqLevel = 18 },
				["Create Spellstone (Greater)"] = { reqLevel = 48 },
				["Create Spellstone (Major)"] = { reqLevel = 60 },
				["Create Spellstone"] = { reqLevel = 36 },
				["Curse of Agony"] = { reqLevel = 8 },
				["Curse of Doom"] = { reqLevel = 60 },
				["Curse of Exhaustion"] = { reqLevel = 30 },
				["Curse of Recklessness"] = { reqLevel = 14 },
				["Curse of Shadow"] = { reqLevel = 44 },
				["Curse of the Elements"] = { reqLevel = 32 },
				["Curse of Tongues"] = { reqLevel = 26 },
				["Curse of Weakness"] = { reqLevel = 4 },
				["Dark Pact"] = { reqLevel = 40 },
				["Death Coil"] = { reqLevel = 42 },
				["Demon Armor"] = { reqLevel = 20 },
				["Demon Skin"] = { reqLevel = 1 },
				["Demonic Sacrifice"] = { reqLevel = 30 },
				["Detect Greater Invisibility"] = { reqLevel = 50 },
				["Detect Invisibility"] = { reqLevel = 26 },
				["Detect Lesser Invisibility"] = { reqLevel = 26 },
				["Drain Life"] = { reqLevel = 14 },
				["Drain Mana"] = { reqLevel = 24 },
				["Drain Soul"] = { reqLevel = 10 },
				["Enslave Demon"] = { reqLevel = 30 },
				["Eye of Kilrogg"] = { reqLevel = 22 },
				["Fear"] = { reqLevel = 8 },
				["Fel Armor"] = { reqLevel = 62 },
				["Fel Domination"] = { reqLevel = 20 },
				["Health Funnel"] = { reqLevel = 12 },
				["Hellfire"] = { reqLevel = 30 },
				["Howl of Terror"] = { reqLevel = 40 },
				["Immolate"] = { reqLevel = 1 },
				["Incinerate"] = { reqLevel = 64 },
				["Inferno"] = { reqLevel = 50 },
				["Life Tap"] = { reqLevel = 6 },
				["Rain of Fire"] = { reqLevel = 20 },
				["Ritual of Doom"] = { reqLevel = 60 },
				["Ritual of Souls"] = { reqLevel = 68 },
				["Ritual of Summoning"] = { reqLevel = 20 },
				["Searing Pain"] = { reqLevel = 18 },
				["Seed of Corruption"] = { reqLevel = 70 },
				["Sense Demons"] = { reqLevel = 24 },
				["Shadow Bolt"] = { reqLevel = 1 },
				["Shadow Ward"] = { reqLevel = 32 },
				["Shadowburn"] = { reqLevel = 20 },
				["Shadowfury"] = { reqLevel = 50 },
				["Siphon Life"] = { reqLevel = 30 },
				["Soul Fire"] = { reqLevel = 48 },
				["Soul Link"] = { reqLevel = 40 },
				["Soulshatter"] = { reqLevel = 66 },
				["Summon Dreadsteed"] = { reqLevel = 60 },
				["Summon Felguard"] = { reqLevel = 50 },
				["Summon Felhunter"] = { reqLevel = 30 },
				["Summon Felsteed"] = { reqLevel = 30 },
				["Felsteed"] = { reqLevel = 30 }, -- If the player logs in already mounted the spell is different.
				["Summon Imp"] = { reqLevel = 1 },
				["Summon Succubus"] = { reqLevel = 20 },
				["Summon Voidwalker"] = { reqLevel = 10 },
				["Unending Breath"] = { reqLevel = 16 },
				["Unstable Affliction"] = { reqLevel = 50 },
			}
		},
		[WARRIOR] = {
			id = 1,
			order = 1,
			textureCoords = CLASS_ICON_TCOORDS["WARRIOR"],
			spells = {
				["Battle Shout"] = { reqLevel = 1 },
				["Battle Stance"] = { reqLevel = 1 },
				["Berserker Rage"] = { reqLevel = 32 },
				["Berserker Stance"] = { reqLevel = 30 },
				["Bloodrage"] = { reqLevel = 10 },
				["Bloodthirst"] = { reqLevel = 40 },
				["Challenging Shout"] = { reqLevel = 26 },
				["Charge"] = { reqLevel = 4 },
				["Cleave"] = { reqLevel = 20 },
				["Commanding Shout"] = { reqLevel = 68 },
				["Concussion Blow"] = { reqLevel = 30 },
				["Death Wish"] = { reqLevel = 30 },
				["Defensive Stance"] = { reqLevel = 10 },
				["Demoralizing Shout"] = { reqLevel = 14 },
				["Devastate"] = { reqLevel = 50 },
				["Disarm"] = { reqLevel = 18 },
				["Execute"] = { reqLevel = 24 },
				["Flurry"] = { reqLevel = 40 },
				["Hamstring"] = { reqLevel = 8 },
				["Heroic Strike"] = { reqLevel = 1 },
				["Improved Pummel"] = { reqLevel = 1 },
				["Intercept"] = { reqLevel = 30 },
				["Intervene"] = { reqLevel = 70 },
				["Intimidating Shout"] = { reqLevel = 22 },
				["Last Stand"] = { reqLevel = 20 },
				["Mocking Blow"] = { reqLevel = 16 },
				["Mortal Strike"] = { reqLevel = 40 },
				["Overpower"] = { reqLevel = 12 },
				["Piercing Howl"] = { reqLevel = 20 },
				["Pummel"] = { reqLevel = 38 },
				["Rampage"] = { reqLevel = 50 },
				["Recklessness"] = { reqLevel = 50 },
				["Rend"] = { reqLevel = 4 },
				["Retaliation"] = { reqLevel = 20 },
				["Revenge"] = { reqLevel = 14 },
				["Shield Bash"] = { reqLevel = 12 },
				["Shield Block"] = { reqLevel = 16 },
				["Shield Slam"] = { reqLevel = 40 },
				["Shield Wall"] = { reqLevel = 28 },
				["Slam"] = { reqLevel = 30 },
				["Spell Reflection"] = { reqLevel = 64 },
				["Stance Mastery"] = { reqLevel = 20 },
				["Sunder Armor"] = { reqLevel = 10 },
				["Sweeping Strikes"] = { reqLevel = 30 },
				["Taunt"] = { reqLevel = 10 },
				["Thunder Clap"] = { reqLevel = 6 },
				["Victory Rush"] = { reqLevel = 62 },
				["Whirlwind"] = { reqLevel = 36 },
			}
		},
		[DEATHKNIGHT] = {
			id = 6,
			order = 6,
			textureCoords = CLASS_ICON_TCOORDS["DEATHKNIGHT"],
			spells = {}
		}
	}
};

-- ..
--
do
	for _, info in pairs(DATA.classes) do
		info.localizedName = C_CreatureInfo.GetClassInfo(info.id).className;
	end
	for _, info in pairs(DATA.races) do
		info.localizedName = C_CreatureInfo.GetRaceInfo(info.id).raceName;
	end
end

--
--
--

DangeradarData = {};

function DangeradarData:GetClassTexCoords(class)
	return DATA.classes[class].textureCoords;
end

function DangeradarData:GetRaceID(race)
	return DATA.races[race].id;
end

function DangeradarData:GetClassID(class)
	return DATA.classes[class].id;
end

function DangeradarData:GetClassOrder(class)
	return DATA.classes[class].order;
end

function DangeradarData:GetLocalizedRaceName(race)
	return DATA.races[race].localizedName;
end

function DangeradarData:GetLocalizedClassName(class)
	return DATA.classes[class].localizedName;
end

function DangeradarData:GetSpellReqLevel(class, spell)
	local data = DATA.classes[class].spells[spell];
	if (data) then
		return data.reqLevel;
	end
	return 0;
end
