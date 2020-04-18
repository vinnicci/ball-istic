extends Node2D


onready var parent_node: = get_parent()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_console"):
#		parent_node.is_in_control = !parent_node.is_in_control
		$CanvasLayer/TextEdit.visible = !$CanvasLayer/TextEdit.visible
		$CanvasLayer/Label.visible = !$CanvasLayer/Label.visible
