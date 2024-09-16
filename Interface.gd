extends Control

var start_timer:bool = false
var run_ended:bool = false
var loaded:bool = false
var dragging:bool = false
var title_click:bool = false
var time: String = ""
var shown_splits: int = 6
var summofbest = 0
var current_split: int = 0
var click_pos = Vector2.ZERO
var current_split_theme = load("res://outliner.tres")
var sec: float = 0
var mins: int = 0
var hours: int = 0
var delta_time: Array = [0, 0, 0]
var total_time: Array = [0, 0, 0]
var compare_split: Array = [0, 0, 0]
var title: String = ""

@onready var splitters = $ScrollContainer/Splits


var yellow = Color(1.0,1.0,0.0,1.0)
var white = Color(1.0,1.0,1.0,1.0)
var red = Color(1.0,0.0,0.0,1.0)
var green = Color(0.2, 0.7, 0.4)


@onready var saveDiag = $Save_diag
@onready var loadDiag = $Load_diag
@onready var options = $Options
@onready var timer = $Timer/Time

var order: Dictionary = {}

var splits_dict: Dictionary = {
	"Split1": ["Tanglewood", false, [0, 0, 0], [0, 0, 0]],
	"Split2": ["Edgefild", false, [0, 0, 0], [0, 0, 0]],
	"Split3": ["Ridgeview", false, [0, 0, 0], [0, 0, 0]],
	"Split4": ["Willow", false, [0, 0, 0], [0, 0, 0]],
	"Split5": ["Woodwind", false, [0, 0, 0], [0, 0, 0]],
	"Split6": ["Maple", false, [0, 0, 0], [0, 0, 0]],
	"Split7": ["Prison", false, [0, 0, 0], [0, 0, 0]],
	"Split8": ["Sunny Meadows", false, [0, 0, 0], [0, 0, 0]],
	"Split9": ["High School", false, [0, 0, 0], [0, 0, 0]],
	"Split10": ["Bleasdale", false, [0, 0, 0], [0, 0, 0]],
	"Split11": ["Grafton", false, [0, 0, 0], [0, 0, 0]],
	"Split12": ["Point Hope", false, [0, 0, 0], [0, 0, 0]],
}

func fill_splits():
	current_split = 0
	for child in splitters.get_children():
		child.get_child(0).label_settings.font_color = white
		child.remove_theme_stylebox_override("normal")
		child.set_text(splits_dict[child.name][0])
		child.get_child(0).set_text("")
		if order != {}:
			splitters.move_child(splitters.get_child(child.get_index()), order[child.text])
			if order[child.text] < shown_splits:
				child.show()
		if child.get_index() > shown_splits -1:
			child.hide()
		if splits_dict[child.name][3][2] != 0:
			total_time[0] += splits_dict[child.name][3][0]
			total_time[1] += splits_dict[child.name][3][1]
			total_time[2] += splits_dict[child.name][3][2]
			if total_time[2] >= 60:
				total_time[2] -= 60
				total_time[1] += 1
			if total_time[1] >= 60:
				total_time[1] -= 60
				total_time[0] += 1
			if total_time[0] == 0:
				child.get_child(0).set_text(str("%0*d" % [1, total_time[1]]) + ":" + str("%0*d" % [2, total_time[2]]))
			else:
				child.get_child(0).set_text(str("%0*d" % [1, total_time[0]]) + ":" + str("%0*d" % [2, total_time[1]]) + ":" + str("%0*d" % [2, total_time[2]]))

	total_time = [0, 0, 0]
	if order != {}:
		for child in splitters.get_children():
			if child.get_index() != order[child.text]:
				splitters.move_child(splitters.get_child(child.get_index()), order[child.text])
#	if splits_dict.values()[0][3] == null:
#		$SumOfBest.hide()
#	else:
#		count_summofbest()
#		$SumOfBest/SumOfBest.text += time_to_minutes_secs(summofbest)

#func count_summofbest():
#	for split in splits_dict:
#		summofbest += splits_dict[split][3]

