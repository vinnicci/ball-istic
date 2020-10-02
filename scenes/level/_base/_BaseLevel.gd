extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
export var disp_name: String
var _player: Global.CLASS_PLAYER = null setget , get_player
var _player_faction: Color
signal secret_found


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot is Global.CLASS_PLAYER:
			_player = bot
			_player_faction = _player.current_faction
		bot.set_level(self)
		bot.connect("dead", self, "_on_bot_dead", [bot])
		if bot.has_node("AI") == true:
			bot.get_node("AI").connect("engaged", self, "_on_bot_engaged", [bot])
	for access in $Access.get_children():
		if access is Global.DEPOT || access is Global.VAULT:
			access.set_level(self)
	open_doors()


var _doors_open: bool


func open_doors() -> void:
	for door in $Doors.get_children():
		door.open()
	_doors_open = true


func close_doors() -> void:
	for door in $Doors.get_children():
		door.close()
	_doors_open = false


func spawn_projectile(proj_inst, proj_pos: Vector2, proj_dir: float) -> void:
	if proj_inst is Global.CLASS_BOT_PROJ == true:
		proj_inst.connect("dead", self, "_on_bot_dead", [proj_inst])
		if proj_inst.has_node("AI") == true:
			proj_inst.get_node("AI").connect("engaged", self,
				"_on_bot_engaged", [proj_inst])
		$Bots.add_child(proj_inst)
	else:
		add_child(proj_inst)
	proj_inst.init_travel(proj_pos, proj_dir)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


func _on_bot_engaged(bot) -> void:
	var ai_node = bot.get_node("AI")
	if ai_node.get_enemy().current_faction == _player_faction:
		close_doors()


func _on_bot_dead(bot) -> void:
	if bot == _player:
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
		return
	for lvlbot in $Bots.get_children():
		if (lvlbot == bot || lvlbot.current_faction == _player_faction ||
			lvlbot.state == Global.CLASS_BOT.State.DEAD ||
			lvlbot.has_node("AI") == false):
			continue
		var ai = lvlbot.get_node("AI")
		if (ai.get_enemy() != null &&
			ai.get_enemy().current_faction == _player_faction):
			return
	open_doors()


#anim effect cleanup -> critical, deflected, stunned, charge and teleport trail
func _on_Anim_finished(anim_name: String, anim_obj: Node) -> void:
	anim_obj.queue_free()
