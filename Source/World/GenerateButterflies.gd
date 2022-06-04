extends Node2D

var butterflies = []
var butterflies_per_path : float = 3.0
onready var butterfly = preload("res://Butterfly_AI/PathFollowButterfly.tscn")

func _ready():
	var children = get_children()
	for child in children:
		for i in range(butterflies_per_path):
			var bf = butterfly.instance()
			butterflies.append(bf)
			bf.hue = randf()
			child.add_child(bf)
			bf.unit_offset = i / butterflies_per_path
		
	pass # Replace with function body.

