extends Node

var menu: Control
var world_scene := preload("res://scenes/world.tscn")
var player_scene := preload("res://scenes/player.tscn")
var peer := ENetMultiplayerPeer.new()
var world: Node3D

var players_position = {
	
}




func create_kvas_server():
	peer.create_server(12345)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(new_kvas_player)
	
	start_game()
	new_kvas_player(multiplayer.get_unique_id())


func connect_to_kvas(kvas_address: String):
	peer.create_client(kvas_address, 12345)
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	menu.queue_free()
	world = world_scene.instantiate()
	get_tree().root.add_child(world)


func new_kvas_player(id: int):
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	world.get_node("players").add_child(player)
