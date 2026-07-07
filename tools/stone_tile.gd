class_name StoneTile
extends RefCounted

## Shared draw helper that renders a grid cell as a rounded, beveled "stone"
## instead of a flat rect. Used by the card builder's workbench grid and its
## component pieces until real art replaces them.

var _shadow_style := StyleBoxFlat.new()
var _body_style := StyleBoxFlat.new()
var _highlight_style := StyleBoxFlat.new()
var _socket_style := StyleBoxFlat.new()
var _socket_shadow_style := StyleBoxFlat.new()
var _warning_style := StyleBoxFlat.new()

func _init() -> void:
	_body_style.border_width_left = 2
	_body_style.border_width_top = 2
	_body_style.border_width_right = 2
	_body_style.border_width_bottom = 2
	_socket_style.border_width_left = 2
	_socket_style.border_width_top = 2
	_socket_style.border_width_right = 2
	_socket_style.border_width_bottom = 2
	_warning_style.border_width_left = 2
	_warning_style.border_width_top = 2
	_warning_style.border_width_right = 2
	_warning_style.border_width_bottom = 2

## A raised, polished stone: drop shadow beneath, bordered body, glossy
## highlight along the top. Used for held/placed components.
func draw(node: CanvasItem, rect: Rect2, base_color: Color, inset: float = 1.5) -> void:
	if base_color.a <= 0.0:
		return
	var tile_rect := rect.grow(-inset)
	if tile_rect.size.x <= 0 or tile_rect.size.y <= 0:
		return
	var corner_radius := clampi(int(min(tile_rect.size.x, tile_rect.size.y) * 0.18), 2, 20)

	_shadow_style.set_corner_radius_all(corner_radius)
	_shadow_style.bg_color = Color(0, 0, 0, 0.35)
	node.draw_style_box(_shadow_style, Rect2(tile_rect.position + Vector2(0, 2), tile_rect.size))

	_body_style.set_corner_radius_all(corner_radius)
	_body_style.bg_color = base_color
	_body_style.border_color = base_color.darkened(0.45)
	node.draw_style_box(_body_style, tile_rect)

	var highlight_rect := Rect2(
		tile_rect.position + Vector2(2, 2),
		Vector2(maxf(tile_rect.size.x - 4.0, 0.0), maxf(tile_rect.size.y * 0.42 - 2.0, 0.0))
	)
	if highlight_rect.size.x > 0 and highlight_rect.size.y > 0:
		_highlight_style.corner_radius_top_left = corner_radius
		_highlight_style.corner_radius_top_right = corner_radius
		_highlight_style.bg_color = Color(base_color.lightened(0.4), base_color.a * 0.4)
		node.draw_style_box(_highlight_style, highlight_rect)

## An empty, carved-in socket: darker recessed body with an inner shadow
## along the top edge. Used for open workbench cells waiting for a stone.
## connect_* marks which sides touch another buildable cell - those edges
## are drawn flush (no gap, no rounded corner) so adjoining sockets read as
## one continuous carved surface instead of separate floating tiles, and
## only the outer silhouette of the workbench stays rounded.
func draw_socket(node: CanvasItem, rect: Rect2, base_color: Color,
		connect_left: bool = false, connect_right: bool = false,
		connect_top: bool = false, connect_bottom: bool = false,
		inset: float = 2.0) -> void:
	if base_color.a <= 0.0:
		return
	var left := rect.position.x + (0.0 if connect_left else inset)
	var top := rect.position.y + (0.0 if connect_top else inset)
	var right := rect.position.x + rect.size.x - (0.0 if connect_right else inset)
	var bottom := rect.position.y + rect.size.y - (0.0 if connect_bottom else inset)
	var tile_rect := Rect2(Vector2(left, top), Vector2(right - left, bottom - top))
	if tile_rect.size.x <= 0 or tile_rect.size.y <= 0:
		return
	var corner_radius := clampi(int(min(rect.size.x, rect.size.y) * 0.18), 2, 20)
	var radius_tl := 0 if (connect_left or connect_top) else corner_radius
	var radius_tr := 0 if (connect_right or connect_top) else corner_radius
	var radius_bl := 0 if (connect_left or connect_bottom) else corner_radius
	var radius_br := 0 if (connect_right or connect_bottom) else corner_radius

	_socket_style.corner_radius_top_left = radius_tl
	_socket_style.corner_radius_top_right = radius_tr
	_socket_style.corner_radius_bottom_left = radius_bl
	_socket_style.corner_radius_bottom_right = radius_br
	_socket_style.bg_color = base_color.darkened(0.15)
	_socket_style.border_color = base_color.darkened(0.55)
	node.draw_style_box(_socket_style, tile_rect)

	var inner_shadow_rect := Rect2(
		tile_rect.position + Vector2(2, 2),
		Vector2(maxf(tile_rect.size.x - 4.0, 0.0), maxf(tile_rect.size.y * 0.35, 0.0))
	)
	if inner_shadow_rect.size.x > 0 and inner_shadow_rect.size.y > 0:
		_socket_shadow_style.corner_radius_top_left = radius_tl
		_socket_shadow_style.corner_radius_top_right = radius_tr
		_socket_shadow_style.bg_color = Color(0, 0, 0, 0.28)
		node.draw_style_box(_socket_shadow_style, inner_shadow_rect)

## A red warning overlay with an X, drawn on top of a stone that a piece
## being placed is currently overlapping. Purely a placement hint.
func draw_overlap_warning(node: CanvasItem, rect: Rect2, inset: float = 1.5) -> void:
	var tile_rect := rect.grow(-inset)
	if tile_rect.size.x <= 0 or tile_rect.size.y <= 0:
		return
	var corner_radius := clampi(int(min(tile_rect.size.x, tile_rect.size.y) * 0.18), 2, 20)

	_warning_style.set_corner_radius_all(corner_radius)
	_warning_style.bg_color = Color(0.9, 0.15, 0.15, 0.55)
	_warning_style.border_color = Color(1, 0.2, 0.2, 0.9)
	node.draw_style_box(_warning_style, tile_rect)

	var pad := tile_rect.size * 0.22
	var top_left := tile_rect.position + pad
	var bottom_right := tile_rect.position + tile_rect.size - pad
	var top_right := Vector2(bottom_right.x, top_left.y)
	var bottom_left := Vector2(top_left.x, bottom_right.y)
	var line_width := maxf(tile_rect.size.x * 0.12, 3.0)
	node.draw_line(top_left, bottom_right, Color(1, 1, 1, 0.95), line_width, true)
	node.draw_line(top_right, bottom_left, Color(1, 1, 1, 0.95), line_width, true)
