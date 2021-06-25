extends Camera2D

# The camera script also sucks.
#Todo:Optimize the camera script

var camera_hitbox_shape : CollisionShape2D = null
var dragging : bool = false
var mouse_relative_position : Vector2 = Vector2(0, 0)
var screensize : Vector2 = Vector2(0, 0)
var max_min_zoom := Vector2(2.5937424601, 0.38554328942953174736440364447886) # Stores the minimum and the maximum camera zoom.
var global_tl = Vector2(INF, INF)
var global_br = Vector2(-INF, -INF)

func _ready():
	screensize = get_viewport_rect().size
	camera_hitbox_shape = get_node("Static_Layer/Camera_hitbox/Camera_collision")
	camera_hitbox_shape.shape = RectangleShape2D.new()
	reposition_hitbox()
	General_Manager.connect("update_camera", self, "change_camera_limits")
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")

func reposition_hitbox():
	camera_hitbox_shape.position = get_viewport_rect().position + screensize / 2
	camera_hitbox_shape.shape.extents = screensize / 2

func _on_Camera_hitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if(event.is_action_pressed("ui_scroll_up")):
			if(zoom.x >= max_min_zoom.y):
				zoom /= 1.1
		elif(event.is_action_pressed("ui_scroll_down")):
			if(zoom.y <= max_min_zoom.x):
				zoom *= 1.1
		elif event.is_pressed():
			dragging = true
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		position -= event.relative * zoom.x
		
		if (position.x + screensize.x / 2 * zoom.x > limit_right):
			position.x = limit_right - screensize.x / 2 * zoom.x
		elif (position.x - screensize.x / 2 * zoom.x < limit_left):
			position.x = limit_left + screensize.x / 2 * zoom.x
		
		if (position.y - screensize.y / 2 * zoom.y < limit_top):
			position.y = limit_top + screensize.y / 2 * zoom.y
		elif (position.y + screensize.y / 2 * zoom.y > limit_bottom):
			position.y = limit_bottom - screensize.y / 2 * zoom.y

func change_camera_limits(pop : NN_Population):
	var tl = Vector2(INF, INF)
	var br = Vector2(-INF, -INF)
	for i in pop.pop:
		if(i.brain.bottom_right.x + i.relative_position.x > br.x):
			br.x = i.brain.bottom_right.x + i.relative_position.x
		if(i.brain.top_left.x + i.relative_position.x < tl.x):
			tl.x = i.brain.top_left.x + i.relative_position.x
		if(i.brain.bottom_right.y + i.relative_position.y > br.y):
			br.y = i.brain.bottom_right.y + i.relative_position.y
		if(i.brain.top_left.y + i.relative_position.y < tl.y):
			tl.y = i.brain.top_left.y + i.relative_position.y
	
	global_br = br
	global_tl = tl
	
	limit_left = int(global_tl.x) - (screensize.x / 4)
	limit_top = int(global_tl.y) - (screensize.y / 4)
	limit_right = int(global_br.x) + (screensize.x * 4)
	limit_bottom = int(global_br.y) + (screensize.y / 4)
	
	var screen = tl.direction_to(global_br) * tl.distance_to(global_br)
	if screen.x < screensize.x:
		limit_left -= (screensize.x - screen.x) / 2
		limit_right += (screensize.x - screen.x) / 2
	if screen.y < screensize.y:
		limit_top -= (screensize.y - screen.y) / 2
		limit_bottom += (screensize.y - screen.y) / 2

	max_min_zoom.x = (max(screen.x, screen.y) / screensize.y) / 2

func _on_viewport_size_changed():
	screensize = get_viewport_rect().size
	reposition_hitbox()

func _on_Camera_item_rect_changed():
	reposition_hitbox()
