extends TextureRect

var hue = 0.0; # hue of the player
var sat = 0.7
var val = 0.8
var lastHue = -99
var gradient

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hue = GlobalProperties.TargetHue
	if hue != lastHue:
		gradient = Gradient.new()
		gradient.set_offset(1, 0.66)
		gradient.add_point(0.3, Color.from_hsv(hue, sat, val))
		self.material.get_shader_param("colorCurve").gradient = gradient
		lastHue = hue
	pass
