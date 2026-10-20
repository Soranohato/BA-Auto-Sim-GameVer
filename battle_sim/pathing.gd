
class_name Pathing
extends RefCounted

const NODE_MARGIN := 0.03
const MIN_WAYPOINT_DIST := 0.01

# distance from p to square (0 if inside)
static func dist_to_square(p: Vector2, center: Vector2, half: float) -> float:
	var q:= (p - center).abs() - Vector2(half, half)
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
	
static func segment_hits_square(a: Vector2, b: Vector2, center: Vector2, half: float) -> bool:
	return _seg_hits_rect(a, b, center, half, half)
	
static func _seg_hits_rect(a: Vector2, b: Vector2, center: Vector2, hx: float, hy: float) -> bool:
	var d := b - a
	var ext := Vector2(hx, hy)
	var t_min := 0.0
	var t_max := 1.0
	for axis in 2:
		var low: float = center[axis] - ext[axis]
		var high: float = center[axis] + ext[axis]
		if absf(d[axis]) < 0.00001:
			# Parallel to this axis: it can only hit if it lies inside the slab
			if a[axis] <= low or a[axis] >= high:
				return false
		else:
			var t1: float = (low - a[axis]) / d[axis]
			var t2: float = (high - a[axis]) / d[axis]
			t_min = maxf(t_min, minf(t1, t2))
			t_max = minf(t_max, maxf(t1, t2))
			if t_min >= t_max:
				return false
	return true
	
static func _blocked(a: Vector2, b: Vector2, centers: Array[Vector2],
		half: float, radius: float) -> bool:
	for c in centers:
		if _seg_hits_rect(a, b, c, half + radius, half):
			return true
		if _seg_hits_rect(a, b, c, half, half + radius):
			return true
			
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var corner: Vector2 = c + Vector2(sx, sy) * half
				if Geometry2D.get_closest_point_to_segment(corner, a, b).distance_to(corner) < radius:
					return true
					
	return false

static func _sign(v: float) -> float:
	return 1.0 if v >= 0.0 else -1.0

# If p is inside an obstacle's keep-out zone, returns the nearest point just
# outside it, otherwise returns p unchanged
static func _push_out(p: Vector2, centers: Array[Vector2], half: float, radius: float) -> Vector2:
	for c in centers:
		if dist_to_square(p, c, half) >= radius:
			continue
		var q := p - c
		var nearest := Vector2(clampf(q.x, -half, half), clampf(q.y, -half, half))
		var away := q - nearest
		if away.length_squared() < 0.000001:
			# p is inside the square itself: leave through the closest face
			if absf(q.x) >= absf(q.y):
				nearest = Vector2(_sign(q.x) * half, q.y)
				away = Vector2(_sign(q.x), 0.0)
			else:
				nearest = Vector2(q.x, _sign(q.y) * half)
				away = Vector2(0.0, _sign(q.y))
		return c + nearest + away.normalized() * (radius + NODE_MARGIN)
	return p

static func next_waypoint(from: Vector2, to: Vector2, centers: Array[Vector2],
		half: float, radius: float, bounds: Rect2) -> Vector2:
	# Repair: if we're already inside an obstacle's keep-out zone, walk straight out
	var out := _push_out(from, centers, half, radius)
	if out != from:
		return out
	# A goal inside a zone can't be reached, aim at the nearest point outside it
	var goal := _push_out(to, centers, half, radius)

	if not _blocked(from, goal, centers, half, radius):
		return goal

	# Nodes: 0 = start, 1 = goal, then one per usable obstacle corner
	var nodes: Array[Vector2] = [from, goal]
	var corner_offset := half + radius + NODE_MARGIN
	for c in centers:
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var p: Vector2 = c + Vector2(sx, sy) * corner_offset
				if not bounds.has_point(p):
					continue
				var inside_other := false
				for o in centers:
					if dist_to_square(p, o, half) < radius:
						inside_other = true
						break
				if not inside_other:
					nodes.append(p)

	# Dijkstra
	var n := nodes.size()
	var dist := PackedFloat64Array()
	dist.resize(n)
	dist.fill(INF)
	var prev := PackedInt32Array()
	prev.resize(n)
	prev.fill(-1)
	var done := PackedByteArray()
	done.resize(n)
	dist[0] = 0.0

	for _iter in range(n):
		var u := -1
		var best := INF
		for i in range(n):
			if done[i] == 0 and dist[i] < best:
				best = dist[i]
				u = i
		if u == -1 or u == 1:
			break
		done[u] = 1
		for v in range(n):
			if done[v] == 1:
				continue
			var w := nodes[u].distance_to(nodes[v])
			if dist[u] + w >= dist[v]:
				continue
			if _blocked(nodes[u], nodes[v], centers, half, radius):
				continue
			dist[v] = dist[u] + w
			prev[v] = u

	if prev[1] == -1:
		push_error("Pathing: no path from %s to %s, moving straight" % [from, goal])
		return goal

	var path: Array[int] = []
	var cur := 1
	while cur != 0:
		path.push_front(cur)
		cur = prev[cur]
	for idx in path:
		if from.distance_to(nodes[idx]) > MIN_WAYPOINT_DIST:
			return nodes[idx]
	return goal
