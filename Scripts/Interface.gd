extends CanvasLayer

# This is the interface script and doesn't carry a lot about the NN itself.
# Expect messy code here.
#Todo:Improve the tooltip system
var tooltip : PanelContainer = null
var tooltip_label : RichTextLabel = null
var margin_container : MarginContainer = null
var button_elements : Button = null
var tabs : TabContainer = null

var tool_scroll : ScrollContainer = null
var node_scroll : ScrollContainer = null
var conn_scroll : ScrollContainer = null

const tool_button_name_array : Array = [
	"Rand_Node"
]

const node_label_name_array : Array = [
	"Agent_ID",
	"Node_Num",
	"Layer"
]
const node_button_name_array : Array = [
	"Add_Connection",
	"Remove_Connection",
	"Crossover"
]

const conn_label_name_array : Array = [
	"Agent_ID",
	"Connection_Num",
	"Connection_Inno",
	"From_Node",
	"To_Node",
	"Weight"
]

var tool_button_array : Array = []
var node_label_array : Array = []
var node_button_array : Array = []
var conn_label_array : Array = []
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
	
	tool_scroll = get_node("Screen_Margin/Container/Tabs/Tabs/Tools/ScrollContainer")
	node_scroll = get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer")
	conn_scroll = get_node("Screen_Margin/Container/Tabs/Tabs/Connection/ScrollContainer")
	
	for i in node_label_name_array:
		node_label_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/" + i + "/Right/LblRight"))
	for i in node_button_name_array:
		node_button_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/" + i + "/Right/BtnRight"))
	
	for i in conn_label_name_array:
		conn_label_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Connection/ScrollContainer/Container/" + i + "/Right/LblRight"))
	
	for i in tool_button_name_array:
		tool_button_array.append(get_node("Screen_Margin/Container/Tabs/Tabs/Tools/ScrollContainer/Container/" + i + "/Right/MnuRight"))
	
	node_container = get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container")
	node_template = get_node("Screen_Margin/Container/Tabs/Tabs/Nodes/ScrollContainer/Container/Container_To_Clone")
	
	button_elements.visible = false
	tooltip.visible = false
	
	var pop = General_Manager.population_ref
	for i in pop.pop:
		tool_button_array[0].get_popup().add_item(str(i.id))
	tool_button_array[0].get_popup().connect("index_pressed", self, "_on_Button_Rand_Node_pressed")
	
	node_button_array[2].get_popup().connect("index_pressed", self, "_on_Button_Crossover_pressed")
	
	General_Manager.connect("change_tooltip_text", self, "change_tooltip_text")
	General_Manager.connect("show_tooltip", self, "theres_a_tooltip")
	General_Manager.connect("hide_tooltip", self, "theres_not_a_tooltip_anymore")
	General_Manager.connect("element_click", self, "update_tab_content")
	General_Manager.connect("finished_loading_NN", self, "update_tools")
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	
	_on_viewport_size_changed()

func _process(_delta):
	if(tooltip.visible == true):
		tooltip.rect_global_position = get_viewport().get_mouse_position() + Vector2(8, 8)

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
		node_label_array[0].text = str(net.agent_ref.id)
		node_label_array[1].text = str(displayed_element_number)
		node_label_array[2].text = str(ref_element.layer)
		
		node_button_array[0].get_popup().clear()
		node_button_array[1].get_popup().clear()
		node_button_array[2].get_popup().clear()
		
		var pop = General_Manager.population_ref
		
		for i in pop.pop:
			if(i.brain != net):
				node_button_array[2].get_popup().add_item(str(i.id))
		
		for i in net.nodes:
			if(i.is_connected_to(ref_element)):
				node_button_array[1].get_popup().add_item(str(i.number))
			else:
				node_button_array[0].get_popup().add_item(str(i.number))
		
		var clone = null
		for i in node_container.get_children():
			if i.name.find("delete") > 0:
				node_container.remove_child(i)
				i.queue_free()
		for i in ref_element.input_connections:
			if (i.enabled):
				clone = node_template.duplicate()
				clone.name += "delete"
				
				var label_info = clone.get_node("Left/LblLeft")
				var label_data = clone.get_node("Right/LblRight")
				
				label_info.text = "Receives input from #"
				label_data.text = str(i.from_node.number)
				
				clone.visible = true
				node_container.add_child(clone)
		for i in ref_element.output_connections:
			if (i.enabled):
				clone = node_template.duplicate()
				clone.name += "delete"
				
				var label_info = clone.get_node("Left/LblLeft")
				var label_data = clone.get_node("Right/LblRight")
				
				label_info.text = "Delivers output to #"
				label_data.text = str(i.to_node.number)
				
				clone.visible = true
				node_container.add_child(clone)
	else:
		ref_element = net.get_NN_conn(displayed_element_number)
		
		button_text += "Connection #"
		
		conn_label_array[0].text = str(net.agent_ref.id)
		conn_label_array[1].text = str(displayed_element_number)
		conn_label_array[2].text = str(ref_element.innovation)
		conn_label_array[3].text = str(ref_element.from_node.number)
		conn_label_array[4].text = str(ref_element.to_node.number)
		conn_label_array[5].text = str(ref_element.weight)
	
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
	
	call_deferred("resize_scrolls")
