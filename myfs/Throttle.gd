class_name Throttle
extends Control

var levels = [1,0.5,0]
var cur_level_idx = 2
var cur_level = 0
var font = ThemeDB.fallback_font
var style_box
var selected_level_style_box

signal throttle_changed(level)

func _ready():
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0,0,0,0.3)
	style_box.set_corner_radius_all(10)
	
	selected_level_style_box = StyleBoxFlat.new()
	selected_level_style_box.set_corner_radius_all(12)
	selected_level_style_box.bg_color = Color.WHITE
	
	set_process_input(true)

func _input(event):
	# print(event)
	if event is InputEventScreenTouch and _is_point_inside_area(event.position): #  or event is InputEventScreenDrag:
		var level_height = size.y / len(levels)
		var level_index = floor((event.position.y - global_position.y) / level_height)
		level_index = max(0, min(len(levels) - 1, level_index))
		# print("[TT] Touch pressed at: ", event.position)
		cur_level_idx = level_index
		cur_level = levels[cur_level_idx]
		queue_redraw()
		throttle_changed.emit(cur_level)

func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y

func _process(delta):
	pass
	#if is_dragging:
	#	var direction = (joystick_position - joystick_center).normalized()
		# Use direction to move your character or perform other actions

func _draw():
	var rect = Rect2(Vector2(0,0), size)
	draw_style_box(style_box, rect)
	
	for idx in [0,1,2]:
		var level = levels[idx]
		var text = str(level * 100) + "%"
		var cell_height = size.y / len(levels)
		var levelRect = Rect2(Vector2(0, idx * cell_height), Vector2(rect.size.x, cell_height))   
		var selected = idx == cur_level_idx
		var text_color = Color.WHITE
		if selected:
			draw_style_box(selected_level_style_box, levelRect.grow(-10))
			text_color = Color.DARK_BLUE
		var font_size = 25
		draw_string(
			font, 
			Vector2(0, levelRect.position.y + font_size / 2 + cell_height / 2), 
			text, 
			HORIZONTAL_ALIGNMENT_CENTER, 
			levelRect.size.x, 
			font_size, 
			text_color
		)
			
		
		

