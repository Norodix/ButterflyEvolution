extends Control


var FullnessLabel : Label
var FullnessBar : ProgressBar
var Mate : TextureRect
var MateColor : ColorRect

func _ready():
	FullnessLabel = find_node("FullnessLabel")
	FullnessBar = find_node("FullnessBar")
	Mate = find_node("Mate")
	MateColor = find_node("MateColor")

func _process(delta):
	#Hide irrelevant data
	var hasEaten : bool = GlobalProperties.PlayerFullness != 0
	FullnessBar.visible = hasEaten
	FullnessLabel.visible = hasEaten
	
	var hasMate : bool = GlobalProperties.PlayerMate != null
	Mate.visible = hasMate
	MateColor.visible = hasMate
	

	FullnessLabel.text = String(GlobalProperties.PlayerFullness) + " / " \
	+ String(GlobalProperties.PlayerMaxFullness)
	FullnessBar.value = float(GlobalProperties.PlayerFullness) \
							/ float(GlobalProperties.PlayerMaxFullness)
	
