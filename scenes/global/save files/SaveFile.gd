extends Resource


export (String) var save_name: String
export (Dictionary) var player: Dictionary = {
	"Items": [],
	"Weapons": [],
	"Passives": [],
	"Spawn": null, #value -> Lvl: level name, Pos: access name
	"Keys": []
}
export (Dictionary) var despawnable_bots: Dictionary
export (Dictionary) var depot_items: Dictionary
export (Array) var vault_items: Array
export (Array) var paths: Array
