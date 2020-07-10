extends Area2D


func _access(body: Node, arr: Array, access_name: String, arr_count: int) -> void:
	$AccessUI/Label.visible = true
	$Sprite/Anim.stop()
	$Sprite.modulate.a = 1.0
	body.ui_access = access_name
	body.ui_loadout_access_button.text = "<" + access_name.to_upper() + ">"
	body.ui_loadout_access_button.disabled = false
	body.ui_loadout.visible = false
	body.arr_external = arr
	for i in range(arr_count):
		body.update_ui_slot(i, access_name)


func _exit_access(body: Node) -> void:
	$AccessUI/Label.visible = false
	$Sprite/Anim.play("fading")
	body.ui_access = ""
	body.ui_loadout_access_button.text = ""
	body.ui_loadout_access_button.disabled = true
	body.ui_loadout.visible = true
	body.arr_external = []


func _on_Access_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Access_body_exited(body: Node) -> void:
	pass # Replace with function body.
