extends Node2D


const CLASS_PLAYER = preload("res://scenes/bots/player/Player.gd")


func _ready() -> void:
	$Sprite/Anim.play("fading")
