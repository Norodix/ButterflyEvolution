extends Node2D
tool

var flipHysteresis = 0.1

func _ready():
	self.set_as_toplevel(true)

func _process(delta):
	self.visible = get_parent().visible
	self.global_position = get_parent().global_position
	#Get parent rotation to determine facing, but do not rotate with it (toplevel)
	if not Engine.editor_hint:
		if cos(get_parent().rotation) > flipHysteresis:
			self.scale.x = 1.0
		if cos(get_parent().rotation) < - flipHysteresis:
			self.scale.x = - 1.0
