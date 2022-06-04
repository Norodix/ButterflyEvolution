extends PathFollow2D

signal mate
var speed = 80
var initial_unit_offset = 0.0

var gradient : Gradient
var hue = 0.0; # hue of the butterfly
var sat = 0.7
var val = 0.8

func _ready():
	#Set color of the butterfly
	gradient = Gradient.new()
	gradient.set_offset(1, 0.66)
	gradient.add_point(0.3, Color.from_hsv(hue, sat, val))
	$RotationHandler/AnimatedSprite.material.get_shader_param("colorCurve").gradient = gradient
	
	$RotationHandler/AnimatedSprite.speed_scale = rand_range(7, 10)
	$RotationHandler/AnimatedSprite.frame = randi()%4

func _process(delta):
	self.offset += speed * delta
#	self.visible = $HideTimer.is_stopped()
#	$RotationHandler/ContactArea.monitorable = $HideTimer.is_stopped()
#	$RotationHandler/ContactArea.monitoring = $HideTimer.is_stopped()
	
	if not $RotationHandler/ContactArea.get_overlapping_areas().empty():
		#print("Mating")
#		$HideTimer.start()
		self.emit_signal("mate", self)
		pass
