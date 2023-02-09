extends "res://Resources/Entity/EntityBase.gd"

onready var animTree = $AnimationTree
onready var attackTimer = $AttackTimer
onready var animState = animTree.get("parameters/playback")

export(PackedScene) var PROJECTILE: PackedScene = null
export(int) var ACCELERATION: int = 500
export(int) var FRICTION: int = 500
export(int) var ATTACK_SLOWDOWN: int = 20

enum {
	MOVE,
	DASH
}

var state = MOVE

func _ready():
	Global.player = self
	
func _exit_tree():
	Global.player = null

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		DASH:
			dash_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if Input.is_action_pressed("action_attack") and attackTimer.is_stopped():
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION - ATTACK_SLOWDOWN * delta)
		if PROJECTILE:
			var projectile_direction = self.global_position.direction_to(get_global_mouse_position())
			throw_projectile(projectile_direction)

	if input_vector != Vector2.ZERO:
		animTree.set("parameters/Idle/blend_position", input_vector)
		animTree.set("parameters/Walk/blend_position", input_vector)
		animState.travel("Walk")
		if Input.is_action_pressed("action_attack"):
			velocity = velocity.move_toward(input_vector * (SPEED - ATTACK_SLOWDOWN), ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	else:
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("ui_accept"):
		state = DASH

func dash_state(delta):
	print("dash")
	state = MOVE

func throw_projectile(projectile_direction: Vector2):
	var projectile = PROJECTILE.instance()
	
	get_tree().current_scene.add_child(projectile)
	screenShake.start(0.05, 7, 5)
	projectile.shootSound.play()
	projectile.global_position = self.global_position
	
	projectile.sprite.rotation = -projectile_direction.angle()
	projectile.rotation = projectile_direction.angle()
	
	attackTimer.set_wait_time(projectile.attack_timeout)
	attackTimer.start()
	
	if projectile.has_kickback:
		var kickback = -projectile_direction * projectile.kickback_modifier
		self.global_position += kickback
