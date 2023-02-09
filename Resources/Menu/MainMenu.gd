extends Control

export(PackedScene) var target_scene

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	var next_scene = get_tree().change_scene_to(target_scene)

func _on_OptionsButton_pressed():
	pass # put options scene here

func _on_QuitButton_pressed():
	get_tree().quit()
