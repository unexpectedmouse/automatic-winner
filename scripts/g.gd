extends Node
signal clicked(object: Node3D)

var menu: Control
var world_scene := preload("res://scenes/world.tscn")
var player_scene := preload("res://scenes/player.tscn")
var peer := ENetMultiplayerPeer.new()
var world: Node3D

var players_alive = 0


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



var has_player = false
func update_players_alive():
	for player:CharacterBody3D in world.get_node('players').get_children():
		if player.is_in_group('player'):
			players_alive += 1	
	world.get_node('players_alive_label').text = 'В живых: '+str(players_alive)
	set_label.rpc()

#@rpc('any_peer', 'call_local')
func players_alive_minus_one():
	players_alive -= 1
	set_label.rpc()


@rpc('any_peer', 'call_local')
func set_label():
	world.get_node('players_alive_label').text = 'В живых: '+str(players_alive)
	if players_alive == 0:
		world.won.rpc(false)
	

func start_game():
	menu.queue_free()
	world = world_scene.instantiate()
	get_tree().root.add_child(world)


func new_kvas_player(id: int):
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	world.get_node("players").add_child(player)


func click(obj: Node3D):
	clicked.emit(obj)
