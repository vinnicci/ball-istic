extends "res://scenes/bots/Dummy.gd"


var points: Array
var next_point: Vector2
var found: bool
const RANGE_REQUIRED: int = 64
onready var target = get_parent().get_node("Player")


func get_new_points(end) -> void:
	var scene_root = get_parent().get_parent()
	points = scene_root.get_points(self, end)
	next_point = points.pop_front()


func _control(delta):
	$LineOfSight.look_at(target.global_position)
	velocity = Vector2(0,0)
	if $LineOfSight.get_collider() != target && found == false:
		return
	else:
		found = true
	if points.size() == 0:
		get_new_points(target)
	if (global_position - next_point).length() <= RANGE_REQUIRED:
		next_point = points.pop_front()
	$Body/WeaponHatch.look_at(next_point)
	velocity = velocity.move_toward(Vector2(1,0).rotated($Body/WeaponHatch.global_rotation), delta)


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target && $ChargeCooldown.is_stopped() == true:
		$LineOfSight.look_at(target.global_position)
		charge_attack($LineOfSight.global_rotation)


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body == target:
		$LineOfSight.enabled = true
		get_new_points(target)


func _on_DetectionRange_body_exited(body: Node) -> void:
	$LineOfSight.enabled = false
	found = false
	points = []
