extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/VBoxContainer/fog.button_pressed = Settings.fog
	$Panel/VBoxContainer/bloom.button_pressed = Settings.bloom


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/connection_menu.tscn")


func _on_fog_toggled(toggled_on: bool) -> void:
	Settings.fog = toggled_on


func _on_bloom_toggled(toggled_on: bool) -> void:
	Settings.bloom = toggled_on