# Look, man, I know it looks bad
func resize_scrolls():
	call_deferred("resize_scrolls2")
# But really, this was the only solution that worked to resize a ScrollContainer
func resize_scrolls2():
	tool_scroll.rect_size = tool_scroll.get_parent_control().rect_size
	node_scroll.rect_size = node_scroll.get_parent_control().rect_size
	conn_scroll.rect_size = conn_scroll.get_parent_control().rect_size

func _on_Button_Elements_pressed(should_hide : bool, is_button : bool):
	if (((is_button) or (should_hide and not is_button)) and tabs.current_tab != 0):
		tabs.current_tab = displayed_element + 1
		tabs.visible = !tabs.visible
		tabs.get_parent().size_flags_stretch_ratio = int(tabs.visible) * 20
		tabs.get_parent().rect_min_size = int(tabs.visible) * Vector2(350, 0)
	else:
		tabs.current_tab = displayed_element + 1
		tabs.visible = true
		tabs.get_parent().size_flags_stretch_ratio = 20
		tabs.get_parent().rect_min_size = Vector2(350, 0)

func _on_Button_Tools_pressed():
	if (tabs.current_tab == 0):
		tabs.visible = !tabs.visible
		tabs.get_parent().size_flags_stretch_ratio = int(tabs.visible) * 20
		tabs.get_parent().rect_min_size = int(tabs.visible) * Vector2(350, 0)
	else:
		tabs.current_tab = 0
		tabs.visible = true
		tabs.get_parent().size_flags_stretch_ratio = 20
		tabs.get_parent().rect_min_size = Vector2(350, 0)

func _on_Button_Rand_Node_pressed(index):
	General_Manager.population_ref.pop[index].brain.add_random_node(General_Manager.population_ref.innovation_history)
	General_Manager.redraw()

func _on_Button_Add_Connection_pressed(index):
	pass

func _on_Button_Remove_Connection_pressed(index):
	pass

func _on_Button_Crossover_pressed(index):
	var pop = General_Manager.population_ref
	pop.pop.append(genome.agent_ref.crossover(General_Manager.population_ref.pop[int(node_button_array[2].get_popup().get_item_text(index))]))
	pop.add_child(General_Manager.population_ref.pop.back())
	General_Manager.add_agent()
	General_Manager.redraw()
	#General_Manager.population_ref.pop.back().brain.generate_network()
	tool_button_array[0].get_popup().clear()
	for i in pop.pop:
		tool_button_array[0].get_popup().add_item(str(i.id))
	tool_button_array[0].get_popup().rect_size.y = 200
	update_tab_content(genome, displayed_element_number, displayed_element)

func _on_Button_Rand_Agent_pressed():
	var pop = General_Manager.population_ref
	pop.add_agent()
	General_Manager.redraw()
	tool_button_array[0].get_popup().clear()
	for i in pop.pop:
		tool_button_array[0].get_popup().add_item(str(i.id))
	tool_button_array[0].get_popup().rect_size.y = 200
