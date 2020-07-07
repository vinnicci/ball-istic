extends "res://scenes/level/tileset/TileMapBrown.gd"


func destroy() -> void:
	.destroy()
	_level.secret_path.show()
