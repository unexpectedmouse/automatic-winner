extends Control

@onready var kvas_address: LineEdit = %KvasAddress


func _ready() -> void:
	G.menu = self


func _on_connect_to_kvas_pressed() -> void:
	if kvas_address.text == "":
		kvas_address.text = "localhost"
	G.connect_to_kvas(kvas_address.text)


func _on_kvas_server_pressed() -> void:
	G.create_kvas_server()
