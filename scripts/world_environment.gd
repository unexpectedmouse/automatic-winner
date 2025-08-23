extends WorldEnvironment


func _ready() -> void:
	environment.glow_enabled = Settings.bloom
	environment.fog_enabled = Settings.fog
	environment.volumetric_fog_enabled = Settings.fog
	
