extends Node3D

@export var size := 64
@export var cell_size := 2.0
@export var height := 15.0

var mesh_instance: MeshInstance3D

func _ready():
	generate_terrain()

func generate_terrain():
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05
	noise.fractal_octaves = 4

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(size):
		for x in range(size):
			var h1 = (noise.get_noise_2d(x, z) * 0.5 + 0.5) * height
			var h2 = (noise.get_noise_2d(x + 1, z) * 0.5 + 0.5) * height
			var h3 = (noise.get_noise_2d(x, z + 1) * 0.5 + 0.5) * height
			var h4 = (noise.get_noise_2d(x + 1, z + 1) * 0.5 + 0.5) * height

			var v1 = Vector3(x * cell_size, h1, z * cell_size)
			var v2 = Vector3((x + 1) * cell_size, h2, z * cell_size)
			var v3 = Vector3(x * cell_size, h3, (z + 1) * cell_size)
			var v4 = Vector3((x + 1) * cell_size, h4, (z + 1) * cell_size)

			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)
			st.add_vertex(v3)
			st.add_vertex(v2)
			st.add_vertex(v4)

	var mesh = st.commit()
	if mesh_instance:
		mesh_instance.queue_free()

	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.translate(Vector3(-size * cell_size / 2, 0, -size * cell_size / 2))

	# ✅ Smooth material setup
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.9, 0.9)
	mat.metallic = 0.1
	mat.roughness = 0.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.subsurf_scatter_strength = 0.1
	mesh_instance.material_override = mat

	add_child(mesh_instance)

	print("✅ Terrain generated successfully!")
