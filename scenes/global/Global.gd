extends Node


const CLASS_BOT = preload("res://scenes/bots/_base/_BaseBot.gd")
const CLASS_PLAYER = preload("res://scenes/bots/player/Player.gd")

#core mods later
const CLASS_ITEM = preload("res://scenes/global/_base item/_BaseItem.gd")
const CLASS_WEAPON = preload("res://scenes/weapons/_base/_BaseWeapon.gd")
const CLASS_PASSIVE = preload("res://scenes/passives/_base/_BasePassive.gd")

#level objects include: tilemap walls, staticbody walls, or rigidbody objects
const CLASS_LEVEL_OBJECT = preload("res://scenes/levels/_base/_BaseLevelObject.gd")

onready var player: Node = null
