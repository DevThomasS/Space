class_name MainMenu extends CanvasLayer

func _ready():
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/LevelOneButton.pressed.connect(_on_level_one_pressed)
	$VBoxContainer/LevelTwoButton.pressed.connect(_on_level_two_pressed)

func _on_settings_pressed():
	print("Settings not implemented yet")

func _on_level_one_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_one.tscn")

func _on_level_two_pressed():
	print("Level 2 not implemented yet")
