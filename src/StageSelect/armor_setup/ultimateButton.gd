extends VBoxContainer

var ultimate_on: bool = false

signal ultimate_activated(part_name)
signal other_activated(part_name)

onready var menu = $"../../../.."

func _ready():
	margin_left = -47.5
	margin_right = 47.5
	var head_part_container = $HeadParts
	yield(menu, "initialize")
	if head_part_container.get_child(3).visible:
		margin_left = -63
		margin_right = 63
	var all_armor_pieces = head_part_container.get_collected_armor_pieces()
	var current_armor = head_part_container.filter_parts(all_armor_pieces)
	for part in current_armor:
		if "ultimate" in part:
			ultimate_on = true
			break
		
	

func on_ultimate_activated(part_name):
	if !ultimate_on:
		ultimate_on = true
		var part_containers = get_children()
		for part_container in part_containers:
			if not part_name.get_slice("_",1) in part_container.name.to_lower():
				part_container.get_child(3).on_press()

func on_other_activated(part_name):
	if ultimate_on:
		ultimate_on = false
		var part_containers = get_children()
		for part_container in part_containers:
			var this_part = part_name.find("_")
			this_part = part_name if this_part == -1 else part_name.get_slice("_",1)
			if not this_part in part_container.name.to_lower():
				part_container.get_child(1).on_press()
