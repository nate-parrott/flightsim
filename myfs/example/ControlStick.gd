class_name ControlStick
extends Control

#var joystick_area = Rect2(Vector2(0, 0), Vector2(100, 100))
#var joystick_center = Vector2(50, 50)
#var joystick_position = Vector2(50, 50)
#var is_dragging = false

var pos = Vector2(0.5, 0.5)
var drag_start_pos = null
var min_drag_dist = 40

func _ready():
	set_process_input(true)

func _input(event):
	var k = min(size.x, size.y)
	
	if event is InputEventScreenTouch:
		if event.is_pressed():
			drag_start_pos = event.position			
			# print("Touch pressed at: ", event.position)
		else:
			pos = Vector2(0.5, 0.5)
			# print("Touch released at: ", event.position)
		queue_redraw()
	elif event is InputEventScreenDrag:
		# print("Touch dragged to: ", event.position)
		var delta = Vector2(event.position.x - drag_start_pos.x, event.position.y - drag_start_pos.y)
		# Enforce min drag dist:
		if delta.x > 0:
			delta.x = max(0, delta.x - min_drag_dist)
		if delta.x < 0:
			delta.x = min(0, delta.x + min_drag_dist)
		if delta.y > 0:
			delta.y = max(0, delta.y - min_drag_dist)
		if delta.y < 0:
			delta.y = min(0, delta.y + min_drag_dist)
		pos.x = clamp((delta.x / size.x * 0.7 + 0.5), 0, 1) # Invert
		pos.y = clamp(delta.y / size.y * 1.0 + 0.5, 0, 1)
		queue_redraw()

func _process(delta):
	pass
	#if is_dragging:
	#	var direction = (joystick_position - joystick_center).normalized()
		# Use direction to move your character or perform other actions

func _draw():
	var rect = Rect2(Vector2(0, 0), size)
	# draw_rect(rect, Color(0, 0, 0, 0.5))
	var k = min(size.x, size.y)
	var wheel_size_x = k * 0.4
	var wheel_size = Vector2(wheel_size_x, wheel_size_x * 0.6)
	var wheel_center = Vector2(rect.size.x / 2, rect.size.y * remap(pos.y, 0, 1, 0.3, 0.6))
	var wheel_rect = Rect2(wheel_center.x - wheel_size.x / 2, wheel_center.y - wheel_size.y / 2, wheel_size.x, wheel_size.y)
	
	# draw_rect(wheel_rect, Color(0,0,0,0.5))
	
	var wheel_rotation = deg_to_rad(remap(pos.x, 0, 1, -30, 30))
	var wheel_scale = remap(pos.y, 0, 1, 0.9, 1.3)
	
	# Draw W shape centered at wheel_size
	var base_shape = [
		# Outside from top left
		[0, 0],
		[0.1, 1],
		# Center square (bottom)
		[0.4, 0.6],
		[0.45, 0.6],
		[], # Stem will be inserted here (these points are handled differently)
		[0.55, 0.6],
		[0.6, 0.6],
		[0.9, 1],
		[1, 0],
		## Top right, now doing inside
		[0.9, 0],
		[0.8, 0.6],
		## Center square (top)
		[0.6, 0.4],
		[0.6, 0.2],
		[0.4, 0.2],
		[0.4, 0.4],
		[0.2, 0.6],
		[0.1, 0],
		[0, 0]
	]
	# base_shape.reverse()
	var final_points = []
	for base_pt in base_shape:
		if len(base_pt) == 0:
			# Insert stem
			var stem_w = k * 0.05
			final_points.append(Vector2(wheel_center.x - stem_w/2, rect.size.y))
			final_points.append(Vector2(wheel_center.x + stem_w/2, rect.size.y))
		else:
			var x = remap(base_pt[0], 0, 1, wheel_rect.position.x, wheel_rect.position.x + wheel_rect.size.x)
			var y = remap(base_pt[1], 0, 1, wheel_rect.position.y, wheel_rect.position.y + wheel_rect.size.y)
			var pt = Vector2(x, y)
			pt = rotate_point(pt, wheel_center, wheel_rotation)
			pt = scale_point(pt, wheel_center, wheel_scale)
			final_points.append(pt)
	draw_polygon(final_points, [Color(0,0,0,0.2)])
	draw_polyline(final_points, Color(1,1,1,0.7))

	# Draw bounds
	# draw_polyline([Vector2(3,3), Vector2(3, size.x - 3), Vector2(size.x - 3,size.y - 3), Vector2(size.x - 3, 3), Vector2(3,3)], Color(1,0,0,1))
	
	#draw_rect(joystick_area, Color(0, 0, 0, 0.5))
	#draw_circle(joystick_center, 10, Color(1, 1, 1))
	#draw_circle(joystick_position, 5, Color(1, 0, 0))
	
	#var stem_w_top = k * 0.1
	#var stem_w_bottom = k * 0.07
	#var stem_shape = [
		#Vector2(wheel_center.x - stem_w_top / 2, wheel_center.y),
		#Vector2(wheel_center.x + stem_w_top / 2, wheel_center.y),
		#Vector2(wheel_center.x + stem_w_top / 2, rect.size.y),
		#Vector2(wheel_center.x - stem_w_top / 2, rect.size.y),
	#]
	#draw_polygon(stem_shape, [Color(0,1,0,1)])


func rotate_point(point: Vector2, center: Vector2, angle: float) -> Vector2:
	var translated_point = point - center
	var rotated_x = translated_point.x * cos(angle) - translated_point.y * sin(angle)
	var rotated_y = translated_point.x * sin(angle) + translated_point.y * cos(angle)
	var rotated_point = Vector2(rotated_x, rotated_y) + center
	return rotated_point

func scale_point(point: Vector2, center: Vector2, scale: float) -> Vector2:
	var translated_point = point - center
	var scaled_point = translated_point * scale
	var final_point = scaled_point + center
	return final_point