func update_splits(child):
	total_time[0] += splits_dict[child.name][2][0]
	total_time[1] += splits_dict[child.name][2][1]
	total_time[2] += splits_dict[child.name][2][2]
	if total_time[2] >= 60:
		total_time[2] -= 60
		total_time[1] += 1
	if total_time[1] >= 60:
		total_time[1] -= 60
		total_time[0] += 1
	if total_time[0] == 0:
		child.get_child(0).set_text(str("%0*d" % [1, total_time[1]]) + ":" + str("%0*d" % [2, total_time[2]]))
	else:
		child.get_child(0).set_text(str("%0*d" % [1, total_time[0]]) + ":" + str("%0*d" % [2, total_time[1]]) + ":" + str("%0*d" % [2, total_time[2]]))
	splits_dict[child.name][1] = true
	current_split += 1
	print(total_time)
	if compare_split[2] != 0:
		print(compare_split, "against ", splits_dict[child.name])
		if splits_dict[child.name][2][0]*3600 + splits_dict[child.name][2][1]*60 + splits_dict[child.name][2][2] < compare_split[0]*3600 + compare_split[1]*60 + compare_split[2]:
			child.get_child(0).label_settings.font_color = green
		else:
			child.get_child(0).label_settings.font_color = red
	if child.get_index()+1 > shown_splits-2 and child.get_index() + 1< splitters.get_child_count()-1:
		splitters.get_child(child.get_index()-4).hide()
		splitters.get_child(child.get_index()+2).show()
	elif child.get_index()+1 == splitters.get_child_count():
		start_timer = false
		run_ended = true
		for splits in splitters.get_children():
			splits.show()

func not_live_run():
	for splits in splits_dict:
		splits_dict[splits][1] = false

func _ready():
	fill_splits()
	saveDiag.current_dir = "%userprofile%/Documents"
	get_window().position = Vector2(0, 50)
	get_window().grab_focus()
	title = $GameName/GameName/ver.text

func _input(event):
	if event is InputEventKey:
		print(event)
		if Input.is_action_pressed("Start"):
			if !run_ended:
				split_time()
				start_timer = true
				splitters.get_child(current_split-1).remove_theme_stylebox_override("normal")
				if splitters.get_child_count() > current_split:
					splitters.get_child(current_split).add_theme_stylebox_override("normal",current_split_theme)
			else:
				$Run_ended.show()
		if Input.is_action_pressed("Stop"):
			splitters.get_child(current_split).remove_theme_stylebox_override("normal")
			splitters.get_child(current_split-1).get_child(0).text = ""
			splitters.get_child(current_split-1).add_theme_stylebox_override("normal",current_split_theme)
			current_split -= 1
		if Input.is_action_pressed("Nullify"):
			nullify()
		if Input.is_action_pressed("ui_text_caret_right"):
			get_window().position[0] += 10
		if Input.is_action_pressed("ui_text_caret_left"):
			get_window().position[0] -= 10
		if Input.is_action_pressed("ui_text_caret_up"):
			get_window().position[1] -= 10
		if Input.is_action_pressed("ui_text_caret_down"):
			get_window().position[1] += 10

	if event is InputEventMouseButton:
		if Input.is_action_pressed("Options") and (start_timer == false or run_ended == true):
			print("lalala")
			var position = get_global_mouse_position()
			print(position)
			options.position = Vector2i((get_window().position[0] + position[0]), (get_window().position[1] + position[1]))
			options.show()
		if Input.is_action_pressed("click") and title_click == true:
			dragging = true
			await get_tree().create_timer(0.2).timeout
			while dragging:
				var delta_pos = get_local_mouse_position()
				get_window().position[0] += delta_pos[0] + -20
				get_window().position[1] += delta_pos[1] + -20
				await get_tree().create_timer(0.05).timeout
		if Input.is_action_just_released("click"):
			dragging = false
		

	
func nullify():
	start_timer = false
	for splits in splits_dict:
		splits_dict[splits][1] = false
	time = "0:00"
	current_split = 0
	print(splits_dict)
	total_time = [0, 0, 0]
	compare_split = [0, 0, 0]
	hours = 0
	mins = 0
	sec = 0
	run_ended = false
	current_split = 0
	delta_time = [0, 0, 0]
	timer.set_text(time)
	fill_splits()


func split_time():
	var remainder1:int = 0
	var remainder2: int = 0
	if start_timer == true:
		for splits in splits_dict.values():
			if splits[1] == false:
				if splits[0] == splitters.get_child(current_split).text:
					splits[2][2] = snappedf(sec, 0.01) - total_time[2]
					if splits[2][2] < 0:
						splits[2][2] = snappedf(sec, 0.01)+60 - total_time [2]
						remainder1 = 1
					splits[2][1] = mins - total_time[1] - remainder1
					if splits[2][1] < 0:
						splits[2][1] = mins+60 - total_time[1]
						remainder2 = 1
					splits[2][0] = hours - total_time[0] - remainder2
					if splits[3][2] != 0:
						compare_split = splits[3]
					update_splits(splitters.get_child(current_split))
					break


func _process(delta):
	if start_timer == true and run_ended == false:
		if sec >= 60:
			sec = 0
			mins += 1
		if mins >= 60:
			mins = 0
			hours += 1
		if mins == 0 and hours == 0:
			time = str(sec).pad_decimals(1)
		elif hours == 0:
			time = str("%0*d" % [1, mins]) + ":" + str("%0*d" % [2, sec])
		else:
			time = str("%0*d" % [1, hours]) + ":" + str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, sec])
		#sec += snappedf(delta, 0.01)
		sec += 0.1
		timer.set_text(time)



