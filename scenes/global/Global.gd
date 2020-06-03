extends Node


#base class bots and sub class bots
const CLASS_BOT = preload("res://scenes/bots/_base/_BaseBot.gd")
const CLASS_PLAYER = preload("res://scenes/bots/player/Player.gd")
const CLASS_BOT_PROJ = preload("res://scenes/weapons/_base/_BaseBotProjectile.gd")

#core mods later
#base class item and sub class items
const CLASS_ITEM = preload("res://scenes/global/items/_base/_BaseItem.gd")
const CLASS_WEAPON = preload("res://scenes/weapons/_base/_BaseWeapon.gd")
const CLASS_PASSIVE = preload("res://scenes/passives/_base/_BasePassive.gd")

#level objects include: tilemap walls, static body walls, or rigid body objects
const CLASS_LEVEL_OBJECT = preload("res://scenes/level/_base/_BaseLevelObject.gd")

#vault items will be accessible everywhere
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

var player: Node = null
var current_level: Node = null
