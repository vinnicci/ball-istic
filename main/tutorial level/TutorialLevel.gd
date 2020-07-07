extends "res://scenes/level/_base/_BaseLevel.gd"


onready var bots_A: Array = [$Bots/DummyA, $Bots/DummyA2, $Bots/DummyA3]
onready var bots_B: Array = [$Bots/DummyB, $Bots/DummyB2, $Bots/DummyB3]
onready var bot_C: = $Bots/DummyC
onready var bot_D: = $Bots/DummyD
onready var door_A: = $Nav/DoorA
onready var door_B: = $Nav/DoorB
onready var door_C: = $Nav/DoorC
onready var door_D: = $Nav/DoorD


func _ready() -> void:
	for hint in $Access.get_children():
		hint.set_level(self)
