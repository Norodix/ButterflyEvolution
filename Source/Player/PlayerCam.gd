extends Camera2D

onready var zoomTimer = Timer.new()
var targetZoom = 0.8
var maxZoom = 0.5
var minZoom = 1.2
var zoomLerp = 0.01
var zoomStep = 0.05

func _ready():
	zoomTimer.one_shot = true
	zoomTimer.wait_time = 0.2
	add_child(zoomTimer)
	pass # Replace with function body.

func _process(delta):
	if zoomTimer.is_stopped():
		if Input.is_action_pressed("zoom_in"):
			zoomTimer.start()
			targetZoom -= zoomStep
			pass
		if Input.is_action_pressed("zoom_out"):
			zoomTimer.start()
			targetZoom += zoomStep
			pass
		targetZoom = clamp(targetZoom, maxZoom, minZoom)
	var z = lerp(self.zoom.x, targetZoom, zoomLerp)
	self.zoom = Vector2(z, z)
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				targetZoom -= zoomStep
			if event.button_index == BUTTON_WHEEL_DOWN:
				targetZoom += zoomStep
