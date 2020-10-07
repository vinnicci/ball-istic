extends Node


#base class bots
const CLASS_BOT = preload("res://scenes/bots/_base/_BaseBot.gd")
const CLASS_PLAYER = preload("res://scenes/bots/player/Player.gd")
const CLASS_BOT_PROJ = preload("res://scenes/weapons/_base/_BaseBotProjectile.gd")

#core mods later
const CLASS_ITEM = preload("res://scenes/global/items/_base/_BaseItem.gd")
const CLASS_WEAPON = preload("res://scenes/weapons/_base/_BaseWeapon.gd")
const CLASS_PASSIVE = preload("res://scenes/passives/_base/_BasePassive.gd")
const CLASS_PROJ = preload("res://scenes/weapons/_base/_BaseProjectile.gd")

#level objects include: tilemap walls, static body walls
const CLASS_LEVEL_OBJECT = preload("res://scenes/level/_base/_BaseLevelObject.gd")
#rigid body objects
const CLASS_RIGID_OBJECT = preload("res://scenes/level/_base/_BaseRigidObject.gd")

const PLAYER_BUILT_IN_WEAP: = preload("res://scenes/weapons/blaster/BuiltInAutoBlaster.gd")
const BOT_STATION: = preload("res://scenes/level/bot station/BotStation.gd")
const DEPOT: = preload("res://scenes/level/depot/Depot.gd")
const VAULT: = preload("res://scenes/level/vault/Vault.gd")
const NEXT_ZONE: = preload("res://scenes/level/next zone/NextZone.gd")
const KEY: = preload("res://scenes/level/key/Key.gd")

const CLASS_SAVE: = preload("res://scenes/global/save files/SaveFile.gd")

const PROJ_BHVR_SPLIT: = preload("res://scenes/weapons/_projectile behaviors/split/Split.gd")
const PROJ_BHVR_REFLECT: = preload("res://scenes/weapons/_projectile behaviors/reflect/Reflect.gd")
