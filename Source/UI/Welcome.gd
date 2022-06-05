extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ready : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	var e = event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton
	if e:
		if event.pressed:
			if not ready:
				$Tutorial.visible = true
				ready = true
			else:
				get_tree().change_scene("res://World/World.tscn")
