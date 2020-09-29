extends "res://scenes/level/tileset/brown/TileMapBrown.gd"


func destroy() -> void:
	.destroy()
	_level_node.secret_path.show()
