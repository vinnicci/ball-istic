extends Node


#trail effect cleanup
func _on_Trail_anim_finished(anim_name: String, trail_obj: Node) -> void:
	trail_obj.queue_free()
