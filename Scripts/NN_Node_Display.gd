extends Node2D

# I promise my coding will improve with time.

var ref_node : NN_Node = null
var text_label : RichTextLabel = null

var tooltip_text : String = ""
var picked : bool = false

func _ready():
	#add_child(ref_node)

	text_label = get_node("Centralizer/Num_Label")
	
	call_deferred("set_canvas_location")
	call_deferred("_render")
	call_deferred("mount_string")

func mount_string():
	tooltip_text = "Node #" + str(ref_node.number)
	tooltip_text = tooltip_text + "\nBelongs to Agent #" + str(ref_node.genome_ref.agent_ref.id)

func set_canvas_location():
	ref_node.canvas_location = position

func _render():
	if(text_label != null):
		text_label.set_bbcode("[center]Node #" + str(ref_node.number))
	if(ref_node.number == ref_node.genome_ref.bias_node):
		text_label.append_bbcode("\nBias node")
	#visible = false

func _on_Node_Collision_button_down():
	picked = true
	General_Manager.node_picked()

func _on_Node_Collision_button_up():
	picked = false

	var divisions = []
	
	divisions.resize(ref_node.genome_ref.layers)
	for i in range(divisions.size()):
		divisions[i] = Vector2((i * General_Manager.node_size.x + i * General_Manager.node_spacing.x), 0)
	
	position.x = divisions[ref_node.layer].x + ref_node.genome_ref.agent_ref.relative_position.x
	ref_node.canvas_location = position
	
	General_Manager.node_moved(ref_node.genome_ref.agent_ref.id)

func _on_Node_Collision_mouse_entered():
	General_Manager.add_tooltip(tooltip_text, ref_node.number, 0)

func _on_Node_Collision_mouse_exited():
	General_Manager.remove_tooltip(tooltip_text)

func _on_Node_Collision_gui_input(event):
	if (event is InputEventMouseMotion and picked):
		position += event.relative
		ref_node.canvas_location = position
		General_Manager.node_moved(ref_node.genome_ref.agent_ref.id)
		#_render()
	elif (event.is_action_pressed("ui_click")):
		General_Manager.element_clicked(ref_node.genome_ref, ref_node.number, 0)
