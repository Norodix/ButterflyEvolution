extends Node2D

var butterflies = []
var butterflies_per_path : float = 3.0
onready var butterfly = preload("res://Butterfly_AI/PathFollowButterfly.tscn")

func _ready():
	randomize()
	var children = get_children()
	#Create a shuffled hue array
	var colorNum = children.size() * butterflies_per_path
	var colors = []
	for i in range(colorNum):
		colors.append(float(i) / float(colorNum))
	colors.shuffle()
	
	for child in children:
		for i in range(butterflies_per_path):
			var bf = butterfly.instance()
			butterflies.append(bf)
			bf.hue = colors.pop_back()
			child.add_child(bf)
			bf.unit_offset = i / butterflies_per_path
		
	pass # Replace with function body.

