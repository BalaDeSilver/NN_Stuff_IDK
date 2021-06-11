extends CanvasLayer

var tooltip : PanelContainer = null
var tooltip_label : RichTextLabel = null
var margin_container : MarginContainer = null
var button_elements : Button = null
var tabs : TabContainer = null

const label_name_array : Array = [
	"Network_ID",
	"Node_Num",
	"Layer"
]
const button_name_array : Array = [
	"Add_Connection",
	"Remove_Connection"
]

var label_array : Array = []
var button_array : Array = []
var network_list : Array = []

var displayed_element : int = -1
var displayed_element_number : int = -1
var displayed_network : int = -1

var node_container : VBoxContainer = null
var node_template : HBoxContainer = null

var genome : NN_Genome = null

func _ready():
	tooltip = get_node("Hover_Tooltip")
	tooltip_label = get_node("Hover_Tooltip/Tooltip_Label")
	margin_container = get_node("Screen_Margin")
	button_elements = get_node("Screen_Margin/Container/Buttons/Elements/Button_Elements")
	tabs = get_node("Screen_Margin/Container/Tabs/Tabs")
	
	for i in label_name_array:
		label_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/" + i + "/Right/LblRight"))
	for i in button_name_array:
		button_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/" + i + "/Left/BtnLeft"))
	
	node_container = get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container")
	node_template = get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/Container_To_Clone")
	
	button_elements.visible = false
	tooltip.visible = false
	
	General_Manager.connect("change_tooltip_text", self, "change_tooltip_text")
	General_Manager.connect("show_tooltip", self, "theres_a_tooltip")
	General_Manager.connect("hide_tooltip", self, "theres_not_a_tooltip_anymore")
	General_Manager.connect("element_click", self, "update_tab_content")
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	General_Manager.connect("finished_loading_NN", self, "update_tools")
	_on_viewport_size_changed()

func _process(_delta):
	if(tooltip.visible == true):
		tooltip.rect_global_position = get_viewport().get_mouse_position() + Vector2(8, 8)

func update_tools():
	var ref = General_Manager.population_ref
	network_list.resize(ref.pop.size())
	for i in range(ref.pop.size()):
		network_list[i] = Button.new()
		if ref[i].agent_name == "":
			network_list[i].name = "Btn_Network_" + ref[i].id
		else:
			network_list[i].name = "Btn_Network_" + ref[i].agent_name

func update_tab_content(net : NN_Genome, num : int, ele : int):
	_on_Button_Elements_pressed((ele == displayed_element and net.agent_ref.id == displayed_network and num == displayed_element_number), false)
	
	genome = net
	
	tabs.current_tab = ele + 1
	
	displayed_network = net.agent_ref.id
	displayed_element = ele
	displayed_element_number = num
	
	var ref_element = null
	var button_text = ""
	
	if(displayed_element == 0):
		ref_element = net.get_NN_node(displayed_element_number)
		
		button_text += "Node #"
		label_array[0].text = str(net.agent_ref.id)
		label_array[1].text = str(displayed_element_number)
		label_array[2].text = str(ref_element.layer)
		
		var clone = null
		for i in node_container.get_children():
			if i.name.find("delete") > 0:
				node_container.remove_child(i)
				i.queue_free()
		for i in ref_element.output_connections:
			clone = node_template.duplicate()
			clone.name += "delete"
			
			var label_info = clone.get_node("Left/LblLeft")
			var label_data = clone.get_node("Right/LblRight")
			
			label_info.text = "Connected to Node #"
			label_data.text = str(i.to_node.number)
			
			clone.visible = true
			node_container.add_child(clone)
	else:
		
		
		button_text += "Connection #"
	
	button_elements.visible = true
	button_elements.text = button_text + str(num)

func theres_a_tooltip():
	tooltip.visible = true

func theres_not_a_tooltip_anymore():
	tooltip.visible = false

func change_tooltip_text(text : String):
	tooltip_label.set_bbcode(text)

func _on_viewport_size_changed():
	margin_container.rect_position = Vector2(0,0)
	margin_container.rect_size = General_Manager.get_viewport_rect().size
	
	for i in margin_container.get_children():
		i.visible = false
		i.call_deferred("set_visible", true)

func _on_Button_Elements_pressed(should_hide : bool, is_button : bool):
	if (((is_button) or (should_hide and not is_button)) and tabs.current_tab != 0):
		tabs.current_tab = displayed_element + 1
		tabs.visible = !tabs.visible
		tabs.get_parent().size_flags_stretch_ratio = int(tabs.visible) * 20
	else:
		tabs.current_tab = displayed_element + 1
		tabs.visible = true
		tabs.get_parent().size_flags_stretch_ratio = 20

func _on_Button_Tools_pressed():
	if (tabs.current_tab == 0):
		tabs.visible = !tabs.visible
		tabs.get_parent().size_flags_stretch_ratio = int(tabs.visible) * 20
	else:
		tabs.current_tab = 0
	pass

func _on_Btn_Rand_Node_pressed():
	var new_display_node = preload("res://Scenes/NN_Node_Display.tscn").instance()
	var new_node = genome.add_random_node(genome.agent_ref.pop_ref.innovation_history)
	new_display_node.ref_node = new_node
	genome.get_parent().add_child(new_display_node)
	General_Manager.redraw()
