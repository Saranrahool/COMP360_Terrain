extends Node3D

@export var size := 64
@export var cell_size := 2.0
@export var height := 12.0

var mesh_instance: MeshInstance3D

func _ready():
	generate_terrain()

func generate_terrain():
	# --- Noise setup ---
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.03
	noise.fractal_octaves = 4

	# --- SurfaceTool for mesh building ---
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(size):
		for x in range(size):
			# Sample height values
			var h1 = noise.get_noise_2d(x, z) * height
			var h2 = noise.get_noise_2d(x + 1, z) * height
			var h3 = noise.get_noise_2d(x, z + 1) * height
			var h4 = noise.get_noise_2d(x + 1, z + 1) * height

			# Create 4 vertex positions (a grid square)
			var v1 = Vector3(x * cell_size, h1, z * cell_size)
			var v2 = Vector3((x + 1) * cell_size, h2, z * cell_size)
			var v3 = Vector3(x * cell_size, h3, (z + 1) * cell_size)
			var v4 = Vector3((x + 1) * cell_size, h4, (z + 1) * cell_size)

			# Add 2 triangles per grid square
			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)

			st.add_vertex(v3)
			st.add_vertex(v2)
			st.add_vertex(v4)

	# --- Generate smooth shading ---
	st.generate_normals()
	st.generate_tangents()
	st.index()

	var mesh = st.commit()

	# Remove old terrain if it exists
	if mesh_instance:
		mesh_instance.queue_free()

	# --- Create and position mesh instance ---
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.translate(Vector3(-size * cell_size / 2, 0, -size * cell_size / 2))

	# --- Add smooth material ---
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.85, 0.9) # soft gray-blue tone
	mat.roughness = 0.9
	mat.metallic = 0.0
	mat.specular = 0.3
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mesh_instance.material_override = mat

	add_child(mesh_instance)
	print("✅ Terrain generated successfully with smooth shading!")
