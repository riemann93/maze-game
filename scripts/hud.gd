extends CanvasLayer

var timer_text = "Timer: %s"
var lives_text = "Lives: %s"
var bombs_text = "Bombs: %s"
@export var timer: int
var timer_delta = 0
var game_active = false
var timer_label
var lives_label
var bombs_label
var anykey = false

signal start_game

func _ready():
	timer_label = $TimerLabel
	lives_label = $LivesLabel
	bombs_label = $BombsLabel
	$AnykeyTimer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_active:
		timer_delta += delta
		var _time = timer + 1 - timer_delta
		if _time < 0:
			var main = get_tree().get_root().get_node("Main")
			main.end_game()
		timer_label.text = timer_text % str(int(_time))

func update_lives(lives):
	lives_label.text = lives_text % lives


func update_bombs(bombs):
	bombs_label.text = bombs_text % bombs


func game_over(won=false):
	game_active = false
	anykey = false
	timer_delta = 0
	if won:
		$Title.text = "<CONGRATULATIONS>"
		$SubTitle.text = "{YOU_WON!}"
		$SubTitle.show()
	$TimerLabel.hide()
	$LivesLabel.hide()
	$BombsLabel.hide()
	$Title.show()
	$AnykeyTimer.start()


func _input(event):
	if event is InputEventKey and event.pressed and game_active == false and anykey == true:
		# $AnykeyTimer.pause()
		$TimerLabel.show()
		$LivesLabel.show()
		$BombsLabel.show()
		$Title.hide()
		$SubTitle.hide()
		start_game.emit()
		game_active = true



func _on_anykey_timer_timeout():
	anykey = true
	$SubTitle.text = "{PRESS_ANY_KEY}"
	$SubTitle.show()
