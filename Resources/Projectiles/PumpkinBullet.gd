extends "res://Resources/Overlap/HitBox.gd"

export(int) var SPEED: int = 200
export(bool) var has_kickback: bool = true
export(int) var kickback_modifier: int = 1
export(float) var attack_timeout: float = 0.1

onready var sprite = $Sprite
onready var shootSound = $ShootSound

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += SPEED * direction * delta

func destroy():
	queue_free()

func _on_PumpkinBullet_area_entered(area):
	destroy()

func _on_PumpkinBullet_body_entered(body):
	destroy()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
