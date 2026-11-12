# CityBuilder.gd
# AGENT 4: REALISTIC GTA V-STYLE CITY, 3D ARCHITECTURE & NATURE SYSTEM
# Replaces primitive cone/cylinder placeholders with authentic 3D low-poly models:
# - California Palm trees along city avenues
# - Leafy Oak trees & wild bushes in countryside
# - Tall Pine trees & granite boulders on mountains
# - Modular 3D commercial buildings, retail storefronts, multi-tier towers with windows & depth
# - Gas station with canopy & pumps, suburban houses with fences, industrial warehouses
class_name CityBuilder
extends RefCounted

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

static var city_buildings_prefab: PackedScene = null
static var street_shops_prefab: PackedScene = null
static var police_car_prop_prefab: PackedScene = null
static var fence_prefab: PackedScene = null

static var mesh_palm: Mesh = null
static var mesh_oak: Mesh = null
static var mesh_pine: Mesh = null
static var mesh_bush: Mesh = null
static var mesh_rock: Mesh = null
static var mesh_grass: Mesh = null

static var _cached_towers: Dictionary = {}
static var _cached_towers_near: Dictionary = {}
static var _cached_towers_med: Dictionary = {}
static var _cached_towers_far: Dictionary = {}

static var _cached_apartment_mesh: ArrayMesh = null
static var _cached_apartment_near: ArrayMesh = null
static var _cached_apartment_med: ArrayMesh = null
static var _cached_apartment_far: ArrayMesh = null

static var _cached_house_meshes: Dictionary = {}
static var _cached_houses_near: Dictionary = {}
static var _cached_houses_med: Dictionary = {}
static var _cached_houses_far: Dictionary = {}

static func _setup_lod_instance(mesh: Mesh, vis_begin: float, vis_end: float, margin_begin: float = 0.0, margin_end: float = 0.0) -> MeshInstance3D:
	var inst = MeshInstance3D.new()
	inst.mesh = mesh
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	inst.visibility_range_begin = vis_begin
	inst.visibility_range_begin_margin = margin_begin
	inst.visibility_range_end = vis_end
	inst.visibility_range_end_margin = margin_end
	if vis_begin > 0.0 or vis_end > 0.0:
		inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	return inst

static func _bm(sx: float, sy: float, sz: float) -> BoxMesh:
	var m = BoxMesh.new()
	m.size = Vector3(sx, sy, sz)
	return m

static func _pm(sx: float, sy: float, sz: float) -> PrismMesh:
	var m = PrismMesh.new()
	m.size = Vector3(sx, sy, sz)
	return m

static func _combine_shapes(shapes: Array) -> Array:
	var all_verts = PackedVector3Array()
	var all_norms = PackedVector3Array()
	var all_uvs = PackedVector2Array()
	var all_indices = PackedInt32Array()
	
	for s in shapes:
		var m = s["mesh"] as Mesh
		var arrs = m.get_mesh_arrays()
		var verts = arrs[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var norms = arrs[Mesh.ARRAY_NORMAL] as PackedVector3Array
		var uvs = arrs[Mesh.ARRAY_TEX_UV] as PackedVector2Array
		var inds = arrs[Mesh.ARRAY_INDEX] as PackedInt32Array
		var pos = s.get("pos", Vector3.ZERO) as Vector3
		var rot = s.get("rot", Vector3.ZERO) as Vector3
		var basis = Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)))
		
		var base_i = all_verts.size()
		for v in verts:
			all_verts.append(basis * v + pos)
		for n in norms:
			all_norms.append((basis * n).normalized())
		for u in uvs:
			all_uvs.append(u)
		for idx in inds:
			all_indices.append(base_i + idx)
			
	var result = []
	result.resize(Mesh.ARRAY_MAX)
	result[Mesh.ARRAY_VERTEX] = all_verts
	result[Mesh.ARRAY_NORMAL] = all_norms
	result[Mesh.ARRAY_TEX_UV] = all_uvs
	result[Mesh.ARRAY_INDEX] = all_indices
	return result

static func _combine_box_meshes(boxes: Array) -> Array:
	var shapes = []
	for b in boxes:
		shapes.append({"mesh": _bm(b["size"].x, b["size"].y, b["size"].z), "pos": b["pos"]})
	return _combine_shapes(shapes)

