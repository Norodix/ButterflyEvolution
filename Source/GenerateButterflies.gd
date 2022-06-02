extends Node2D

var butterflies = []
var butterflies_per_path = 3
onready var butterfly = preload("res://PathFollowButterfly.tscn")

func _ready():
	var children = get_children()
	for child in children:
		for i in range(butterflies_per_path):
			butterflies.append(butterfly.instance())
			butterflies[-1].unit_offset = 1.0 / butterflies_per_path
			child.add_child(butterflies[-1])
		
	pass # Replace with function body.

