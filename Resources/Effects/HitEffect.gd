extends Sprite

func random_rotate():
	var array = [0, 90, 180, 270]
	randomize()
	array.shuffle()
	var rand_value = array[randi() % array.size()]
	rotation_degrees = rand_value
