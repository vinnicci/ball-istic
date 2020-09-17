extends Area2D


func _access(body: Node, access_name: String, items: Node) -> void:
	$AccessUI/Label.visible = true
	$Sprite/Anim.stop()
	$Sprite.modulate.a = 1.0
	body.ui_inventory.accessing = access_name
	body.ui_inventory.access_button.text = "<" + access_name.to_upper() + ">"
	body.ui_inventory.access_button.disabled = false
	body.ui_inventory.items_external = items
	body.ui_inventory.get_node("Loadout").visible = false


func _exit_access(body: Node) -> void:
	$AccessUI/Label.visible = false
	$Sprite/Anim.play("fading")
	body.ui_inventory.accessing = ""
	body.ui_inventory.access_button.text = ""
	body.ui_inventory.access_button.disabled = true
	body.ui_inventory.items_external = null
	body.ui_inventory.get_node("Loadout").visible = true


func _on_Access_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Access_body_exited(body: Node) -> void:
	pass # Replace with function body.
