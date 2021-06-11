extends Node2D

var ref_connection : NN_Connection = null
var connection_render : Line2D = null
var connection_collision : CollisionShape2D = null

var tooltip_text : String = ""

const width_range : Array = [1, 5]

const color_pos = Color.green
const color_neg = Color.red
const color_neu = Color.yellow

func _ready():
	connection_render = get_node("Connection")
	connection_collision = get_node("Connection/Connection_Mouse_Hover/Mouse_Hover_Shape")
	connection_collision.shape = RectangleShape2D.new()
	
	General_Manager.connect("rerender", self, "should_rerender")
	
	call_deferred("mount_string")
	call_deferred("_render")

func mount_string():
	tooltip_text += "Connection #" + str(ref_connection.number) + "\nFrom node #" + str(ref_connection.from_node.number) + "\nTo node #" + str(ref_connection.to_node.number) + "\nWeight :" + str(ref_connection.weight) + "\nBelongs to agent #" + str(ref_connection.genome_ref.agent_ref.id)

func _render():
	connection_render.clear_points()
	if(ref_connection.enabled):
		var point_a = ref_connection.from_node.canvas_location + Vector2(64, 64)
		var point_b = ref_connection.to_node.canvas_location + Vector2(64, 64)

		connection_render.add_point(point_a)
		connection_render.add_point(point_b)
		
		var hitbox_width = 5
		var angel = 0
		if(point_a.x == point_b.x):
			angel = deg2rad(90)
		else:
			angel = atan((point_b.y - point_a.y) / (point_b.x - point_a.x))
		var hitbox_length = (sqrt(pow((point_a.x - point_b.x), 2) + pow((point_a.y - point_b.y), 2)) / 2) - 64
		
		connection_collision.position = (point_a + point_b) / 2
		connection_collision.rotation = angel
		connection_collision.shape.extents = Vector2(hitbox_length, hitbox_width)
		
		connection_render.width = lerp(width_range[0], width_range[1], abs(ref_connection.weight))
		
		if(ref_connection.weight > 0):
			connection_render.default_color = color_neu.linear_interpolate(color_pos, abs(ref_connection.weight))
		else:
			connection_render.default_color = color_neu.linear_interpolate(color_neg, abs(ref_connection.weight))
	else:
		visible = false

func should_rerender(agent_id):
	if(ref_connection.genome_ref.agent_ref.id == agent_id):
		_render()

func _on_Connection_Mouse_Hover_mouse_entered():
	General_Manager.add_tooltip(tooltip_text, ref_connection.number, 1)

func _on_Connection_Mouse_Hover_mouse_exited():
	General_Manager.remove_tooltip(tooltip_text)

func _on_Connection_Mouse_Hover_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_click"):
		General_Manager.element_clicked(ref_connection.genome_ref, ref_connection.number, 1)
