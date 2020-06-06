extends Node


#trail effect cleanup
func _on_Trail_RemoveTimer_timeout(trail_obj: Node) -> void:
	trail_obj.queue_free()
