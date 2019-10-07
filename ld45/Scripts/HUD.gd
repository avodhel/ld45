extends CanvasLayer

onready var score_lbl = $Game_HUD/score_lbl
onready var life_lbl = $Game_HUD/life_sprite/life_lbl
onready var stock_point_lbl = $Game_HUD/stock_point_sprite/stock_point_lbl
onready var gameover_hud = $GameOver_HUD
onready var highscore_lbl = $GameOver_HUD/highscore_lbl
onready var anim = $AnimationPlayer

var highscore = 0

func _ready():
	anim.play("anim")

#warning-ignore:unused_argument
func _process(delta):
	score_lbl.text = "Score: " + str(Global.score)
	life_lbl.text = str(Global.life)
	stock_point_lbl.text = str(Global.stocked_points)

func assing_highscore(value):
		Global.save_highscore(value)
		highscore = str(Global.load_highscore()) # update high score
		highscore_lbl.text = "Highscore: " + highscore # assign high score to text

func game_over():
	gameover_hud.visible = true
	assing_highscore(Global.score)

func _on_restart_btn_pressed():
	gameover_hud.visible = false
	Global.change_scene("Game")
