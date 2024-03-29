extends Node2D

#Spawn rates
export (int) var max_tile_in_a_row = 8
export (int) var special_tile_percent = 3
export (int) var bomb_tile_percent = 25

#Customizable level data
export (int) var grid_width = 8
export (int) var grid_height = 10
export (int) var x_start = 20
export (int) var y_start = 15
export (int) var x_off = 32
export (int) var y_off = 32

export (PackedScene) var default_tile
export (PackedScene) var aim_tile
export (PackedScene) var player_tile
export (PackedScene) var point_tile
export (PackedScene) var bomb_tile
export (Array, PackedScene) var special_tiles

onready var hud = $HUD
onready var def_tile_con = $DefaultTileContainer
onready var tile_con = $TileContainer
onready var gamespeed_timer = $GameSpeedTimer
onready var game_anim = $game_anim

var level_grid
var ins_aim
var ins_tile
var ins_player_tile

func _ready():
	#signals
	_signal_connect("hud")
	#animations
	anim_control("start")
	#game
	_prepare_game()
	_default_game_values()

func _prepare_game():
	# initialize grid
	initGrid()
	# This function will do more when there are more tile types
	draw_level()
	#initialize aim
	randomize()
	init_aim_tile(randi()%grid_width, grid_height / 2)
	#show tutorial
	Tutorial.tutorial_part("start")
	if Global.load_tut():
		Tutorial.tutorial_part("tutorial_1")

func _default_game_values():
	# assign default game speed after every new start
	Engine.time_scale = Global.default_game_speed
	Global.current_game_speed = Global.default_game_speed
	#reset score after every new start
	Global.score = 0
	#reset stocked points after every new start
	Global.stocked_points = 0
	#set default background color
	VisualServer.set_default_clear_color(Color(0.3, 0.3, 0.3))

func initGrid():
	# Initialize the grid to all default tiles
	level_grid = []
	for i in range(grid_width):
		level_grid.append([])
		#warning-ignore:unused_variable
		for j in range(grid_height):
			level_grid[i].append(0)

func grid_to_pixel(x, y):
	# Convert grid coordinates to pixel values
	return Vector2(x * x_off + x_start, y * y_off + y_start)

func draw_level():
	# Draw each tile in the level grid
	for i in range(grid_width):
		for j in range(grid_height):
			if (level_grid[i][j] == 0):
				var tile = default_tile.instance()
				def_tile_con.add_child(tile)
				var pos = grid_to_pixel(i, j)
				tile.position = Vector2(pos[0], pos[1])

func _signal_connect(which_obj):
	if which_obj == "player_tile":
		ins_player_tile.connect("game_over", hud, "game_over")
		ins_player_tile.connect("piggy_bank_notifier", hud, "piggy_bank_notifier")
#		ins_player_tile.connect("game_paused", hud, "game_paused")
	if which_obj == "point_tile":
		ins_tile.connect("make_it_bomb_tile", self, "from_point_to_bomb")
	if which_obj == "aim_tile":
		ins_aim.connect("make_it_player_tile", self, "from_aim_to_player")
	if which_obj == "hud":
		hud.connect("restart_game", self, "anim_control")

func init_aim_tile(posX, posY):
	# Initialize the aim
	ins_aim = aim_tile.instance()
	# Add the tile object to the game
	add_child(ins_aim)
	#signal connect
	_signal_connect("aim_tile")
	# Set position and aim variables
	var aim_position = grid_to_pixel(posX, posY)
	ins_aim.position = Vector2(aim_position[0], aim_position[1])
	ins_aim.grid_x = posX
	ins_aim.grid_y =  posY

func _on_SpawnTileTimer_timeout():
	randomize()
	var rand_spawn_rate = randi()%max_tile_in_a_row
#	print(rand_spawn_rate)
	for i in rand_spawn_rate:
		chooseTileAndInit()

func chooseTileAndInit():
	var rand_number = pick_rand_number()
	#instance special tile
	if rand_number <= special_tile_percent:
		ins_tile = special_tiles[randi() % special_tiles.size()].instance()
	#instance bomb tile
	elif rand_number > special_tile_percent && rand_number <= bomb_tile_percent + special_tile_percent:
		ins_tile = bomb_tile.instance()
	#instance point tile
	else:
		ins_tile = point_tile.instance()
		_signal_connect("point_tile")
	#add to tile container
	tile_con.add_child(ins_tile)
	#initialize the choosen object
	randomize()
	initTile(ins_tile, randi()%grid_width, 0)

func initTile(whichTile, tilePosX, tilePosY):
	# Set position and tile object variables
	var tile_position = grid_to_pixel(tilePosX, tilePosY)
	whichTile.position = Vector2(tile_position[0], tile_position[1])
	whichTile.grid_x = tilePosX
	whichTile.grid_y =  tilePosY

func pick_rand_number():
	randomize()
	return randi()%100 + 1

func from_aim_to_player(choosen_tile, posX, posY):
	SFX.game_start_sound.play()
	#instance player tile
	ins_player_tile = player_tile.instance()
#	call_deferred("add_child", ins_player_tile)
	add_child(ins_player_tile)
	#assign position
	initTile(ins_player_tile, posX, posY)
	#assign features
	ins_player_tile.assign_features(choosen_tile)
	#signal connect
	_signal_connect("player_tile")
	#destroy unused tiles
	choosen_tile.destroy()
	
	#show tutorial (2)
	if Global.load_tut():
		Tutorial.tutorial_part("tutorial_2")
	else:
		Tutorial.tutorial_part("aim_to_player")

func from_point_to_bomb(point_tile, posX, posY): #change point tile as bomb tile when move point is 0
	#instance bomb tile
	var ins_bomb_tile = bomb_tile.instance()
	tile_con.add_child(ins_bomb_tile)
	#assign position
	initTile(ins_bomb_tile, posX, posY)
	#destroy old point tile
	point_tile.destroy()

func _on_GameSpeedTimer_timeout():
	Engine.time_scale += 0.05
	gamespeed_timer.wait_time += 1
	Global.current_game_speed = stepify(Engine.time_scale, 0.01)

func anim_control(state):
	if state == "start":
		game_anim.play("game_screen_collection")
		Tutorial.tut_anim.play("tut_collection")
	if state == "restart":
		game_anim.play("game_screen_diffusion")
		Tutorial.tut_anim.play("tut_diffusion")

func _on_game_anim_animation_finished(anim_name):
	if anim_name == "game_screen_diffusion":
		Global.change_scene("Game")
