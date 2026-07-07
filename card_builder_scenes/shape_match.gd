class_name ShapeMatch
extends RefCounted

## Utilities for comparing a component's shape against a hand-drawn pattern,
## accounting for the 4 possible 90-degree rotations of the pattern.

static func filled_cells(shape: Array) -> Array:
	var cells: Array = []
	for y in shape.size():
		var row = shape[y]
		for x in row.size():
			if row[x] != 0:
				cells.append(Vector2i(x, y))
	return cells

## Translates cells so the top-left of their bounding box sits at (0,0),
## then sorts them into a canonical order so two equal shapes always
## produce equal arrays.
static func normalize_cells(cells: Array) -> Array:
	if cells.is_empty():
		return []
	var min_x = cells[0].x
	var min_y = cells[0].y
	for c in cells:
		min_x = min(min_x, c.x)
		min_y = min(min_y, c.y)
	var normalized: Array = []
	for c in cells:
		normalized.append(Vector2i(c.x - min_x, c.y - min_y))
	normalized.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
	return normalized

static func rotate_cells_90(cells: Array) -> Array:
	var rotated: Array = []
	for c in cells:
		rotated.append(Vector2i(c.y, -c.x))
	return normalize_cells(rotated)

static func cells_equal(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if a[i] != b[i]:
			return false
	return true

## True if shape_cells matches pattern_cells under any of the 4 rotations.
## Both are normalized to their own bounding box first, so position and
## overall grid size don't matter - only the outline shape does.
static func matches_with_rotation(pattern_cells: Array, shape_cells: Array) -> bool:
	if pattern_cells.is_empty() or shape_cells.is_empty():
		return false
	var target := normalize_cells(shape_cells)
	var rotated := normalize_cells(pattern_cells)
	for i in 4:
		if cells_equal(rotated, target):
			return true
		rotated = rotate_cells_90(rotated)
	return false
