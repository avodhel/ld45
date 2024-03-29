extends Node

#GLOBAL VARIABLES
#warning-ignore:unused_class_variable
var score = 0
#warning-ignore:unused_class_variable
var life = 0
#warning-ignore:unused_class_variable
var stocked_points = 0
#warning-ignore:unused_class_variable
var show_tutorial = true
#warning-ignore:unused_class_variable
var default_game_speed = 1.5
#warning-ignore:unused_class_variable
var current_game_speed = 1.5

func _ready():
#	Global.reset_highscore()
#	Global.reset_tut()
	pass

#SCENE MANAGER
const SCENE_PATH = "res://Scenes/"

func change_scene(scene_name):
	yield(get_tree().create_timer(0.65), "timeout")
	call_deferred("_deferred_change_scene", scene_name)
	if get_tree().paused == true: # if game paused
		get_tree().paused = false # unpaused 

func _deferred_change_scene(scene_name):
	var path = SCENE_PATH + scene_name + ".tscn"
	var root = get_tree().get_root()
	var current = root.get_child(root.get_child_count() - 1)
	current.free()
	var scene_resource = ResourceLoader.load(path)
	var new_scene = scene_resource.instance()
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)

#HIGHSCORE
const SAVE_HS_FILE_PATH = "user://highscore.save"

func save_highscore(score):
	if load_highscore() > score:
		return
	
	var save_file = File.new()
	save_file.open(SAVE_HS_FILE_PATH, File.WRITE)
	var hs_data = {
		highscore = score
	}
	save_file.store_line(to_json(hs_data))
	save_file.close()

func load_highscore():
	var save_file = File.new()
	if !save_file.file_exists(SAVE_HS_FILE_PATH):
		return 0
	
	#warning-ignore:unused_variable
	var highscore
	
	save_file.open(SAVE_HS_FILE_PATH, File.READ)
	var hs_data  = parse_json(save_file.get_line())
	return hs_data["highscore"]

func reset_highscore():
	var dir = Directory.new()
	dir.remove(SAVE_HS_FILE_PATH)

#TUTORIAL
const SAVE_TUT_FILE_PATH = "user://tutorial.save"

func save_tut(con):
	var save_file = File.new()
	save_file.open(SAVE_TUT_FILE_PATH, File.WRITE)
	var tut_data = {
		tutorial = con
	}
	save_file.store_line(to_json(tut_data))
	save_file.close()

func load_tut():
	var save_file = File.new()
	if !save_file.file_exists(SAVE_TUT_FILE_PATH):
		return show_tutorial
	
	#warning-ignore:unused_variable
	var tutorial
	
	save_file.open(SAVE_TUT_FILE_PATH, File.READ)
	var tut_data  = parse_json(save_file.get_line())
	return tut_data["tutorial"]

func reset_tut():
	var dir = Directory.new()
	dir.remove(SAVE_TUT_FILE_PATH)