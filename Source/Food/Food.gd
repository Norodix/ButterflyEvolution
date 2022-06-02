extends Area2D
tool

export(int, 1, 10) var maxSize = 3
export(int, 1, 10) var size = 1
signal finished

func _ready():
	pass # Replace with function body.

func _process(delta):
	var s = float(size)/float(maxSize)
	$Visual.scale = Vector2(s, s)

func bite():
	#called when player takes a bite out of this object
	if $RegrowTimer.is_stopped():
		$RegrowTimer.start()
	self.size -= 1
	if self.size == 0:
		emit_signal("finished", self)
	pass


func _on_RegrowTimer_timeout():
	if self.size < self.maxSize:
		self.size += 1
