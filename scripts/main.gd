extends Control

# 변수
@onready var background = $Background
@onready var footstep_sound = $FootstepSound
@onready var fade = $Fade
@onready var forward_arrow = $ForwardArrow
@onready var back_arrow = $BackArrow
@onready var locked_sound = $LockedSound
@onready var door_button = $DoorButton

var arrow_time = 0.0
var is_moving = false
var current_room = "hallway_1"
var rooms = {}

# 상수
const MSG_NO_FORWARD = "더 이상 앞으로 갈 수 없다..."
const MSG_NO_BACK = "뒤로 갈 수 없다..."
const MSG_DOOR_LOCKED = "문이 굳게 잠겨있다..."

# 프레임 마다 실행 함수
func _process(delta):
	
	if is_moving:
		return

	if Input.is_action_just_pressed("move_forward"):
		var room = rooms[current_room]
		if room.has("forward"):
			move_to_room(room["forward"])
		else:
			await show_dialogue(MSG_NO_FORWARD)

	if Input.is_action_just_pressed("move_back"):
		var room = rooms[current_room]
		if room.has("back"):
			move_to_room(room["back"])
		else:
			await show_dialogue(MSG_NO_BACK)
	
	arrow_time += delta
	forward_arrow.position.y = 30 + sin(arrow_time * 2.0) * 6
	back_arrow.position.y = 950 + sin((arrow_time * 2.0) + PI) * 6
# 처음에 한번 실행 함수
func _ready():
	
	load_rooms()
	background.scale = Vector2(1, 1)
	update_room()
# 방 변경 함수
func update_room():

	var room = rooms[current_room]
	background.texture = load(room["background"])
	forward_arrow.visible = room.has("forward")
	back_arrow.visible = room.has("back")
	door_button.visible = room.has("door")
# 방 이동 함수
func move_to_room(target_room):

	is_moving = true
	await play_move_effect()
	current_room = target_room
	update_room()
	is_moving = false
# 문 상호작용 함수
func _on_door_button_pressed():
	var room = rooms[current_room]
	if room.has("door_open") and room["door_open"]:
		move_to_room(room["door"])
	else:
		locked_sound.play()
		await show_dialogue(MSG_DOOR_LOCKED)
# 대사 출력 함수
func show_dialogue(text):

	$DialogueBox.visible = true
	$DialogueBox/DialogueText.text = text
	await get_tree().create_timer(2).timeout
	$DialogueBox.visible = false
# 이동 효과 함수
func play_move_effect():

	footstep_sound.play()
	var tween = create_tween()

	tween.tween_property(
		background,
		"scale",
		Vector2(1.35, 1.35),
		0.22
	)

	tween.tween_property(
		background,
		"position",
		Vector2(40, 0),
		0.06
	)

	tween.tween_property(
		background,
		"position",
		Vector2(-40, 0),
		0.06
	)

	tween.tween_property(
		background,
		"position",
		Vector2(0, 0),
		0.06
	)

	tween.tween_property(
		background,
		"scale",
		Vector2(1.0, 1.0),
		0.28
	)

	var fade_tween = create_tween()

	fade_tween.tween_property(
		fade,
		"color:a",
		1,
		0
	)

	fade_tween.tween_property(
		fade,
		"color:a",
		0.0,
		3.3
	)
	await tween.finished
# 방 로드 함수
func load_rooms():

	if not FileAccess.file_exists("res://data/rooms.json"):
		print("rooms.json 없음")
		return

	var file = FileAccess.open(
		"res://data/rooms.json",
		FileAccess.READ
	)

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	if error == OK:
		rooms = json.data
	else:
		print("JSON 파싱 실패")
	
	
	
	
