extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	$Bots/LongArtilleryBot2.set_controller($Bots/ArtilleryController2)
	$Bots/FastArtilleryBot.set_controller($Bots/ArtilleryController3)
