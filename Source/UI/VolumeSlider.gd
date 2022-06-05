extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slider = self


# Called when the node enters the scene tree for the first time.
func _ready():
	var busindex = AudioServer.get_bus_index("Master")
	slider.value = AudioServer.get_bus_volume_db(busindex)
	pass # Replace with function body.

func _on_VolumeSliderControl_value_changed(value):	
	var busindex = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(busindex, value)
	if slider.value == slider.min_value:
		AudioServer.set_bus_mute(busindex, true)
	else:
		AudioServer.set_bus_mute(busindex, false)
