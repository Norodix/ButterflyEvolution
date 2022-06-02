extends PathFollow2D

signal mate
var speed = 80
var initial_unit_offset = 0.0

func _ready():
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
