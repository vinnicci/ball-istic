extends "res://scenes/global/_base item/_BaseItem.gd"


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1 setget , get_heat_per_shot
export (float) var heat_capacity: float = 5 setget , get_heat_capacity
export (float) var heat_dissipation_per_sec: float = 1 setget , get_heat_dissipation
#heat must be below this threshold to return firing
export (float, 0, 1.0) var heat_below_threshold: float = 0 setget , get_heat_below_threshold
export (float) var shoot_cooldown: float = 1.0 setget , get_shoot_cooldown
enum FireModes {AUTO, BURST, CHARGE}
export (FireModes) var fire_mode setget , get_fire_mode
export (int) var proj_count_per_shot: int = 1 setget , get_proj_count_per_shot
export (float) var spread: float = 0 setget , get_spread #degrees
export (int) var recoil: int = 0 setget , get_recoil
#works only with burst firing mode
export (float) var burst_timer: float = 0.02 setget , get_burst_timer
#works only with charge firing mode
export (float) var charge_timer: float = 3.0 setget , get_charge_timer

var _current_heat: float setget , current_heat
var _is_overheating: bool = false setget , is_overheating
var _is_shooting: bool = false setget , is_shooting


func get_heat_per_shot():
	return heat_per_shot

func get_heat_capacity():
	return heat_capacity

func get_heat_dissipation():
	return heat_dissipation_per_sec

func get_heat_below_threshold():
	return heat_below_threshold

func get_shoot_cooldown():
	return shoot_cooldown

func get_fire_mode():
	return fire_mode

func get_proj_count_per_shot():
	return proj_count_per_shot

func get_spread():
	return spread

func get_recoil():
	return recoil

func get_burst_timer():
	return burst_timer

func get_charge_timer():
	return charge_timer

func current_heat():
	return _current_heat

func is_overheating():
	return _is_overheating

func is_shooting():
	return _is_shooting


onready var _timer_shoot_cooldown: Node = $Timers/ShootCooldown
onready var _timer_burst_timer: Node = $Timers/BurstTimer
onready var _timer_charge_timer: Node = $Timers/ChargeTimer
onready var _timer_charge_cancel_timer: Node = $Timers/ChargeCancelTimer
onready var _timer_dissipation_cooldown: Node = $Timers/DissipationCooldown


func _ready() -> void:
	_timer_shoot_cooldown.wait_time = shoot_cooldown
	_timer_burst_timer.wait_time = burst_timer
	_timer_charge_timer.wait_time = charge_timer
	#made sure no heat per shot
	#chargecanceltimer is 0.1, shootcooldown must twice as fast
	#to prevent charge timer timeout
	#thus letting go for atleast 0.1 sec means cancelling charge
	if fire_mode == 2:
		heat_per_shot = 0
		_timer_shoot_cooldown.wait_time = 0.05


func fire() -> void:
	if _timer_shoot_cooldown.is_stopped() == false || _is_overheating == true:
		return
	_timer_shoot_cooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	_current_heat += heat_per_shot
	match fire_mode:
		0: _fire_auto()
		1: _fire_burst()
		2: _fire_charged()


func _spawn_proj() -> void:
	Global.current_level.spawn_projectiles(Projectile.instance(), $Muzzle.global_position,
		$Muzzle.global_rotation + deg2rad(rand_range(-spread, spread)), _parent_node.is_hostile())


func _apply_recoil() -> void:
	_parent_node.apply_knockback(Vector2(recoil, 0).rotated(global_rotation - deg2rad(180)))


################################################################################
# auto fire
# fire one or more projectiles at once, shootcooldown node is the rate of fire
################################################################################
func _fire_auto() -> void:
	$ShootingSound.play()
	for i in proj_count_per_shot:
		_spawn_proj()
	_apply_recoil()


################################################################################
# burst fire
# fire rounds in bursts, shootcooldown node is the rate of fire, bursttimer node
# is the spawn delay for each projectile
################################################################################
var _current_burst_count: int = 0


func _fire_burst() -> void:
	$ShootingSound.play()
	_spawn_proj()
	_apply_recoil()
	_current_burst_count += 1
	_timer_burst_timer.start()


func _on_BurstTimer_timeout() -> void:
	if _current_burst_count == proj_count_per_shot || _parent_node.is_rolling() == true:
		_current_burst_count = 0
		return
	_fire_burst()


################################################################################
# charge fire
# shoot by charging and then releasing, shootcooldown node is the time to charge,
# chargecanceltimer node is the delay of letting go to cancel charge
################################################################################
func _fire_charged() -> void:
	if _is_overheating == true || _parent_node.is_transforming() == true:
		return
	if _parent_node.is_rolling() == true:
		_timer_charge_timer.stop()
		_cancel_charge()
		return
	if _current_heat == heat_capacity:
		_timer_charge_cancel_timer.stop()
		_charge_fire()
		_cancel_charge()
		_is_overheating = true
		return
	if _timer_charge_timer.is_stopped() == true && _current_heat == 0:
		$ChargingSound.play()
		_timer_charge_timer.start()
		_timer_dissipation_cooldown.paused = true
		$ChargingTween.interpolate_property(self, "_current_heat", _current_heat,
			heat_capacity, _timer_charge_timer.wait_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$ChargingTween.start()
	_timer_charge_cancel_timer.start()


#virtual
#by default shoots burst
func _charge_fire() -> void:
	if _parent_node.is_rolling() == true:
		return
	_fire_burst()


func _cancel_charge() -> void:
	_timer_charge_timer.stop()
	$ChargingTween.stop_all()
	_timer_dissipation_cooldown.paused = false


func _on_ChargeCancelTimer_timeout() -> void:
	_cancel_charge()
	_current_heat = 0


func animate_transform(transform_speed: float) -> void:
	if visible == true:
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0),
			transform_speed/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif visible == false:
		modulate = Color(1,1,1,0)
		show()
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
			transform_speed/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


func _on_WeaponTween_tween_all_completed() -> void:
	if visible == true && _parent_node.is_rolling() == true:
		hide()
		modulate = Color(1,1,1,1)


func _process(_delta: float) -> void:
	if _current_heat > heat_capacity && _is_overheating == false:
		_current_heat = heat_capacity + (heat_capacity*0.05)
		_is_overheating = true
	elif _is_overheating == true && _current_heat <= heat_capacity * heat_below_threshold:
		_is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if _current_heat > 0:
		_current_heat -= heat_dissipation_per_sec/4 #<- rate 1sec/4
	elif _current_heat <= 0:
		_current_heat = 0


func _on_ShootCooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false


func _on_ChargeTimer_timeout() -> void:
	pass # Replace with function body.
