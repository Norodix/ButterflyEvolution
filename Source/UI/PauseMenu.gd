extends Control

onready var ResumeButton = find_node("Resume")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().paused = not get_tree().paused
		ResumeButton.grab_focus()
		
	self.visible = get_tree().paused
	Engine.time_scale = float(int(not get_tree().paused))


func _on_Resume_pressed():
	get_tree().paused = false
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()
	pass # Replace with function body.
