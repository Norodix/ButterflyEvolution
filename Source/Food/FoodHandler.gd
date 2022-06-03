extends Node2D

onready var Food = preload("res://Food/Food.tscn")

func _ready():
	var ss = get_world_2d().direct_space_state
	for i in range($SpawnPoints.curve.get_point_count()):
		var f = Food.instance()
		var pos = $SpawnPoints.curve.get_point_position(i)
		
		#Find closest surface
		var minDist = 999999
		var minDistRay = null
		for deg in range(0, 360, 5):
			var from = pos
			var rad = deg2rad(deg)
			var to = from + Vector2(cos(rad), sin(rad)) * 60
			var ray = ss.intersect_ray(from, to, [], 1)
			if not ray.empty():
				var dist2 = (ray.position - pos).length_squared()
				if dist2 < minDist:
					minDistRay = ray
					minDist = dist2
		if minDistRay: # if we found a position in valid radius
			#DDD.DrawRay(minDistRay.position, minDistRay.normal * 60, Color(1, 0, 0), 20)
			$FoodPieces.add_child(f)
			f.global_position = minDistRay.position
			f.rotation = minDistRay.normal.angle() + deg2rad(90)
			#f.rotation = minDistRay.normal.angle()
			#$FoodPieces.rotation = deg2rad(60)
			pass
	pass # Replace with function body.

