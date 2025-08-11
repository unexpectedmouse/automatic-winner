extends SpotLight3D

var charge = 100
var speed = 10
var start_fading = false
@onready var timer = $Timer

func _process(delta: float) -> void:
	if start_fading:
		charge-=speed*delta
		light_energy = charge/100
	if charge <= 0.1:
		$"../../OmniLight3D".show()
	else:
		$"../../OmniLight3D".hide()
	

func _on_timer_timeout() -> void:
	start_fading = true
	
