extends CanvasLayer

var score_text = "Score: "
var game_active = false

signal start_game

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over(won=false):
	game_active = false
	if won:
		$Title.text = "<CONGRATULATIONS>"
		$SubTitle.text = "{YOU_WON!}"
	$ScoreLabel.hide()
	$Title.show()
	$SubTitle.show()


func update_score(score):
	$ScoreLabel.text = score_text + str(score)


func _input(event):
	if event is InputEventKey and event.pressed and game_active == false:
		$ScoreLabel.show()
		$Title.hide()
		$SubTitle.hide()
		start_game.emit()
		game_active = true

