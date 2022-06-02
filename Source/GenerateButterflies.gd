extends Node2D

var butterflies = []
onready var butterfly = preload("res://PathFollowButterfly.tscn")

func _ready():
	var children = get_children()
	for child in children:
		butterflies.append(butterfly.instance())
		child.add_child(butterflies[-1])
	pass # Replace with function body.

