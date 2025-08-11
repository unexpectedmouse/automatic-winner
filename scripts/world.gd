extends Node3D


var player = preload("res://scenes/player.tscn")

@onready var players_node: Node3D = $players
@onready var positions: Node3D = $positions

func add_player():
	#adding player to scene
	pass

func set_player_role():
	var hunter_id = randi_range(0, players_node.get_child_count())
	for player:CharacterBody3D in players_node.get_children():
		if players_node.get_child(hunter_id) == player:
			player.add_to_group('hunter')
		else:
			player.add_to_group('player')
	
func set_player_to_pos():
	var id_was = []
	for player:CharacterBody3D in players_node.get_children():
		if player.is_in_group('player'):
			var id = randomize_ids()
			if !id_was.has(id):
				player.global_position = positions.get_child(id).global_position
				positions.get_child(id).queue_free()
				id_was.append(id)
				

func randomize_ids():
	var id = randi_range(0,positions.get_child_count())
	return id

	
