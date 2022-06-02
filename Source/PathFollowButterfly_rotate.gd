extends Node2D
tool

onready var parent = get_parent()
var flipHysteresis = 0.1

func _ready():
	self.set_as_toplevel(true)

func _process(delta):
	self.visible = parent.visible
	self.global_position = parent.global_position
	#Get parent rotation to determine facing, but do not rotate with it (toplevel)
	if cos(parent.rotation) > flipHysteresis:
		$AnimatedSprite.flip_h = false
	if cos(parent.rotation) < - flipHysteresis:
		$AnimatedSprite.flip_h = true
