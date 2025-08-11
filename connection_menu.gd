extends Control
signal server
signal connect(ip: String, port: int)

@onready var kvas_address: LineEdit = $KvasPanel/KvasAddress
@onready var kvas_port: LineEdit = $KvasPanel/KvasPort


func _on_connect_to_kvas_pressed() -> void:
	if kvas_address.text.is_valid_ip_address():
		connect.emit(kvas_address.text, int(kvas_port.text))


func _on_kvas_server_pressed() -> void:
	server.emit()
