extends KinematicBody2D

# Caterpillar motion script
const StepSize = 3 #determines the speed of the caterpillar, in normal motion: speed = stepsize * fps
const headStepSize = 1
var headHeight = 11
var pastSteps = Array()
onready var segments = $Segments.get_children()
const segmentStepDelta = 4 #total distance between segments = segmentStepDelta * StepSize
var isHeadLifted : bool = false

class Step:
	var valid : bool = false
	var position : Vector2 = Vector2()
	var normal : Vector2 = Vector2(1, 0)

func _ready():
	var emptyStep = Step.new()
	emptyStep.position = self.global_position
	for i in range(segmentStepDelta * segments.size()):
		pastSteps.append(emptyStep)
	$Segments.set_as_toplevel(true)

	
#func _process(delta):
#	pass

func _physics_process(delta):
	var dir = get_direction()
	#DDD.DrawLine(self.global_position, self.global_position + dir * 50, Color(1.0, 0, 0))
	if Input.is_action_pressed("LiftHead"):
		isHeadLifted = true

	if isHeadLifted:
		#move head around
		#Use pastSteps's ith section position as anchor
		var i = 3
		var anchorPoint = pastSteps[-((i+1)*segmentStepDelta)].position
		var reach = (segmentStepDelta * (i+1) * StepSize)
		#move head toward direction
		self.global_position += dir * headStepSize
		#snap back to proper distance from anchor
		var head_from_anchor = self.global_position - anchorPoint
		if head_from_anchor.length() > reach:
			self.global_position = anchorPoint + head_from_anchor.normalized() * reach
				
		#### do FABRIK here to move the last i segments ####
		var stepIndexes = range(-((i+1)*segmentStepDelta) + 1, 0)
		#[-15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1]
		for ps in stepIndexes.size():
			pastSteps[stepIndexes[ps]].position = anchorPoint + head_from_anchor * ps / stepIndexes.size()
		####################################################
		
		if not Input.is_action_pressed("LiftHead"):
			if $Area2D.get_overlapping_bodies().empty():
				#try to snap to closest object when not overlapping with other one currently
				var ray = get_closest_ray(self.global_position, headHeight + headStepSize)
				if not ray.empty():
					isHeadLifted = false
				pass

	elif dir.length() != 0: #Head is not lifted, try normal crawling
		var nextStep = get_next_step(dir)
		if nextStep.valid:
			#Draw the normal
			DDD.DrawLine(self.global_position, nextStep.normal * 30 + self.global_position, Color(0, 1, 1))
			#record the step in past steps
			pastSteps.append(nextStep)
			#keep the past steps to necessary size
			while pastSteps.size() > segmentStepDelta * segments.size():
				pastSteps.remove(0)
			self.move_and_slide((nextStep.position - self.global_position) * 60)

	#Update the position of the segments
	for segment in segments:
		var i = segment.get_index()
		var segmentStep = pastSteps[-((i+1)*segmentStepDelta)]
		segment.global_position = segmentStep.position
		DDD.DrawLine(segment.global_position, segmentStep.normal * 30 + segment.global_position, Color(0, 1, 1))



func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var r = Input.is_action_pressed("ui_right")
	var l = Input.is_action_pressed("ui_left")
	var u = Input.is_action_pressed("ui_up")
	var d = Input.is_action_pressed("ui_down")
	dir.x = int(r) - int(l)
	dir.y = int(d) - int(u)
	return dir.normalized()

func get_closest_ray(from: Vector2, length: float) -> Dictionary:
	var ss = get_world_2d().direct_space_state
	var closestRay = Dictionary()
	var minDistance : float = length * 2
	for deg in range(360):
		var a = deg2rad(deg)
		var target = Vector2(cos(a), sin(a)) * length + from
		var ray = ss.intersect_ray(from, target)
		if not ray.empty():
			var distance = (ray.position - from).length()
			if distance < minDistance:
				closestRay = ray
				minDistance = distance
	return closestRay

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
	var normals = []
	
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
					normals.append(ray.normal) # collect the normals for later use
					#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 1, 1), 3)
	
	if validSteps.size() == 0:
		return step
	
	#check and average the valid steps, if the average is valid still, do it
	var average = Vector2()
	var averageNormal = Vector2()
	for i in validSteps.size():
		average += validSteps[i]
		averageNormal += normals[i]
	average /= validSteps.size()
	averageNormal /= validSteps.size()
	var stepDistance = (average - self.global_position).length()
	var stepDelta = abs(stepDistance - StepSize)
	if stepDelta < 2:
		#average step is valid
		step.position = average
		step.valid = true
		step.normal = averageNormal.normalized()
		return step
	
	return step #return invalid step in case of problem
	pass
