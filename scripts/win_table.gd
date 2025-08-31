extends Control


# Called when the node enters the scene tree for the first time.
func win(players:bool) -> void:
	if players:
		$Label.text = 'ПОБЕДИЛИ ИГРОКИ'
		$Label.add_theme_color_override("font_color", Color.CORAL)
		
	else:
		$Label.text = 'ПОБЕДИЛ ОХОТНИК'
		$Label.add_theme_color_override("font_color", Color.DARK_RED)
#
#@rpc("any_peer", 'call_local')
func delete_scene():
	queue_free()
