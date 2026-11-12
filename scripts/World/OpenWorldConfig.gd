# OpenWorldConfig.gd
# AGENT 1: WORLD ARCHITECT & ARCHITECTURE DEFINITIONS
# Coordinates, chunk boundaries, regions, and deterministic terrain elevation.
class_name OpenWorldConfig
extends RefCounted

const CHUNK_SIZE: float = 128.0
const CHUNK_RESOLUTION: int = 16 # 16x16 quads per chunk (optimized for 60 FPS on 4GB RAM)
const ACTIVE_CHUNK_RADIUS: int = 1 # 3x3 active grid (9 chunks total)

enum RegionType {
	CITY_DOWNTOWN,
	CITY_EAST,
	SUBURBS,
	COUNTRYSIDE,
	MOUNTAIN,
	COASTAL,
	INDUSTRIAL
}

static func get_region_for_chunk(cx: int, cz: int) -> int:
	if cz < 0:
		return RegionType.MOUNTAIN
	elif cx < 0:
		return RegionType.COUNTRYSIDE
	elif cz > 0:
		if cx > 0:
			return RegionType.INDUSTRIAL
		else:
			return RegionType.SUBURBS
	else:
		if cx == 0:
			return RegionType.CITY_DOWNTOWN
		else:
			return RegionType.CITY_EAST

static func get_terrain_height(wx: float, wz: float) -> float:
	var h: float = 0.0
	
	# 1. Smooth North Mountains (starts tapering gently from wz < -10.0 into -100.0)
	var m_factor: float = 0.0
	if wz < -10.0:
		var t_m = clamp((-wz - 10.0) / 80.0, 0.0, 1.0)
		m_factor = t_m * t_m * (3.0 - 2.0 * t_m) # Hermite smoothstep
		var m_noise = sin(wx * 0.022) * 12.0 + cos(wz * 0.028) * 16.0 + sin((wx * 0.035 + wz * 0.035)) * 6.0
		h += (20.0 + m_noise) * m_factor
		
	# 2. Smooth West Countryside Rolling Hills (starts tapering gently from wx < -10.0)
	var c_factor: float = 0.0
	if wx < -10.0:
		var t_c = clamp((-wx - 10.0) / 70.0, 0.0, 1.0)
		c_factor = t_c * t_c * (3.0 - 2.0 * t_c) # Hermite smoothstep
		var c_noise = sin(wx * 0.028) * 5.0 + cos(wz * 0.032) * 4.0
		var hill_weight = 1.0 - (m_factor * 0.5)
		h += (6.0 + c_noise) * c_factor * hill_weight
		
	# 3. South-East Coast depression (wx > 160.0 and wz > 160.0)
	if wx > 160.0 and wz > 160.0:
		var s_dist = ((wx - 160.0) + (wz - 160.0)) * 0.5
		var t_coast = clamp(s_dist * 0.05, 0.0, 3.5)
		h -= t_coast
	else:
		# Downtown and Suburbs subtle natural ground undulation
		var base_h = sin(wx * 0.018) * 0.18 + cos(wz * 0.018) * 0.18
		h += base_h * (1.0 - clamp(m_factor + c_factor, 0.0, 1.0))
		
	# Flatten and recess terrain smoothly under main East-West Highway corridor (wz near 64.0)
	var dist_ew = abs(wz - 64.0)
	if dist_ew < 12.0:
		h = -0.05
	elif dist_ew < 18.0:
		var b_ew = (dist_ew - 12.0) / 6.0
		b_ew = b_ew * b_ew * (3.0 - 2.0 * b_ew)
		h = lerp(-0.05, h, b_ew)
		
	# Flatten and recess terrain smoothly under main North-South Avenue corridor (wx near 64.0)
	var dist_ns = abs(wx - 64.0)
	if dist_ns < 12.0:
		h = -0.05
	elif dist_ns < 18.0:
		var b_ns = (dist_ns - 12.0) / 6.0
		b_ns = b_ns * b_ns * (3.0 - 2.0 * b_ns)
		h = lerp(-0.05, h, b_ns)
		
	return h

static func world_to_chunk_coord(pos: Vector3) -> Vector2i:
	var cx = int(floor(pos.x / CHUNK_SIZE))
	var cz = int(floor(pos.z / CHUNK_SIZE))
	return Vector2i(cx, cz)
