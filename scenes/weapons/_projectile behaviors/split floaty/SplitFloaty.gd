extends "res://scenes/weapons/_projectile behaviors/_base/_BaseProjBehavior.gd"


func _ready() -> void:
	$SplitToThreeTimer.connect("timeout", self, "_on_SplitToThreeTimer_timeout")
