extends KinematicBody2D

# Caterpillar motion script
var StepSize = 3 #determines the speed of the caterpillar, in normal motion: speed = stepsize * fps
var headHeight = 11
var pastSteps = PoolVector2Array([])
onready var segments = $Segments.get_children()
const segmentStepDelta = 5

class Step:
	var valid : bool = false
	var position : Vector2 = Vector2()

func _ready():
	for i in range(segmentStepDelta * segments.size()):
		pastSteps.append(self.global_position)
	pass # Replace with function body.

#func _process(delta):
#	pass

func _physics_process(delta):
	var dir = get_direction()
	#DDD.DrawLine(self.global_position, self.global_position + dir * 50, Color(1.0, 0, 0))
	if dir.length() != 0:
		var nextStep = get_next_step(dir)
		if nextStep.valid:
			#record the step in past steps
			pastSteps.append(self.global_position)
			#keep the past steps to necessary size
			while pastSteps.size() > segmentStepDelta * segments.size():
				pastSteps.remove(0)
			for i in segments.size():
				segments[i].global_position = pastSteps[-(i*5)]
			
			self.move_and_slide((nextStep.position - self.global_position) * 60)



func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var r = Input.is_action_pressed("ui_right")
	var l = Input.is_action_pressed("ui_left")
	var u = Input.is_action_pressed("ui_up")
	var d = Input.is_action_pressed("ui_down")
	dir.x = int(r) - int(l)
	dir.y = int(d) - int(u)
	return dir.normalized()


func get_next_step(dir : Vector2) -> Step:
	# starting from target direction in expanding, alternating angles:
	# find the next step where the head should move
	var step = Step.new()
	step.valid = false
	step.position = self.global_position
	
	if dir.length() == 0:
		return step
		
	var dir_a = dir.angle()
	var ss = get_world_2d().direct_space_state
	var start = self.global_position
	var end = start
	
	var angleArray = []
	for a in range(0, 180, 1):
		angleArray.append(- a)
		angleArray.append(a)
		
	var validSteps = []
	
	for degree in angleArray:
		var a = deg2rad(degree) + dir_a
		end = start +  Vector2(cos(a), sin(a)) * StepSize * 10
		#DDD.DrawLine(start, start + (end-start) * 50, Color(0, 1, 0))
		#DDD.DrawLine(start, end, Color(0, 1, 0))
		var ray = ss.intersect_ray(start, end)
		if not ray.empty():
			#get normal to the surface
			var newHeadPosition = ray.position + ray.normal * headHeight
			#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 0, 1))
			var stepDistance = (newHeadPosition - self.global_position).length()
			var stepDelta = abs(stepDistance - StepSize)
			if stepDelta < 1:
				#step is valid size, check direction
				if (newHeadPosition - self.global_position).normalized().dot(dir.normalized()) > 0.3:
					#step is in the general direction of dir
					validSteps.append(newHeadPosition)
					#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 1, 1), 3)
	
	if validSteps.size() == 0:
		return step
	
	#check and average the valid steps, if the average is valid still, do it
	var average = Vector2()
	for s in validSteps:
		average += s
	average /= validSteps.size()
	var stepDistance = (average - self.global_position).length()
	var stepDelta = abs(stepDistance - StepSize)
	if stepDelta < 2:
		#average step is valid
		step.position = average
		step.valid = true
		return step
	
	return step #return invalid step in case of problem
	pass