#func time_to_minutes_secs(time : float):
#	var mins = int(time) / 60
#	time -= mins * 60
#	var secs = int(time) 
#	if mins < 60:
#		return  str("%0*d" % [1, mins]) + ":" + str("%0*d" % [2, secs])
#	else:
#		var hours = int(mins) / 60
#		mins -= hours * 60
#		return  str("%0*d" % [1, hours]) + ":" + str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs])
	

#func save_file():
#	splits_dict
#	return splits_dict
#
#func saving():
#	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
#	var json_string = JSON.stringify(save_file())+1+
#	save_game.store_line(json_string)
#+=+==+=+=++
#func load_game():
#	if not FileAccess.file_exists("user://savegame.save"):+
#		$Delete.hide()
#		return # Error! We don't have a save to load.
#
#	var save_gam+ae = FileAccess.open("user://savegame.save", FileAccess.READ)
#	while save_game.get_position() < save_game.get_length():
#		var json_string = save_game.get_line()
#		var json = JSON.new()
#		var _parse_result = json.parse(json_string)
#		var node_data = json.get_data()
#		splits_dict = node_data



func _on_options_file_selected(path):
	remember_splits()
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	if save_file != null:
		not_live_run()
		nullify()
		var saved_data: Array = [splits_dict, title, order]
		var splits_data = JSON.stringify(saved_data)
		save_file.store_line(splits_data)


func _on_load_diag_file_selected(path):
	var load_file = FileAccess.open(path, FileAccess.READ)
	if load_file != null:
		var raw_json_string = load_file.get_line()
		var loaded_data = JSON.parse_string(raw_json_string)
		if type_string(typeof(loaded_data)) == "Array":
			splits_dict = loaded_data[0]
			title = loaded_data[1]
			$GameName/GameName/ver.text = title
			order = loaded_data[2]
			print(order)
		else:
			splits_dict = loaded_data
		loaded = true
		fill_splits()
		print(loaded_data)

func remember_splits():
	for split in splits_dict.values():
		split[3] = split[2]
		
func _on_save_pressed():
	saveDiag.show()

func _on_load_pressed():
	loadDiag.show()


func _on_yes_pressed():
	saveDiag.show()
	not_live_run()
	

func _on_no_pressed():
	$Run_ended.hide()
	run_ended = false
	nullify()


func _on_save_diag_confirmed():
	$Run_ended.hide()
	nullify()


func _on_clear_pressed():
	randomize_order()
	fill_splits()

func randomize_order():
	var i: int
	for child in splitters.get_children():
		i = randi_range(-6,6)
		splitters.move_child(splitters.get_child(child.get_index()), i)
		child.show()

func _on_exit_pressed():
	get_tree().quit() 


func _on_game_name_mouse_entered():
	title_click = true


func _on_game_name_mouse_exited():
	title_click = false


func _on_edit_title_pressed() -> void:
	$GameName/GameName/ver.hide()
	$GameName/GameName/ver_edit.show()


func _on_ver_edit_text_submitted(new_text: String) -> void:
	title = $GameName/GameName/ver_edit.text
	$GameName/GameName/ver.text = title
	$GameName/GameName/ver_edit.hide()
	$GameName/GameName/ver.show()
	
	
func _on_ver_edit_focus_exited() -> void:
	$GameName/GameName/ver_edit.hide()
	$GameName/GameName/ver.show()


func _on_edit_order_pressed() -> void:
	for child in splitters.get_children():
		child.get_child(0).hide()
		child.get_child(1).show()
		child.get_child(1).get_child(1).text = str(child.get_index())
		child.show()
	$Timer/Time.hide()
	$Timer/EditSplits.show()


func _on_ok_pressed() -> void:
	for child in splitters.get_children():
		child.get_child(0).show()
		child.get_child(1).hide()
		if child.get_index() != int(child.get_child(1).get_child(1).text):
			splitters.move_child(splitters.get_child(child.get_index()), int(child.get_child(-1).get_child(1).text))
	$Timer/Time.show()
	$Timer/EditSplits.hide()
	for child in splitters.get_children():
		order[child.text] = child.get_index()
		if child.get_index() >= shown_splits:
			child.hide()


func _on_cancel_pressed() -> void:
	for child in splitters.get_children():
		child.get_child(0).show()
		child.get_child(1).hide()
		if child.get_index() >= shown_splits-1:
			child.hide()
	$Timer/Time.show()
	$Timer/EditSplits.hide()


func _on_add_split_pressed() -> void:
	$ScrollContainer/Splits/Split1.duplicate()
