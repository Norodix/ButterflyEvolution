extends PathFollow2D
tool

signal mate
var speed = 40

func _ready():
	$RotationHandler/AnimatedSprite.speed_scale = 8
	self.unit_offset = randf()

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
