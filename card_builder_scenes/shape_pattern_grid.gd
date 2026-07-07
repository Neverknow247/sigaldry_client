extends Control

const GRID_SIZE = 5
var cell_size = 24.0
var pattern: Array = []

var stone_tile := StoneTile.new()

signal pattern_changed(cells)

func _ready() -> void:
	_clear_pattern()

## Clears the pattern and notifies listeners. Used when the player right-
## clicks, presses Clear, or a new card is started - not during _ready(),
## since at that point our own parent's @onready vars may not be set up
## yet (children ready before parents), and emitting here would call into
## them too early.
func reset_pattern() -> void:
	_clear_pattern()
	pattern_changed.emit(get_filled_cells())

func _clear_pattern() -> void:
	pattern.clear()
	for y in GRID_SIZE:
		var row = []
		for x in GRID_SIZE:
			row.append(0)
		pattern.append(row)
	queue_redraw()

func get_filled_cells() -> Array:
	var cells: Array = []
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			if pattern[y][x] != 0:
				cells.append(Vector2i(x, y))
	return cells

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var cell := Vector2i((event.position / cell_size).floor())
		if cell.x < 0 or cell.x >= GRID_SIZE or cell.y < 0 or cell.y >= GRID_SIZE:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			pattern[cell.y][cell.x] = 0 if pattern[cell.y][cell.x] != 0 else 1
			queue_redraw()
			pattern_changed.emit(get_filled_cells())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			reset_pattern()

func _draw() -> void:
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var rect := Rect2(Vector2(x, y) * cell_size, Vector2(cell_size, cell_size))
			if pattern[y][x] != 0:
				stone_tile.draw(self, rect, Color("#f2ab37"))
			else:
				var connect_left = x > 0
				var connect_right = x < GRID_SIZE - 1
				var connect_top = y > 0
				var connect_bottom = y < GRID_SIZE - 1
				stone_tile.draw_socket(self, rect, Color("#3a3d42"), connect_left, connect_right, connect_top, connect_bottom)
