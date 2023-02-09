extends KinematicBody2D

signal hp_changed(new_hp)
signal hp_max_changed(new_hp_max)
signal died

export(int) var hp_max: int = 100 setget set_hp_max
export(int) var hp: int = hp_max setget set_hp, get_hp
export(int) var defense: int = 0

export(bool) var recieves_knockback: bool = true
export(float) var knockback_modifier: float = 0.1

export(int) var SPEED: int = 75
var velocity: Vector2 = Vector2.ZERO

export(PackedScene) var EFFECT_HIT: PackedScene = null
export(PackedScene) var EFFECT_DIED: PackedScene = null
export(PackedScene) var BLOOD: PackedScene = null

onready var sprite = $Sprite
onready var collShape = $CollisionShape2D
onready var animPlayer = $AnimationPlayer
onready var hurtBox = $HurtBox
onready var hitSound = $HitSound
onready var screenShake = $Camera2D/ScreenShake

func _physics_process(delta):
	move()
	
func set_hp(value):
	if value != hp:
		hp = clamp(value, 0, hp_max)
		emit_signal("hp_changed", hp)
		if hp == 0:
			emit_signal("died")
	
func get_hp():
	return hp
	
func set_hp_max(value):
	if value != hp_max:
		hp_max = max(0, value)
		emit_signal("hp_max_changed", hp_max)
		self.hp = hp
	
func move():
	velocity = move_and_slide(velocity)
	
func die():
	var blood_instance = BLOOD.instance()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	blood_instance.rotation = global_position.angle_to_point(Global.player.global_position)
	
	if self.is_in_group("Player"):
		blood_instance.camera.make_current()
		blood_instance.screenShake.start(0.2, 20, 20, 1)
		blood_instance.rotation = global_position.angle_to_point(-self.global_position)
	else: 
		blood_instance.rotation = global_position.angle_to_point(Global.player.global_position)	
	
	spawn_effect(EFFECT_DIED)
	queue_free()

func recieve_damage(base_damage: int):
	var actual_damage = base_damage
	actual_damage -= defense
	screenShake.start(0.1, 15, 5)
	
	self.hp -= actual_damage
	return actual_damage

func recieve_knockback(damage_source_position: Vector2, recieved_damage: int):
	if recieves_knockback:
		var knockback_direction = damage_source_position.direction_to(self.global_position)
		var knockback_strength = recieved_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength
		global_position += knockback

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position

func _on_HurtBox_area_entered(hitbox):	
	var actual_damage = recieve_damage(hitbox.damage)
	
	if hitbox.is_in_group("Projectile"):
		hitbox.destroy()
	
	hitSound.play()
	spawn_effect(EFFECT_HIT)
	recieve_knockback(hitbox.global_position, actual_damage)

func _on_EntityBase_died():
	die()
