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

#vault items will be accessible everywhere
#place this later on levelmanager
var arr_vault: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
