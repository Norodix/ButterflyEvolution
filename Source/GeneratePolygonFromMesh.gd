extends CollisionPolygon2D
tool

###############################################################################
# Use this script in the collisionshape to populate the array for the polygon #
# In blender the edgeloop can be reduced by limited dissolve                  #
# Then a bevel modifier should be used to make corners smooth engouh          #
# Then the mesh can be reduced again to save space                            #
###############################################################################

export(Resource) var sourceMesh
export (bool) var ReInit = false

# Initialize collision polygon based on sourceMesh
func _ready():
	var vertices = PoolVector2Array()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(sourceMesh, 0)
	var polygonArrayAsString = ""
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertices.append(Vector2(vertex.x, vertex.y))
	
	print(vertices.size())
	self.polygon = vertices
	pass # Replace with function body.


func _process(delta):
	if ReInit:
		ReInit = false
		print("Reinitialize collision mesh")
		_ready()
	pass
