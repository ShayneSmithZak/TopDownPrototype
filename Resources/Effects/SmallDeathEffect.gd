extends Sprite

onready var explodeSound = $ExplodeSound

func random_flip():
	var random_bool = randi() & 1
	set_flip_h(random_bool)

func play_explode():
	explodeSound.play()
