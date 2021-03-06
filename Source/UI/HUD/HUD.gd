extends Control


var FullnessLabel : Label
var FullnessBar : ProgressBar
var Mate : TextureRect
var HueCircle : ColorRect
var PlayerIndicator : Sprite
var MateIndicator : Sprite
var indicatorRadius
var TargetIndicator

func _ready():
	FullnessLabel = find_node("FullnessLabel")
	FullnessBar = find_node("FullnessBar")
	Mate = find_node("Mate")
	HueCircle = find_node("HueCircle")
	PlayerIndicator = find_node("PlayerIndicator")
	MateIndicator = find_node("MateIndicator")
	TargetIndicator = find_node("TargetSegment")
	
	indicatorRadius = HueCircle.rect_size.x / 2.0

func _process(delta):
	$ScoreLabel.text = String(GlobalProperties.PlayerScore)
	
	#Hide irrelevant data
	var hasEaten : bool = GlobalProperties.PlayerFullness != 0
	FullnessBar.visible = hasEaten
	FullnessLabel.visible = hasEaten
	
	#Move the indicators
	var hasMate : bool = GlobalProperties.PlayerMate != null
	MateIndicator.visible = hasMate
	if (hasMate):
		setIndicator(MateIndicator, GlobalProperties.PlayerMate.hue)
	setIndicator(PlayerIndicator, GlobalProperties.PlayerHue)
	setIndicator(TargetIndicator, GlobalProperties.TargetHue, -8)
	
	#Mate.visible = hasMate
	#HueCircle.visible = hasMate
	

	FullnessLabel.text = String(GlobalProperties.PlayerFullness) + " / " \
	+ String(GlobalProperties.PlayerMaxFullness)
	FullnessBar.value = float(GlobalProperties.PlayerFullness) \
							/ float(GlobalProperties.PlayerMaxFullness)
	

func setIndicator(Indicator, hue, offset = 0.0):
	var a = hue * 2 * PI - PI/2.0
	Indicator.position = Vector2(cos(a), sin(a)) * (indicatorRadius + offset) \
								 + Vector2(indicatorRadius, indicatorRadius)
	Indicator.rotation = a + PI/2
