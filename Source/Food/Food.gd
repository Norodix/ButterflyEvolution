extends Area2D

export(int, 1, 10) var maxSize = 3
export(int, 1, 10) var size = 1

signal finished
var foodValue = 1

func _ready():
	pass # Replace with function body.

func _process(delta):
	var s = float(size)/float(maxSize)
	$Visual.scale = Vector2(s, s)
	if size <= 0:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
		
func bite():
	#called when player takes a bite out of this object
	self.size -= 1
	if self.size == 0:
		emit_signal("finished", self)
		$RegrowTimer.start()
	return foodValue


func _on_RegrowTimer_timeout():
#	if self.size < self.maxSize:
#		self.size += 1
#	else:
#		$RegrowTimer.stop()
	$RegrowTimer.stop()
	self.size = self.maxSize
