extends Camera2D

var camera_hitbox_shape : CollisionShape2D = null
var dragging : bool = false
var mouse_relative_position : Vector2 = Vector2(0, 0)
var screensize : Vector2 = Vector2(0, 0)

func _init():
	General_Manager.camera = self

func _ready():
	screensize = get_viewport_rect().size
	camera_hitbox_shape = get_node("Static_Layer/Camera_hitbox/Camera_collision")
	camera_hitbox_shape.shape = RectangleShape2D.new()
	reposition_hitbox()
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")

func reposition_hitbox():
	camera_hitbox_shape.position = get_viewport_rect().position + screensize / 2
	camera_hitbox_shape.shape.extents = screensize / 2

func _on_Camera_hitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if(event.is_action_pressed("ui_scroll_up")):
			zoom /= 1.1
		elif(event.is_action_pressed("ui_scroll_down")):
			zoom *= 1.1
		elif event.is_pressed():
			dragging = true
		else:
			dragging = false
		
		if (zoom.x > 2.5937424601):
			zoom = Vector2(2.5937424601, 2.5937424601)
		elif (zoom.x < 0.38554328942953174736440364447886):
			zoom = Vector2(0.38554328942953174736440364447886, 0.38554328942953174736440364447886)
	
	elif event is InputEventMouseMotion and dragging:
		position -= event.relative * zoom.x
		
		if (position.x - screensize.x / 2 * zoom.x < limit_left):
			position.x = limit_left + screensize.x / 2 * zoom.x
		elif (position.x + screensize.x / 2 * zoom.x > limit_right):
			position.x = limit_right - screensize.x / 2 * zoom.x
		
		if (position.y - screensize.y / 2 * zoom.y < limit_top):
			position.y = limit_top + screensize.y / 2 * zoom.y
		elif (position.y + screensize.y / 2 * zoom.y > limit_bottom):
			position.y = limit_bottom - screensize.y / 2 * zoom.y

func _on_viewport_size_changed():
	screensize = get_viewport_rect().size
	reposition_hitbox()

func _on_Camera_item_rect_changed():
	reposition_hitbox()