static func _get_cached_house_near_mesh(variant_idx: int) -> ArrayMesh:
	if _cached_houses_near.has(variant_idx):
		return _cached_houses_near[variant_idx]
		
	var am = ArrayMesh.new()
	match variant_idx:
		0:
			# VARIANT 0: CALIFORNIAN SUBURBAN RANCH HOUSE (Single-Story Asymmetric L-Shape)
			# Surface 0: Siding Walls & Deep Skirt
			var s0 = [
				{"mesh": _bm(11.0, 3.6, 9.0), "pos": Vector3(0.0, 1.8, 0.0)},
				{"mesh": _bm(6.0, 3.4, 6.5), "pos": Vector3(-6.0, 1.7, 1.25)},
				{"mesh": _bm(6.4, 3.4, 6.8), "pos": Vector3(6.5, 1.7, 0.5)},
				{"mesh": _bm(19.8, 2.6, 10.5), "pos": Vector3(0.5, -1.3, 0.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_siding_material())
			
			# Surface 1: Dark Slate Architectural Shingle Gabled Roofs
			var s1 = [
				{"mesh": _pm(11.6, 2.8, 9.6), "pos": Vector3(0.0, 5.0, 0.0)},
				{"mesh": _pm(6.5, 2.2, 7.0), "pos": Vector3(-6.0, 4.5, 1.25)},
				{"mesh": _pm(6.8, 2.2, 7.2), "pos": Vector3(6.5, 4.5, 0.5)},
				{"mesh": _pm(3.6, 1.2, 2.4), "pos": Vector3(-1.0, 3.6, 5.2), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
			
			# Surface 2: Recessed Glass Windows & Front Entrance Double Doors
			var s2 = [
				{"mesh": _bm(1.8, 2.4, 0.1), "pos": Vector3(-1.0, 1.2, 4.52)},
				{"mesh": _bm(3.0, 1.8, 0.1), "pos": Vector3(2.5, 2.0, 4.52)},
				{"mesh": _bm(2.0, 1.6, 0.1), "pos": Vector3(-6.0, 2.0, 4.52)},
				{"mesh": _bm(0.1, 1.5, 2.2), "pos": Vector3(-9.02, 2.0, 1.0)},
				{"mesh": _bm(2.4, 1.6, 0.1), "pos": Vector3(0.0, 2.0, -4.52)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: Wood Trim, Porch Pillars, Sills & Concrete Chimney Cap
			var s3 = [
				{"mesh": _bm(3.4, 0.3, 2.2), "pos": Vector3(-1.0, 0.15, 5.2)},
				{"mesh": _bm(0.24, 2.8, 0.24), "pos": Vector3(-2.4, 1.55, 6.0)},
				{"mesh": _bm(0.24, 2.8, 0.24), "pos": Vector3(0.4, 1.55, 6.0)},
				{"mesh": _bm(3.2, 0.15, 0.35), "pos": Vector3(2.5, 1.05, 4.62)},
				{"mesh": _bm(3.2, 0.15, 0.35), "pos": Vector3(2.5, 2.95, 4.62)},
				{"mesh": _bm(2.2, 0.15, 0.35), "pos": Vector3(-6.0, 1.15, 4.62)},
				{"mesh": _bm(5.2, 0.25, 0.35), "pos": Vector3(6.5, 2.7, 3.95)},
				{"mesh": _bm(1.4, 0.25, 1.4), "pos": Vector3(-2.5, 6.8, -1.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_house_wood_trim_material())
			
			# Surface 4: Panelled Garage Door
			var s4 = [
				{"mesh": _bm(4.8, 2.5, 0.12), "pos": Vector3(6.5, 1.3, 3.92)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_house_garage_material())
			
			# Surface 5: Red Brick Chimney Body
			var s5 = [
				{"mesh": _bm(1.2, 4.5, 1.2), "pos": Vector3(-2.5, 4.6, -1.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s5))
			am.surface_set_material(5, WorldMaterialManager.get_house_brick_chimney_material())
			
		1:
			# VARIANT 1: TWO-STORY MODERN SUBURBAN HOME (Split-Level with Terrace & Cantilever)
			# Surface 0: Modern Crisp Off-White Architectural Stucco & Deep Skirt
			var s0 = [
				{"mesh": _bm(12.5, 3.8, 10.5), "pos": Vector3(0.0, 1.9, 0.0)},
				{"mesh": _bm(9.5, 3.5, 8.5), "pos": Vector3(-1.0, 5.55, -0.8)},
				{"mesh": _bm(4.5, 3.6, 2.0), "pos": Vector3(-3.2, 5.6, 4.2)},
				{"mesh": _bm(13.0, 2.6, 11.0), "pos": Vector3(0.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_modern_material())
			
			# Surface 1: Modern Roof Coping & Terrace Parapet
			var s1 = [
				{"mesh": _bm(9.9, 0.35, 8.9), "pos": Vector3(-1.0, 7.4, -0.8)},
				{"mesh": _bm(4.8, 0.35, 2.3), "pos": Vector3(-3.2, 7.5, 4.2)},
				{"mesh": _bm(3.8, 0.9, 0.25), "pos": Vector3(3.2, 4.25, 4.4)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
			
			# Surface 2: Modern Recessed Picture Windows & Ribbon Glass
			var s2 = [
				{"mesh": _bm(4.2, 2.6, 0.1), "pos": Vector3(-2.0, 1.8, 5.27)},
				{"mesh": _bm(3.6, 1.8, 0.1), "pos": Vector3(-3.2, 5.6, 5.22)},
				{"mesh": _bm(2.4, 2.4, 0.1), "pos": Vector3(2.5, 5.0, 3.42)},
				{"mesh": _bm(1.5, 2.6, 0.1), "pos": Vector3(1.2, 1.3, 5.27)},
				{"mesh": _bm(4.8, 2.5, 0.1), "pos": Vector3(0.0, 1.8, -5.27)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: Architectural Concrete Canopy, Pillars & Sills
			var s3 = [
				{"mesh": _bm(3.2, 0.25, 2.2), "pos": Vector3(1.2, 2.8, 6.2)},
				{"mesh": _bm(0.2, 2.8, 0.2), "pos": Vector3(2.5, 1.4, 7.1)},
				{"mesh": _bm(3.2, 0.2, 2.2), "pos": Vector3(1.2, 0.1, 6.2)},
				{"mesh": _bm(4.4, 0.2, 0.6), "pos": Vector3(-2.0, 3.15, 5.5)},
				{"mesh": _bm(1.2, 0.2, 1.0), "pos": Vector3(-4.5, 8.4, -2.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_building_concrete_material())
			
			# Surface 4: 2-Car Garage Door
			var s4 = [
				{"mesh": _bm(5.4, 2.6, 0.12), "pos": Vector3(3.2, 1.3, 5.27)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_house_garage_material())
			
			# Surface 5: Minimalist Modern Chimney Stack
			var s5 = [
				{"mesh": _bm(1.0, 8.2, 0.8), "pos": Vector3(-4.5, 4.2, -2.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s5))
			am.surface_set_material(5, WorldMaterialManager.get_curb_material())
			
		2:
			# VARIANT 2: SPANISH COLONIAL / MEDITERRANEAN REVIVAL VILLA
			# Surface 0: Warm Mediterranean Cream Stucco Walls & Deep Skirt
			var s0 = [
				{"mesh": _bm(12.0, 4.2, 11.0), "pos": Vector3(0.0, 2.1, 0.0)},
				{"mesh": _bm(5.5, 3.2, 5.5), "pos": Vector3(-3.0, 5.8, -2.2)},
				{"mesh": _bm(5.8, 3.5, 6.5), "pos": Vector3(5.8, 1.75, 0.5)},
				{"mesh": _bm(4.2, 1.5, 0.4), "pos": Vector3(0.0, 4.95, 5.3)},
				{"mesh": _bm(18.2, 2.6, 11.5), "pos": Vector3(1.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_stucco_material())
			
			# Surface 1: Terracotta S-Tile Multi-Tier Gabled Roofs
			var s1 = [
				{"mesh": _pm(12.6, 3.0, 11.6), "pos": Vector3(0.0, 5.6, 0.0)},
				{"mesh": _pm(6.0, 2.2, 6.0), "pos": Vector3(-3.0, 8.4, -2.2)},
				{"mesh": _pm(6.2, 2.0, 6.8), "pos": Vector3(5.8, 4.4, 0.5)},
				{"mesh": _pm(4.2, 1.0, 2.4), "pos": Vector3(-1.0, 3.8, 6.4), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_terracotta_material())
			
			# Surface 2: Recessed Multi-Pane Casement Windows & Glass
			var s2 = [
				{"mesh": _bm(1.8, 2.0, 0.1), "pos": Vector3(2.4, 2.2, 5.52)},
				{"mesh": _bm(1.6, 2.2, 0.1), "pos": Vector3(-3.0, 6.2, 0.52)},
				{"mesh": _bm(0.1, 1.8, 1.8), "pos": Vector3(-6.02, 2.2, 1.5)},
				{"mesh": _bm(1.8, 2.6, 0.12), "pos": Vector3(-1.0, 1.3, 5.52)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: Spanish Loggia Archway, Columns, Sills & Flue Cap
			var s3 = [
				{"mesh": _bm(4.0, 0.25, 2.4), "pos": Vector3(-1.0, 0.12, 6.4)},
				{"mesh": _bm(0.35, 3.0, 0.35), "pos": Vector3(-2.6, 1.5, 7.3)},
				{"mesh": _bm(0.35, 3.0, 0.35), "pos": Vector3(0.6, 1.5, 7.3)},
				{"mesh": _bm(3.8, 0.45, 0.45), "pos": Vector3(-1.0, 3.1, 7.3)},
				{"mesh": _bm(2.1, 0.15, 0.4), "pos": Vector3(2.4, 1.15, 5.65)},
				{"mesh": _bm(1.2, 0.4, 1.2), "pos": Vector3(3.5, 6.8, -3.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_house_wood_trim_material())
			
			# Surface 4: Carriage House Wood Garage Door
			var s4 = [
				{"mesh": _bm(4.6, 2.6, 0.12), "pos": Vector3(5.8, 1.3, 3.77)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_house_wood_trim_material())
			
			# Surface 5: Spanish Stucco Chimney Body
			var s5 = [
				{"mesh": _bm(1.0, 4.6, 1.0), "pos": Vector3(3.5, 4.6, -3.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s5))
			am.surface_set_material(5, WorldMaterialManager.get_house_stucco_material())
			
	_cached_houses_near[variant_idx] = am
	return am

static func _get_cached_house_mesh(variant_idx: int) -> ArrayMesh:
	return _get_cached_house_near_mesh(variant_idx)

static func _get_cached_house_med_mesh(variant_idx: int) -> ArrayMesh:
	if _cached_houses_med.has(variant_idx):
		return _cached_houses_med[variant_idx]
		
	var am = ArrayMesh.new()
	match variant_idx:
		0:
			# VARIANT 0: RANCH - MEDIUM LOD
			# Surface 0: Siding Walls & Deep Skirt
			var s0 = [
				{"mesh": _bm(11.0, 3.6, 9.0), "pos": Vector3(0.0, 1.8, 0.0)},
				{"mesh": _bm(6.0, 3.4, 6.5), "pos": Vector3(-6.0, 1.7, 1.25)},
				{"mesh": _bm(6.4, 3.4, 6.8), "pos": Vector3(6.5, 1.7, 0.5)},
				{"mesh": _bm(19.8, 2.6, 10.5), "pos": Vector3(0.5, -1.3, 0.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_siding_material())
			
			# Surface 1: Dark Slate Architectural Shingle Gabled Roofs
			var s1 = [
				{"mesh": _pm(11.6, 2.8, 9.6), "pos": Vector3(0.0, 5.0, 0.0)},
				{"mesh": _pm(6.5, 2.2, 7.0), "pos": Vector3(-6.0, 4.5, 1.25)},
				{"mesh": _pm(6.8, 2.2, 7.2), "pos": Vector3(6.5, 4.5, 0.5)},
				{"mesh": _pm(3.6, 1.2, 2.4), "pos": Vector3(-1.0, 3.6, 5.2), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
			
			# Surface 2: Recessed Glass Windows & Front Entrance Double Doors
			var s2 = [
				{"mesh": _bm(1.8, 2.4, 0.1), "pos": Vector3(-1.0, 1.2, 4.52)},
				{"mesh": _bm(3.0, 1.8, 0.1), "pos": Vector3(2.5, 2.0, 4.52)},
				{"mesh": _bm(2.0, 1.6, 0.1), "pos": Vector3(-6.0, 2.0, 4.52)},
				{"mesh": _bm(0.1, 1.5, 2.2), "pos": Vector3(-9.02, 2.0, 1.0)},
				{"mesh": _bm(2.4, 1.6, 0.1), "pos": Vector3(0.0, 2.0, -4.52)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: Garage Door
			var s3 = [
				{"mesh": _bm(4.8, 2.5, 0.12), "pos": Vector3(6.5, 1.3, 3.92)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_house_garage_material())
			
			# Surface 4: Red Brick Chimney Body
			var s4 = [
				{"mesh": _bm(1.2, 4.5, 1.2), "pos": Vector3(-2.5, 4.6, -1.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_house_brick_chimney_material())
		1:
			# VARIANT 1: TWO-STORY MODERN - MEDIUM LOD
			# Surface 0: Modern Stucco & Skirt
			var s0 = [
				{"mesh": _bm(12.5, 3.8, 10.5), "pos": Vector3(0.0, 1.9, 0.0)},
				{"mesh": _bm(9.5, 3.5, 8.5), "pos": Vector3(-1.0, 5.55, -0.8)},
				{"mesh": _bm(4.5, 3.6, 2.0), "pos": Vector3(-3.2, 5.6, 4.2)},
				{"mesh": _bm(13.0, 2.6, 11.0), "pos": Vector3(0.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_modern_material())
			
			# Surface 1: Modern Roof Coping & Terrace Parapet
			var s1 = [
				{"mesh": _bm(9.9, 0.35, 8.9), "pos": Vector3(-1.0, 7.4, -0.8)},
				{"mesh": _bm(4.8, 0.35, 2.3), "pos": Vector3(-3.2, 7.5, 4.2)},
				{"mesh": _bm(3.8, 0.9, 0.25), "pos": Vector3(3.2, 4.25, 4.4)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
			
			# Surface 2: Picture Windows & Ribbon Glass
			var s2 = [
				{"mesh": _bm(4.2, 2.6, 0.1), "pos": Vector3(-2.0, 1.8, 5.27)},
				{"mesh": _bm(3.6, 1.8, 0.1), "pos": Vector3(-3.2, 5.6, 5.22)},
				{"mesh": _bm(2.4, 2.4, 0.1), "pos": Vector3(2.5, 5.0, 3.42)},
				{"mesh": _bm(1.5, 2.6, 0.1), "pos": Vector3(1.2, 1.3, 5.27)},
				{"mesh": _bm(4.8, 2.5, 0.1), "pos": Vector3(0.0, 1.8, -5.27)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: 2-Car Garage Door
			var s3 = [
				{"mesh": _bm(5.4, 2.6, 0.12), "pos": Vector3(3.2, 1.3, 5.27)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_house_garage_material())
			
			# Surface 4: Modern Chimney Stack
			var s4 = [
				{"mesh": _bm(1.0, 8.2, 0.8), "pos": Vector3(-4.5, 4.2, -2.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_curb_material())
		2:
			# VARIANT 2: SPANISH COLONIAL - MEDIUM LOD
			# Surface 0: Warm Mediterranean Stucco & Skirt
			var s0 = [
				{"mesh": _bm(12.0, 4.2, 11.0), "pos": Vector3(0.0, 2.1, 0.0)},
				{"mesh": _bm(5.5, 3.2, 5.5), "pos": Vector3(-3.0, 5.8, -2.2)},
				{"mesh": _bm(5.8, 3.5, 6.5), "pos": Vector3(5.8, 1.75, 0.5)},
				{"mesh": _bm(4.2, 1.5, 0.4), "pos": Vector3(0.0, 4.95, 5.3)},
				{"mesh": _bm(18.2, 2.6, 11.5), "pos": Vector3(1.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_stucco_material())
			
			# Surface 1: Terracotta S-Tile Roofs
			var s1 = [
				{"mesh": _pm(12.6, 3.0, 11.6), "pos": Vector3(0.0, 5.6, 0.0)},
				{"mesh": _pm(6.0, 2.2, 6.0), "pos": Vector3(-3.0, 8.4, -2.2)},
				{"mesh": _pm(6.2, 2.0, 6.8), "pos": Vector3(5.8, 4.4, 0.5)},
				{"mesh": _pm(4.2, 1.0, 2.4), "pos": Vector3(-1.0, 3.8, 6.4), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_terracotta_material())
			
			# Surface 2: Casement Windows & Glass
			var s2 = [
				{"mesh": _bm(1.8, 2.0, 0.1), "pos": Vector3(2.4, 2.2, 5.52)},
				{"mesh": _bm(1.6, 2.2, 0.1), "pos": Vector3(-3.0, 6.2, 0.52)},
				{"mesh": _bm(0.1, 1.8, 1.8), "pos": Vector3(-6.02, 2.2, 1.5)},
				{"mesh": _bm(1.8, 2.6, 0.12), "pos": Vector3(-1.0, 1.3, 5.52)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s2))
			am.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
			
			# Surface 3: Carriage Wood Garage Door
			var s3 = [
				{"mesh": _bm(4.6, 2.6, 0.12), "pos": Vector3(5.8, 1.3, 3.77)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s3))
			am.surface_set_material(3, WorldMaterialManager.get_house_wood_trim_material())
			
			# Surface 4: Spanish Stucco Chimney Body
			var s4 = [
				{"mesh": _bm(1.0, 4.6, 1.0), "pos": Vector3(3.5, 4.6, -3.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s4))
			am.surface_set_material(4, WorldMaterialManager.get_house_stucco_material())
			
	_cached_houses_med[variant_idx] = am
	return am

static func _get_cached_house_far_mesh(variant_idx: int) -> ArrayMesh:
	if _cached_houses_far.has(variant_idx):
		return _cached_houses_far[variant_idx]
		
	var am = ArrayMesh.new()
	match variant_idx:
		0:
			# VARIANT 0: RANCH - FAR LOD (2-surface silhouette)
			var s0 = [
				{"mesh": _bm(11.0, 3.6, 9.0), "pos": Vector3(0.0, 1.8, 0.0)},
				{"mesh": _bm(6.0, 3.4, 6.5), "pos": Vector3(-6.0, 1.7, 1.25)},
				{"mesh": _bm(6.4, 3.4, 6.8), "pos": Vector3(6.5, 1.7, 0.5)},
				{"mesh": _bm(19.8, 2.6, 10.5), "pos": Vector3(0.5, -1.3, 0.5)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_siding_material())
			
			var s1 = [
				{"mesh": _pm(11.6, 2.8, 9.6), "pos": Vector3(0.0, 5.0, 0.0)},
				{"mesh": _pm(6.5, 2.2, 7.0), "pos": Vector3(-6.0, 4.5, 1.25)},
				{"mesh": _pm(6.8, 2.2, 7.2), "pos": Vector3(6.5, 4.5, 0.5)},
				{"mesh": _pm(3.6, 1.2, 2.4), "pos": Vector3(-1.0, 3.6, 5.2), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
		1:
			# VARIANT 1: TWO-STORY MODERN - FAR LOD (2-surface silhouette)
			var s0 = [
				{"mesh": _bm(12.5, 3.8, 10.5), "pos": Vector3(0.0, 1.9, 0.0)},
				{"mesh": _bm(9.5, 3.5, 8.5), "pos": Vector3(-1.0, 5.55, -0.8)},
				{"mesh": _bm(4.5, 3.6, 2.0), "pos": Vector3(-3.2, 5.6, 4.2)},
				{"mesh": _bm(13.0, 2.6, 11.0), "pos": Vector3(0.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_modern_material())
			
			var s1 = [
				{"mesh": _bm(9.9, 0.35, 8.9), "pos": Vector3(-1.0, 7.4, -0.8)},
				{"mesh": _bm(4.8, 0.35, 2.3), "pos": Vector3(-3.2, 7.5, 4.2)},
				{"mesh": _bm(3.8, 0.9, 0.25), "pos": Vector3(3.2, 4.25, 4.4)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_shingle_material())
		2:
			# VARIANT 2: SPANISH COLONIAL - FAR LOD (2-surface silhouette)
			var s0 = [
				{"mesh": _bm(12.0, 4.2, 11.0), "pos": Vector3(0.0, 2.1, 0.0)},
				{"mesh": _bm(5.5, 3.2, 5.5), "pos": Vector3(-3.0, 5.8, -2.2)},
				{"mesh": _bm(5.8, 3.5, 6.5), "pos": Vector3(5.8, 1.75, 0.5)},
				{"mesh": _bm(4.2, 1.5, 0.4), "pos": Vector3(0.0, 4.95, 5.3)},
				{"mesh": _bm(18.2, 2.6, 11.5), "pos": Vector3(1.0, -1.3, 0.0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s0))
			am.surface_set_material(0, WorldMaterialManager.get_house_stucco_material())
			
			var s1 = [
				{"mesh": _pm(12.6, 3.0, 11.6), "pos": Vector3(0.0, 5.6, 0.0)},
				{"mesh": _pm(6.0, 2.2, 6.0), "pos": Vector3(-3.0, 8.4, -2.2)},
				{"mesh": _pm(6.2, 2.0, 6.8), "pos": Vector3(5.8, 4.4, 0.5)},
				{"mesh": _pm(4.2, 1.0, 2.4), "pos": Vector3(-1.0, 3.8, 6.4), "rot": Vector3(0, 90, 0)}
			]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _combine_shapes(s1))
			am.surface_set_material(1, WorldMaterialManager.get_house_roof_terracotta_material())
			
	_cached_houses_far[variant_idx] = am
	return am

static func _get_cached_tower_near_mesh(total_height: float) -> ArrayMesh:
	if _cached_towers_near.has(total_height):
		return _cached_towers_near[total_height]
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Concrete elements (Podium, Foundation Skirt, Main Body, Cornices, Rooftop Mechanical & Antenna)
	var conc_boxes = [
		{"size": Vector3(28.0, 8.0, 28.0), "pos": Vector3(0, 4.0, 0)}, # Retail podium
		{"size": Vector3(28.4, 3.2, 28.4), "pos": Vector3(0, -1.6, 0)}, # 3.2m foundation skirt
		{"size": Vector3(28.6, 0.6, 28.6), "pos": Vector3(0, 8.1, 0)}, # Architectural podium cornice
		{"size": Vector3(22.0, total_height - 12.0, 22.0), "pos": Vector3(0, 8.0 + (total_height - 12.0) * 0.5, 0)}, # Main tower shaft
		{"size": Vector3(22.6, 0.5, 22.6), "pos": Vector3(0, total_height - 4.2, 0)}, # Upper tower cornice
		{"size": Vector3(8.0, 4.0, 8.0), "pos": Vector3(0, total_height - 2.0, 0)}, # Rooftop mechanical penthouse
		{"size": Vector3(0.35, 9.0, 0.35), "pos": Vector3(0, total_height + 4.5, 0)}, # Communications antenna spire
		{"size": Vector3(3.2, 1.8, 2.2), "pos": Vector3(6.5, total_height - 1.0, 4.0)}, # Rooftop HVAC unit 1
		{"size": Vector3(3.2, 1.8, 2.2), "pos": Vector3(-6.5, total_height - 1.0, -4.0)} # Rooftop HVAC unit 2
	]
	var conc_arrays = _combine_box_meshes(conc_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, conc_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_concrete_material())
	
	# Surface 1: Glass elements (Canopy, Ground-Floor Retail Doors, 4 Inset Window Facades)
	var win_height = total_height - 16.0
	var glass_boxes = [
		{"size": Vector3(12.0, 0.4, 4.5), "pos": Vector3(0, 4.2, -14.2)}, # Entrance canopy
		{"size": Vector3(8.0, 3.6, 0.2), "pos": Vector3(0, 1.8, -14.05)} # Ground-floor storefront glass doors
	]
	for face in [Vector3(0, 0, 11.05), Vector3(0, 0, -11.05), Vector3(11.05, 0, 0), Vector3(-11.05, 0, 0)]:
		var w_size: Vector3
		if abs(face.z) > 0.1:
			w_size = Vector3(18.0, win_height, 0.15)
		else:
			w_size = Vector3(0.15, win_height, 18.0)
		glass_boxes.append({"size": w_size, "pos": Vector3(face.x, 8.0 + win_height * 0.5, face.z)})
		
	var glass_arrays = _combine_box_meshes(glass_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, glass_arrays)
	arr_mesh.surface_set_material(1, WorldMaterialManager.get_building_glass_material())
	
	_cached_towers_near[total_height] = arr_mesh
	return arr_mesh

static func _get_cached_tower_med_mesh(total_height: float) -> ArrayMesh:
	if _cached_towers_med.has(total_height):
		return _cached_towers_med[total_height]
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Concrete elements (Podium, Skirt, Main Body, Cornices, Penthouse - Antenna Spire & HVAC units culled)
	var conc_boxes = [
		{"size": Vector3(28.0, 8.0, 28.0), "pos": Vector3(0, 4.0, 0)}, # Retail podium
		{"size": Vector3(28.4, 3.2, 28.4), "pos": Vector3(0, -1.6, 0)}, # 3.2m foundation skirt
		{"size": Vector3(28.6, 0.6, 28.6), "pos": Vector3(0, 8.1, 0)}, # Architectural podium cornice
		{"size": Vector3(22.0, total_height - 12.0, 22.0), "pos": Vector3(0, 8.0 + (total_height - 12.0) * 0.5, 0)}, # Main tower shaft
		{"size": Vector3(22.6, 0.5, 22.6), "pos": Vector3(0, total_height - 4.2, 0)}, # Upper tower cornice
		{"size": Vector3(8.0, 4.0, 8.0), "pos": Vector3(0, total_height - 2.0, 0)} # Rooftop mechanical penthouse
	]
	var conc_arrays = _combine_box_meshes(conc_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, conc_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_concrete_material())
	
	# Surface 1: Glass elements (4 Inset Window Facades - Small canopy & storefront doors culled)
	var win_height = total_height - 16.0
	var glass_boxes = []
	for face in [Vector3(0, 0, 11.05), Vector3(0, 0, -11.05), Vector3(11.05, 0, 0), Vector3(-11.05, 0, 0)]:
		var w_size: Vector3
		if abs(face.z) > 0.1:
			w_size = Vector3(18.0, win_height, 0.15)
		else:
			w_size = Vector3(0.15, win_height, 18.0)
		glass_boxes.append({"size": w_size, "pos": Vector3(face.x, 8.0 + win_height * 0.5, face.z)})
		
	var glass_arrays = _combine_box_meshes(glass_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, glass_arrays)
	arr_mesh.surface_set_material(1, WorldMaterialManager.get_building_glass_material())
	
	_cached_towers_med[total_height] = arr_mesh
	return arr_mesh

static func _get_cached_tower_far_mesh(total_height: float) -> ArrayMesh:
	if _cached_towers_far.has(total_height):
		return _cached_towers_far[total_height]
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Single unified concrete silhouette mesh (1 draw call, zero glass shader overhead)
	var conc_boxes = [
		{"size": Vector3(28.0, 8.0, 28.0), "pos": Vector3(0, 4.0, 0)}, # Retail podium
		{"size": Vector3(28.4, 3.2, 28.4), "pos": Vector3(0, -1.6, 0)}, # 3.2m foundation skirt
		{"size": Vector3(22.0, total_height - 8.0, 22.0), "pos": Vector3(0, 8.0 + (total_height - 8.0) * 0.5, 0)} # Main tower shaft
	]
	var conc_arrays = _combine_box_meshes(conc_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, conc_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_concrete_material())
	
	_cached_towers_far[total_height] = arr_mesh
	return arr_mesh

static func _get_cached_tower_mesh(total_height: float) -> ArrayMesh:
	return _get_cached_tower_near_mesh(total_height)

static func _get_cached_apartment_near_mesh() -> ArrayMesh:
	if _cached_apartment_near != null:
		return _cached_apartment_near
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Brick building body
	var brick_boxes = [
		{"size": Vector3(26.0, 18.0, 24.0), "pos": Vector3(0, 9.0, 0)}
	]
	var brick_arrays = _combine_box_meshes(brick_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, brick_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_brick_material())
	
	# Surface 1: Concrete Skirt, Entrance Portico, Pillars, Balconies, Parapet & Rooftop HVAC
	var conc_boxes = [
		{"size": Vector3(26.4, 3.0, 24.4), "pos": Vector3(0, -1.5, 0)}, # 3.0m deep foundation skirt
		{"size": Vector3(5.5, 0.4, 2.8), "pos": Vector3(0, 3.8, -13.2)}, # Entrance portico porch
		{"size": Vector3(0.4, 3.8, 0.4), "pos": Vector3(-2.4, 1.9, -13.2)}, # Entrance pillar left
		{"size": Vector3(0.4, 3.8, 0.4), "pos": Vector3(2.4, 1.9, -13.2)}, # Entrance pillar right
		{"size": Vector3(26.4, 0.8, 24.4), "pos": Vector3(0, 18.4, 0)}, # Rooftop parapet trim
		{"size": Vector3(3.4, 2.0, 2.5), "pos": Vector3(4.0, 19.0, 2.0)} # Rooftop HVAC compressor
	]
	for floor_idx in range(3):
		var y_balc = 4.5 + floor_idx * 4.2
		for balc_x in [-6.5, 6.5]:
			conc_boxes.append({"size": Vector3(4.8, 0.35, 1.8), "pos": Vector3(balc_x, y_balc, -12.8)})
	var conc_arrays = _combine_box_meshes(conc_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, conc_arrays)
	arr_mesh.surface_set_material(1, WorldMaterialManager.get_building_concrete_material())
	
	# Surface 2: Glass Entrance Double Doors & Patio Windows
	var glass_boxes = [
		{"size": Vector3(3.6, 3.0, 0.15), "pos": Vector3(0, 1.5, -12.02)} # Front entrance double doors
	]
	for floor_idx in range(3):
		var y_balc = 4.5 + floor_idx * 4.2
		for balc_x in [-6.5, 6.5]:
			glass_boxes.append({"size": Vector3(3.2, 2.6, 0.1), "pos": Vector3(balc_x, y_balc + 1.4, -12.02)})
	var glass_arrays = _combine_box_meshes(glass_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, glass_arrays)
	arr_mesh.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
	
	_cached_apartment_near = arr_mesh
	return arr_mesh

static func _get_cached_apartment_med_mesh() -> ArrayMesh:
	if _cached_apartment_med != null:
		return _cached_apartment_med
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Brick building body
	var brick_boxes = [
		{"size": Vector3(26.0, 18.0, 24.0), "pos": Vector3(0, 9.0, 0)}
	]
	var brick_arrays = _combine_box_meshes(brick_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, brick_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_brick_material())
	
	# Surface 1: Concrete Skirt, Balconies, Parapet (Small entrance pillars & rooftop HVAC culled)
	var conc_boxes = [
		{"size": Vector3(26.4, 3.0, 24.4), "pos": Vector3(0, -1.5, 0)}, # 3.0m deep foundation skirt
		{"size": Vector3(26.4, 0.8, 24.4), "pos": Vector3(0, 18.4, 0)} # Rooftop parapet trim
	]
	for floor_idx in range(3):
		var y_balc = 4.5 + floor_idx * 4.2
		for balc_x in [-6.5, 6.5]:
			conc_boxes.append({"size": Vector3(4.8, 0.35, 1.8), "pos": Vector3(balc_x, y_balc, -12.8)})
	var conc_arrays = _combine_box_meshes(conc_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, conc_arrays)
	arr_mesh.surface_set_material(1, WorldMaterialManager.get_building_concrete_material())
	
	# Surface 2: Glass Entrance Double Doors & Patio Windows
	var glass_boxes = [
		{"size": Vector3(3.6, 3.0, 0.15), "pos": Vector3(0, 1.5, -12.02)}
	]
	for floor_idx in range(3):
		var y_balc = 4.5 + floor_idx * 4.2
		for balc_x in [-6.5, 6.5]:
			glass_boxes.append({"size": Vector3(3.2, 2.6, 0.1), "pos": Vector3(balc_x, y_balc + 1.4, -12.02)})
	var glass_arrays = _combine_box_meshes(glass_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, glass_arrays)
	arr_mesh.surface_set_material(2, WorldMaterialManager.get_building_glass_material())
	
	_cached_apartment_med = arr_mesh
	return arr_mesh

static func _get_cached_apartment_far_mesh() -> ArrayMesh:
	if _cached_apartment_far != null:
		return _cached_apartment_far
		
	var arr_mesh = ArrayMesh.new()
	
	# Surface 0: Single unified brick silhouette mesh (1 draw call, zero glass shader overhead)
	var brick_boxes = [
		{"size": Vector3(26.0, 18.0, 24.0), "pos": Vector3(0, 9.0, 0)},
		{"size": Vector3(26.4, 3.0, 24.4), "pos": Vector3(0, -1.5, 0)}
	]
	var brick_arrays = _combine_box_meshes(brick_boxes)
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, brick_arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_building_brick_material())
	
	_cached_apartment_far = arr_mesh
	return arr_mesh

static func _get_cached_apartment_mesh() -> ArrayMesh:
	return _get_cached_apartment_near_mesh()

static func _init_prefabs():
	if street_shops_prefab == null:
		# Only load active prefabs; avoid loading unused 130MB RealCityBuildings8.scn
		street_shops_prefab = load("res://scenes/environments/models/RealStreet6.scn")
		fence_prefab = load("res://assets/nature_kit/glb/fence_simpleHigh.glb")
		
		# Load and cache authentic 3D nature meshes from project assets
		mesh_palm = _extract_mesh("res://assets/nature_kit/glb/tree_palm.glb")
		mesh_oak = _extract_mesh("res://assets/nature_kit/glb/tree_oak.glb")
		mesh_pine = _extract_mesh("res://assets/nature_kit/glb/tree_pineTallA.glb")
		mesh_bush = _extract_mesh("res://assets/nature_kit/glb/plant_bushLarge.glb")
		mesh_rock = _extract_mesh("res://assets/nature_kit/glb/rock_tallA.glb")
		mesh_grass = _extract_mesh("res://assets/nature_kit/glb/grass.glb")

static func _extract_mesh(glb_path: String) -> Mesh:
	var scn = load(glb_path) as PackedScene
	if not scn:
		return null
	var inst = scn.instantiate()
	var found_mesh: Mesh = null
	var stack = [inst]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh != null:
			found_mesh = curr.mesh
			break
		for c in curr.get_children():
			stack.append(c)
	inst.free()
	return found_mesh

static func populate_chunk(chunk_node: Node3D, coord: Vector2i, region_type: int):
	_init_prefabs()
	
	match region_type:
		OpenWorldConfig.RegionType.CITY_DOWNTOWN:
			_build_downtown_district(chunk_node, coord)
		OpenWorldConfig.RegionType.CITY_EAST:
			_build_commercial_district(chunk_node, coord)
		OpenWorldConfig.RegionType.SUBURBS:
			_build_suburban_district(chunk_node, coord)
		OpenWorldConfig.RegionType.INDUSTRIAL:
			_build_industrial_district(chunk_node, coord)
		OpenWorldConfig.RegionType.COUNTRYSIDE:
			_build_countryside_vegetation(chunk_node, coord)
		OpenWorldConfig.RegionType.MOUNTAIN:
			_build_mountain_forest(chunk_node, coord)

static func _get_ground_pos(coord: Vector2i, local_x: float, local_z: float) -> Vector3:
	var wx = float(coord.x) * OpenWorldConfig.CHUNK_SIZE + local_x
	var wz = float(coord.y) * OpenWorldConfig.CHUNK_SIZE + local_z
	var wy = OpenWorldConfig.get_terrain_height(wx, wz)
	return Vector3(local_x, wy, local_z)

# ==============================================================================
# 1. DOWNTOWN DISTRICT
# ==============================================================================
static func _build_downtown_district(chunk_node: Node3D, coord: Vector2i):
	# 4 Architectural City Plaza Slabs using optimized plaza shader (specular disabled, low fill-rate overhead)
	var plaza_mat = WorldMaterialManager.get_plaza_shader_material()
	var block_centers = [
		Vector2(27.5, 27.5),
		Vector2(100.5, 27.5),
		Vector2(27.5, 100.5),
		Vector2(100.5, 100.5)
	]
	for b_pos in block_centers:
		var g_pos = _get_ground_pos(coord, b_pos.x, b_pos.y)
		var p_mesh = BoxMesh.new()
		# 1.4m deep foundation skirt so edges never float even on undulating terrain
		p_mesh.size = Vector3(49.0, 1.4, 49.0)
		var p_inst = MeshInstance3D.new()
		p_inst.mesh = p_mesh
		p_inst.material_override = plaza_mat
		p_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		p_inst.position = Vector3(b_pos.x, g_pos.y - 0.65, b_pos.y)
		chunk_node.add_child(p_inst)
		
	# Corner 1 (Top-Left): Multi-Tier Architectural Financial Tower (Batch-Optimized ArrayMesh)
	var p1 = _get_ground_pos(coord, 30.0, 30.0)
	_create_architectural_tower(chunk_node, p1, 44.0)
		
	# Corner 2 (Top-Right): Street Shops with Storefronts, Signage & Foundation Skirt
	if street_shops_prefab:
		var p2 = _get_ground_pos(coord, 98.0, 42.0)
		var s1 = street_shops_prefab.instantiate()
		s1.position = p2
		s1.scale = Vector3(2.5, 2.5, 2.5)
		_optimize_shop_model(s1)
		
		# Foundation skirt slab extending 2.8m underground to eliminate floating
		var skirt_mesh = BoxMesh.new()
		skirt_mesh.size = Vector3(9.6, 1.2, 7.2) # Scaled by 2.5 = 24.0m x 3.0m x 18.0m
		var skirt_inst = MeshInstance3D.new()
		skirt_inst.mesh = skirt_mesh
		skirt_inst.material_override = WorldMaterialManager.get_building_concrete_material()
		skirt_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		skirt_inst.position = Vector3(0.0, -0.6, 0.0)
		s1.add_child(skirt_inst)
		
		chunk_node.add_child(s1)
		_add_box_collider_to_chunk(chunk_node, p2, Vector3(22.0, 9.0, 16.0))
		
	# Corner 3 (Bottom-Left): Multi-Tier Modern High-Rise Tower (Batch-Optimized ArrayMesh)
	var p3 = _get_ground_pos(coord, 30.0, 98.0)
	_create_architectural_tower(chunk_node, p3, 52.0)
	
	# Corner 4 (Bottom-Right): Brick Residential Complex with Balconies (Batch-Optimized ArrayMesh)
	var p4 = _get_ground_pos(coord, 98.0, 98.0)
	_create_brick_apartment(chunk_node, p4)
	
	# Avenue Sidewalks: Authentic California Palm Trees & Landscaping Bushes
	_create_avenue_palm_trees(chunk_node, coord)

static func _create_architectural_tower(chunk_node: Node3D, pos: Vector3, total_height: float):
	var root = Node3D.new()
	root.position = pos
	
	# 3-Tier Distance-Based Architectural Building LOD System (Zero popping cross-fade)
	var lod0 = _setup_lod_instance(_get_cached_tower_near_mesh(total_height), 0.0, 45.0, 0.0, 6.0)
	root.add_child(lod0)
	
	var lod1 = _setup_lod_instance(_get_cached_tower_med_mesh(total_height), 45.0, 110.0, 6.0, 10.0)
	root.add_child(lod1)
	
	var lod2 = _setup_lod_instance(_get_cached_tower_far_mesh(total_height), 110.0, 450.0, 10.0, 30.0)
	root.add_child(lod2)
	
	chunk_node.add_child(root)
	_add_box_collider_to_chunk(chunk_node, pos, Vector3(28.0, total_height, 28.0))

static func _create_brick_apartment(chunk_node: Node3D, pos: Vector3):
	var root = Node3D.new()
	root.position = pos
	
	# 3-Tier Distance-Based Architectural Building LOD System (Zero popping cross-fade)
	var lod0 = _setup_lod_instance(_get_cached_apartment_near_mesh(), 0.0, 45.0, 0.0, 6.0)
	root.add_child(lod0)
	
	var lod1 = _setup_lod_instance(_get_cached_apartment_med_mesh(), 45.0, 110.0, 6.0, 10.0)
	root.add_child(lod1)
	
	var lod2 = _setup_lod_instance(_get_cached_apartment_far_mesh(), 110.0, 450.0, 10.0, 30.0)
	root.add_child(lod2)
	
	chunk_node.add_child(root)
	_add_box_collider_to_chunk(chunk_node, pos, Vector3(26.0, 18.0, 24.0))

# ==============================================================================
# 2. COMMERCIAL DISTRICT
# ==============================================================================
static func _build_commercial_district(chunk_node: Node3D, coord: Vector2i):
	if street_shops_prefab:
		var p1 = _get_ground_pos(coord, 40.0, 42.0)
		var s1 = street_shops_prefab.instantiate()
		s1.position = p1
		s1.scale = Vector3(2.5, 2.5, 2.5)
		_optimize_shop_model(s1)
		
		# Foundation skirt slab extending 2.8m underground to eliminate floating
		var sm1 = BoxMesh.new()
		sm1.size = Vector3(9.6, 1.2, 7.2)
		var sk1 = MeshInstance3D.new()
		sk1.mesh = sm1
		sk1.material_override = WorldMaterialManager.get_building_concrete_material()
		sk1.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sk1.position = Vector3(0.0, -0.6, 0.0)
		s1.add_child(sk1)
		
		chunk_node.add_child(s1)
		_add_box_collider_to_chunk(chunk_node, p1, Vector3(22.0, 9.0, 16.0))
		
		var p2 = _get_ground_pos(coord, 98.0, 42.0)
		var s2 = street_shops_prefab.instantiate()
		s2.position = p2
		s2.scale = Vector3(2.5, 2.5, 2.5)
		_optimize_shop_model(s2)
		
		var sm2 = BoxMesh.new()
		sm2.size = Vector3(9.6, 1.2, 7.2)
		var sk2 = MeshInstance3D.new()
		sk2.mesh = sm2
		sk2.material_override = WorldMaterialManager.get_building_concrete_material()
		sk2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sk2.position = Vector3(0.0, -0.6, 0.0)
		s2.add_child(sk2)
		
		chunk_node.add_child(s2)
		_add_box_collider_to_chunk(chunk_node, p2, Vector3(22.0, 9.0, 16.0))
		
	# Gas Station Canopy at (64, wy, 96)
	var p_gas = _get_ground_pos(coord, 64.0, 96.0)
	_create_gas_station(chunk_node, p_gas)
	_create_avenue_palm_trees(chunk_node, coord)

static func _create_gas_station(chunk_node: Node3D, pos: Vector3):
	var root = Node3D.new()
	root.position = pos
	
	# Solid Concrete Island Foundation Pad & Skirt (visible to 220m)
	var pad_mesh = BoxMesh.new()
	pad_mesh.size = Vector3(24.0, 2.2, 16.0)
	var pad_inst = _setup_lod_instance(pad_mesh, 0.0, 220.0, 0.0, 15.0)
	pad_inst.material_override = WorldMaterialManager.get_building_concrete_material()
	pad_inst.position = Vector3(0.0, -0.9, 0.0) # Top surface at y=+0.2, skirt extends 2.0m underground
	root.add_child(pad_inst)
	
	# Canopy Roof (visible to 220m)
	var canopy_mesh = BoxMesh.new()
	canopy_mesh.size = Vector3(22.0, 0.9, 14.0)
	var canopy_inst = _setup_lod_instance(canopy_mesh, 0.0, 220.0, 0.0, 15.0)
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.85, 0.22, 0.16) # Red trim
	c_mat.roughness = 0.5
	canopy_inst.material_override = c_mat
	canopy_inst.position = Vector3(0.0, 5.4, 0.0)
	root.add_child(canopy_inst)
	
	# Steel Support Pillars (medium distance: cull at 110m)
	var metal_mat = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.88, 0.88, 0.90)
	metal_mat.metallic = 0.8
	metal_mat.roughness = 0.35
	for pil_x in [-7.5, 7.5]:
		for pil_z in [-4.5, 4.5]:
			var pil = CylinderMesh.new()
			pil.top_radius = 0.25
			pil.bottom_radius = 0.25
			pil.height = 5.4
			var p_inst = _setup_lod_instance(pil, 0.0, 110.0, 0.0, 10.0)
			p_inst.material_override = metal_mat
			p_inst.position = Vector3(pil_x, 2.7, pil_z)
			root.add_child(p_inst)
	
	# Fuel Pumps (near props: cull at 45m)
	for p_offset in [-5.5, 5.5]:
		var pmesh = BoxMesh.new()
		pmesh.size = Vector3(1.3, 2.2, 0.9)
		var pump = _setup_lod_instance(pmesh, 0.0, 45.0, 0.0, 6.0)
		var pmat = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.92, 0.92, 0.94)
		pump.material_override = pmat
		pump.position = Vector3(p_offset, 1.1, 0.0)
		root.add_child(pump)
		_add_box_collider(pump, pmesh.size, Vector3.ZERO)
		
	chunk_node.add_child(root)

# ==============================================================================
# 3. SUBURBAN DISTRICT (AAA ARCHITECTURAL RESIDENTIAL STREET)
# ==============================================================================
static func _build_suburban_district(chunk_node: Node3D, coord: Vector2i):
	# Flank the central avenue on Left Lot (x = 26.0) and Right Lot (x = 102.0), keeping avenue (x=64) clear
	var house_xs = [26.0, 102.0]
	var house_zs = [26.0, 70.0, 106.0]
	var variant_idx = 0
	for hx in house_xs:
		var facing = 90.0 if hx < 64.0 else -90.0 # Face the central avenue
		for hz in house_zs:
			var house_pos = _get_ground_pos(coord, hx, hz)
			_create_house(chunk_node, house_pos, variant_idx % 3, facing)
			variant_idx += 1
			
	_create_avenue_palm_trees(chunk_node, coord)
	_build_suburban_lawns(chunk_node, coord)

static func _create_house(chunk_node: Node3D, pos: Vector3, variant_idx: int = 0, facing_angle: float = 0.0):
	var house_root = Node3D.new()
	house_root.position = pos
	house_root.rotation_degrees = Vector3(0.0, facing_angle, 0.0)
	
	# 3-Tier Distance-Based Building LOD System (Zero popping cross-fade)
	var lod0 = _setup_lod_instance(_get_cached_house_near_mesh(variant_idx), 0.0, 45.0, 0.0, 6.0)
	house_root.add_child(lod0)
	
	var lod1 = _setup_lod_instance(_get_cached_house_med_mesh(variant_idx), 45.0, 110.0, 6.0, 10.0)
	house_root.add_child(lod1)
	
	var lod2 = _setup_lod_instance(_get_cached_house_far_mesh(variant_idx), 110.0, 450.0, 10.0, 30.0)
	house_root.add_child(lod2)
	
	# Concrete Driveway connecting garage to sidewalk (visible up to 110m)
	var dw_mesh = BoxMesh.new()
	dw_mesh.size = Vector3(6.5, 0.15, 8.5)
	var dw_inst = _setup_lod_instance(dw_mesh, 0.0, 110.0, 0.0, 10.0)
	dw_inst.material_override = WorldMaterialManager.get_building_concrete_material()
	dw_inst.position = Vector3(5.8, 0.05, 8.5)
	house_root.add_child(dw_inst)
	
	# Suburban Picket Fence along front lawn (micro-props: cull smoothly at 45m)
	if fence_prefab:
		for f_idx in range(3):
			var fence = fence_prefab.instantiate()
			fence.position = Vector3(-6.0 + f_idx * 4.5, 0.0, 10.5)
			for fc in fence.find_children("*", "MeshInstance3D", true, false):
				fc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				fc.visibility_range_begin = 0.0
				fc.visibility_range_end = 45.0
				fc.visibility_range_end_margin = 6.0
				fc.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			house_root.add_child(fence)
			
	# Solid Box Collider calibrated for each house variant
	var col_size = Vector3(19.0, 6.0, 11.0)
	if variant_idx == 1:
		col_size = Vector3(13.0, 8.5, 11.0)
	elif variant_idx == 2:
		col_size = Vector3(18.0, 8.5, 12.0)
	_add_box_collider(house_root, col_size, Vector3(0.0, col_size.y * 0.5, 0.0))
	
	chunk_node.add_child(house_root)

static func _build_suburban_lawns(chunk_node: Node3D, coord: Vector2i):
	if not mesh_grass:
		return
	var ox = float(coord.x) * OpenWorldConfig.CHUNK_SIZE
	var oz = float(coord.y) * OpenWorldConfig.CHUNK_SIZE
	var lawn_coords: Array[Vector3] = [
		Vector3(34.0, 0.0, 26.0), Vector3(34.0, 0.0, 70.0), Vector3(34.0, 0.0, 106.0),
		Vector3(18.0, 0.0, 32.0), Vector3(18.0, 0.0, 76.0), Vector3(18.0, 0.0, 112.0),
		Vector3(94.0, 0.0, 26.0), Vector3(94.0, 0.0, 70.0), Vector3(94.0, 0.0, 106.0),
		Vector3(110.0, 0.0, 32.0), Vector3(110.0, 0.0, 76.0), Vector3(110.0, 0.0, 112.0)
	]
	var mm_g = MultiMesh.new()
	mm_g.transform_format = MultiMesh.TRANSFORM_3D
	mm_g.mesh = mesh_grass
	mm_g.instance_count = lawn_coords.size() * 2
	var idx = 0
	for base in lawn_coords:
		for sub in range(2):
			var px = base.x + (sub - 0.5) * 2.5
			var pz = base.z + (sub - 0.5) * 2.0
			var py = OpenWorldConfig.get_terrain_height(ox + px, oz + pz)
			var s = 2.2 + sub * 0.4
			var rot = (idx * 57.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm_g.set_instance_transform(idx, Transform3D(basis, Vector3(px, py, pz)))
			idx += 1
	var mm_g_inst = MultiMeshInstance3D.new()
	mm_g_inst.multimesh = mm_g
	mm_g_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mm_g_inst.visibility_range_end = 55.0
	mm_g_inst.visibility_range_end_margin = 8.0
	mm_g_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	chunk_node.add_child(mm_g_inst)

# ==============================================================================
# 4. INDUSTRIAL DISTRICT
# ==============================================================================
static func _build_industrial_district(chunk_node: Node3D, coord: Vector2i):
	var p_wh1 = _get_ground_pos(coord, 36.0, 36.0)
	_create_warehouse(chunk_node, p_wh1, Vector3(34.0, 14.0, 24.0))
	var p_wh2 = _get_ground_pos(coord, 85.0, 36.0)
	_create_warehouse(chunk_node, p_wh2, Vector3(36.0, 16.0, 26.0))
	var p_wh3 = _get_ground_pos(coord, 50.0, 85.0)
	_create_warehouse(chunk_node, p_wh3, Vector3(45.0, 18.0, 30.0))
	
	# Shipping containers
	var pad_mesh = BoxMesh.new()
	pad_mesh.size = Vector3(18.0, 2.0, 16.0)
	var pad_inst = MeshInstance3D.new()
	pad_inst.mesh = pad_mesh
	pad_inst.material_override = WorldMaterialManager.get_building_concrete_material()
	pad_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var p_ground = _get_ground_pos(coord, 96.0, 79.0)
	pad_inst.position = Vector3(96.0, p_ground.y - 0.9, 79.0)
	chunk_node.add_child(pad_inst)
	
	var colors = [Color(0.85, 0.2, 0.15), Color(0.18, 0.42, 0.85), Color(0.18, 0.65, 0.32), Color(0.92, 0.62, 0.12)]
	for i in range(8):
		var lx = 92.0 + (i % 2) * 6.5
		var lz = 75.0 + (i % 4) * 2.8
		var ground_pos = _get_ground_pos(coord, lx, lz)
		var c_mesh = BoxMesh.new()
		c_mesh.size = Vector3(6.0, 2.6, 2.4)
		var c_inst = MeshInstance3D.new()
		c_inst.mesh = c_mesh
		var c_mat = StandardMaterial3D.new()
		c_mat.albedo_color = colors[i % colors.size()]
		var norm = load("res://textures/pbr/tex_metal_normal.png")
		if norm:
			c_mat.normal_enabled = true
			c_mat.normal_texture = norm
			c_mat.normal_scale = 0.5
		c_mat.roughness = 0.55
		c_mat.metallic = 0.65
		c_inst.material_override = c_mat
		c_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		c_inst.position = Vector3(lx, ground_pos.y + 1.3 + int(i / 4) * 2.6, lz)
		chunk_node.add_child(c_inst)
		_add_box_collider(c_inst, c_mesh.size, Vector3.ZERO)

static func _create_warehouse(chunk_node: Node3D, pos: Vector3, size: Vector3):
	var root = Node3D.new()
	root.position = pos
	
	var wmesh = BoxMesh.new()
	wmesh.size = size
	var wh = _setup_lod_instance(wmesh, 0.0, 450.0, 0.0, 30.0)
	wh.material_override = WorldMaterialManager.get_warehouse_metal_material()
	wh.position = Vector3(0.0, size.y * 0.5, 0.0)
	root.add_child(wh)
	
	# Foundation Skirt extending 2.8m underground to eliminate floating
	var f_mesh = BoxMesh.new()
	f_mesh.size = Vector3(size.x + 0.6, 2.8, size.z + 0.6)
	var f_inst = _setup_lod_instance(f_mesh, 0.0, 450.0, 0.0, 30.0)
	f_inst.material_override = WorldMaterialManager.get_building_concrete_material()
	f_inst.position = Vector3(0.0, -1.4, 0.0)
	root.add_child(f_inst)
	
	# Roll-up Cargo Door (cull at 110m)
	var door_mesh = BoxMesh.new()
	door_mesh.size = Vector3(7.0, 5.2, 0.2)
	var door_inst = _setup_lod_instance(door_mesh, 0.0, 110.0, 0.0, 10.0)
	var d_mat = StandardMaterial3D.new()
	d_mat.albedo_color = Color(0.22, 0.24, 0.28)
	d_mat.roughness = 0.5
	d_mat.metallic = 0.7
	door_inst.material_override = d_mat
	door_inst.position = Vector3(0.0, 2.6, size.z * 0.5 + 0.1)
	root.add_child(door_inst)
	
	# Industrial Rooftop AC Unit (near micro-prop: cull at 45m)
	var ac_mesh = BoxMesh.new()
	ac_mesh.size = Vector3(4.2, 2.4, 4.2)
	var ac_inst = _setup_lod_instance(ac_mesh, 0.0, 45.0, 0.0, 6.0)
	ac_inst.material_override = WorldMaterialManager.get_building_concrete_material()
	ac_inst.position = Vector3(0.0, size.y + 1.2, 0.0)
	root.add_child(ac_inst)
	
	_add_box_collider(root, size, Vector3(0.0, size.y * 0.5, 0.0))
	chunk_node.add_child(root)

# ==============================================================================
# 5. NATURE & VEGETATION (REAL LOW-POLY 3D MODELS VIA MULTIMESH)
# ==============================================================================
static func _create_avenue_palm_trees(chunk_node: Node3D, coord: Vector2i):
	if not mesh_palm:
		return
		
	var tree_coords: Array[Vector3] = [
		Vector3(18.0, 0.0, 52.0),
		Vector3(38.0, 0.0, 52.0),
		Vector3(92.0, 0.0, 52.0),
		Vector3(112.0, 0.0, 52.0),
		Vector3(75.5, 0.0, 32.0),
		Vector3(75.5, 0.0, 85.0),
		Vector3(18.0, 0.0, 76.0),
		Vector3(92.0, 0.0, 76.0)
	]
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh_palm
	mm.instance_count = tree_coords.size()
	
	var ox = float(coord.x) * OpenWorldConfig.CHUNK_SIZE
	var oz = float(coord.y) * OpenWorldConfig.CHUNK_SIZE
	
	for i in range(tree_coords.size()):
		var base = tree_coords[i]
		base.y = OpenWorldConfig.get_terrain_height(ox + base.x, oz + base.z)
		var rot_y = (i * 45.0) * PI / 180.0
		var basis = Basis(Vector3.UP, rot_y).scaled(Vector3(1.3, 1.4, 1.3))
		var t = Transform3D(basis, base)
		mm.set_instance_transform(i, t)
		
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.multimesh = mm
	mm_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mm_inst.visibility_range_end = 380.0
	mm_inst.visibility_range_end_margin = 30.0
	mm_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	chunk_node.add_child(mm_inst)
	
	# Add bushes under palm trees
	if mesh_bush:
		var mm_b = MultiMesh.new()
		mm_b.transform_format = MultiMesh.TRANSFORM_3D
		mm_b.mesh = mesh_bush
		mm_b.instance_count = tree_coords.size()
		for i in range(tree_coords.size()):
			var base = tree_coords[i]
			var b_pos = Vector3(base.x + 0.8, OpenWorldConfig.get_terrain_height(ox + base.x + 0.8, oz + base.z + 0.6), base.z + 0.6)
			var b_basis = Basis(Vector3.UP, (i * 60.0) * PI / 180.0).scaled(Vector3(1.2, 1.0, 1.2))
			mm_b.set_instance_transform(i, Transform3D(b_basis, b_pos))
		var mm_b_inst = MultiMeshInstance3D.new()
		mm_b_inst.multimesh = mm_b
		mm_b_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_b_inst.visibility_range_end = 85.0
		mm_b_inst.visibility_range_end_margin = 10.0
		mm_b_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_b_inst)

static func _build_countryside_vegetation(chunk_node: Node3D, coord: Vector2i):
	var size = OpenWorldConfig.CHUNK_SIZE
	var ox = float(coord.x) * size
	var oz = float(coord.y) * size
	
	# 1. Real 3D Oak Trees
	if mesh_oak:
		var count = 18
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh_oak
		mm.instance_count = count
		
		for i in range(count):
			var lx = fmod(14.0 + (i * 27.0), size - 28.0) + 14.0
			var lz = fmod(12.0 + (i * 35.0), size - 28.0) + 12.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 1.2 + fmod(i * 0.17, 0.6)
			var rot = (i * 37.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
			
		var mm_inst = MultiMeshInstance3D.new()
		mm_inst.multimesh = mm
		mm_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_inst.visibility_range_end = 380.0
		mm_inst.visibility_range_end_margin = 30.0
		mm_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_inst)
		
	# 2. Wild Bushes
	if mesh_bush:
		var b_count = 24
		var mm_bush = MultiMesh.new()
		mm_bush.transform_format = MultiMesh.TRANSFORM_3D
		mm_bush.mesh = mesh_bush
		mm_bush.instance_count = b_count
		
		for i in range(b_count):
			var lx = fmod(8.0 + (i * 19.0), size - 16.0) + 8.0
			var lz = fmod(16.0 + (i * 23.0), size - 16.0) + 16.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 1.0 + fmod(i * 0.23, 0.8)
			var rot = (i * 47.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm_bush.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
			
		var mm_bush_inst = MultiMeshInstance3D.new()
		mm_bush_inst.multimesh = mm_bush
		mm_bush_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_bush_inst.visibility_range_end = 85.0
		mm_bush_inst.visibility_range_end_margin = 10.0
		mm_bush_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_bush_inst)
		
	# 3. Lush Green Wild Grass Fields
	if mesh_grass:
		var g_count = 48
		var mm_g = MultiMesh.new()
		mm_g.transform_format = MultiMesh.TRANSFORM_3D
		mm_g.mesh = mesh_grass
		mm_g.instance_count = g_count
		for i in range(g_count):
			var lx = fmod(6.0 + (i * 17.0), size - 12.0) + 6.0
			var lz = fmod(10.0 + (i * 21.0), size - 12.0) + 10.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 2.4 + fmod(i * 0.15, 1.0)
			var rot = (i * 61.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm_g.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
		var mm_g_inst = MultiMeshInstance3D.new()
		mm_g_inst.multimesh = mm_g
		mm_g_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_g_inst.visibility_range_end = 55.0
		mm_g_inst.visibility_range_end_margin = 8.0
		mm_g_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_g_inst)

static func _build_mountain_forest(chunk_node: Node3D, coord: Vector2i):
	var size = OpenWorldConfig.CHUNK_SIZE
	var ox = float(coord.x) * size
	var oz = float(coord.y) * size
	
	# 1. Real 3D Pine Trees
	if mesh_pine:
		var count = 22
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh_pine
		mm.instance_count = count
		
		for i in range(count):
			var lx = fmod(10.0 + (i * 23.0), size - 20.0) + 10.0
			var lz = fmod(8.0 + (i * 31.0), size - 20.0) + 8.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 1.3 + fmod(i * 0.2, 0.7)
			var rot = (i * 53.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
			
		var mm_inst = MultiMeshInstance3D.new()
		mm_inst.multimesh = mm
		mm_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_inst.visibility_range_end = 380.0
		mm_inst.visibility_range_end_margin = 30.0
		mm_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_inst)
		
	# 2. Mountain Granite Rock Boulders
	if mesh_rock:
		var r_count = 14
		var mm_r = MultiMesh.new()
		mm_r.transform_format = MultiMesh.TRANSFORM_3D
		mm_r.mesh = mesh_rock
		mm_r.instance_count = r_count
		
		for i in range(r_count):
			var lx = fmod(18.0 + (i * 29.0), size - 24.0) + 18.0
			var lz = fmod(14.0 + (i * 37.0), size - 24.0) + 14.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 1.5 + fmod(i * 0.3, 1.2)
			var rot = (i * 71.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm_r.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
			
		var mm_r_inst = MultiMeshInstance3D.new()
		mm_r_inst.multimesh = mm_r
		mm_r_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_r_inst.visibility_range_end = 320.0
		mm_r_inst.visibility_range_end_margin = 25.0
		mm_r_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_r_inst)
		
	# 3. Alpine Forest Grass & Bushes
	if mesh_grass:
		var g_count = 36
		var mm_g = MultiMesh.new()
		mm_g.transform_format = MultiMesh.TRANSFORM_3D
		mm_g.mesh = mesh_grass
		mm_g.instance_count = g_count
		for i in range(g_count):
			var lx = fmod(8.0 + (i * 19.0), size - 16.0) + 8.0
			var lz = fmod(12.0 + (i * 27.0), size - 16.0) + 12.0
			var wy = OpenWorldConfig.get_terrain_height(ox + lx, oz + lz)
			var s = 2.0 + fmod(i * 0.2, 0.8)
			var rot = (i * 43.0) * PI / 180.0
			var basis = Basis(Vector3.UP, rot).scaled(Vector3(s, s, s))
			mm_g.set_instance_transform(i, Transform3D(basis, Vector3(lx, wy, lz)))
		var mm_g_inst = MultiMeshInstance3D.new()
		mm_g_inst.multimesh = mm_g
		mm_g_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mm_g_inst.visibility_range_end = 55.0
		mm_g_inst.visibility_range_end_margin = 8.0
		mm_g_inst.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		chunk_node.add_child(mm_g_inst)

static func _add_box_collider_to_chunk(chunk_node: Node3D, pos: Vector3, size: Vector3):
	var sb = StaticBody3D.new()
	sb.collision_layer = 1
	var col = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = size
	col.shape = bshape
	col.position = pos + Vector3(0.0, size.y * 0.5, 0.0)
	sb.add_child(col)
	chunk_node.add_child(sb)

static func _add_box_collider(parent: Node3D, size: Vector3, offset: Vector3):
	var sb = StaticBody3D.new()
	sb.collision_layer = 1
	var col = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = size
	col.shape = bshape
	col.position = offset
	sb.add_child(col)
	parent.add_child(sb)

static func _optimize_shop_model(shop_node: Node3D):
	if not shop_node:
		return
	for c in shop_node.find_children("*", "Light3D", true, false):
		c.queue_free()
	for c in shop_node.find_children("*", "MeshInstance3D", true, false):
		var mi = c as MeshInstance3D
		if mi:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.visibility_range_begin = 0.0
			mi.visibility_range_end = 220.0
			mi.visibility_range_end_margin = 20.0
			mi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			for s in range(mi.get_surface_override_material_count()):
				var mat = mi.get_surface_override_material(s)
				if mat is StandardMaterial3D:
					mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
			if mi.mesh:
				for s in range(mi.mesh.get_surface_count()):
					var mat = mi.mesh.surface_get_material(s)
					if mat is StandardMaterial3D:
						mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
