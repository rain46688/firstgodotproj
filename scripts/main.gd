extends Control

# 변수
@onready var background = $Background
@onready var footstep_sound = $FootstepSound
@onready var fade = $Fade
@onready var forward_arrow = $ForwardArrow
@onready var back_arrow = $BackArrow
@onready var locked_sound = $LockedSound
@onready var door_button = $DoorButton
@onready var desk_button = $DeskButton
@onready var choice_box = $DialogueBox/ChoiceBox
@onready var choice_labels = [
	$DialogueBox/ChoiceBox/Choice1,
	$DialogueBox/ChoiceBox/Choice2,
	$DialogueBox/ChoiceBox/Choice3,
	$DialogueBox/ChoiceBox/Choice4
]
@onready var window_button = $WindowButton
@onready var choice_sound = $ChoiceSound
@onready var locker_button = $LockerButton

var arrow_time = 0.0
var is_moving = false
var current_room = "hallway_1"
var rooms = {}
var is_choosing = false
var choice_index = 0
var current_choices = []
var is_interacting = false
var is_dialogue_showing = false
var dialogue_finished = false
var is_typing = false
var typing_finished = false
var inventory = []

# 상수
const MSG_NO_FORWARD = "더 이상 앞으로 갈 수 없다..."
const MSG_NO_BACK = "뒤로 갈 수 없다..."
const MSG_DOOR_LOCKED = "문이 굳게 잠겨있다..."

# 프레임 마다 실행 함수
func _process(delta):
	
	# 1. 선택지 중이면 선택지만 처리하고 종료
	if is_choosing:
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("move_back"):
			choice_index += 1
			if choice_index >= current_choices.size():
				choice_index = 0
			update_choice_ui()
			choice_sound.play()

		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("move_forward"):
			choice_index -= 1
			if choice_index < 0:
				choice_index = current_choices.size() - 1
			update_choice_ui()
			choice_sound.play()

		if Input.is_action_just_pressed("ui_accept"):
			choice_sound.play()
			is_choosing = false

		return
		
	if is_dialogue_showing:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("mouse_left"):
			if is_typing:
				typing_finished = true
			else:
				dialogue_finished = true
		return

	# 2. 이동 중이면 아무 입력도 받지 않음
	if is_moving:
		return

	# 3. 대사/상호작용 중이면 맵 이동 금지
	if is_interacting:
		return

	# 4. 여기부터 일반 맵 이동 입력
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

	# 5. 화살표 애니메이션
	arrow_time += delta
	forward_arrow.position.y = 30 + sin(arrow_time * 2.0) * 6
	back_arrow.position.y = 950 + sin((arrow_time * 2.0) + PI) * 6
# 처음에 한번 실행 함수
func _ready():
	
	background.scale = Vector2(1, 1)
	var success = load_rooms()
	
	if not success:
		push_error("방 데이터 로드 실패로 게임 초기화 중단")
		return
		
	update_room()
# 방 변경 함수
func update_room():
	
	var room = rooms[current_room]
	
	if not rooms.has(current_room):
		push_error("존재하지 않는 방: " + current_room)
		return
		
	if not room.has("background"):
		push_error(current_room + "에 background 값이 없음")
		return
		
	window_button.visible = false
	
	if room.has("interactions"):
		window_button.visible = room["interactions"].has("window")
		
	background.texture = load(room["background"])
	forward_arrow.visible = room.has("forward")
	back_arrow.visible = room.has("back")
	door_button.visible = room.has("door")
	
	desk_button.visible = false
	locker_button.visible = false
# interactions 체크하는 부분
	if room.has("interactions"):
		if room["interactions"].has("desk"):
			desk_button.visible = true
			
	if room.has("interactions"):
		if room["interactions"].has("locker"):
			locker_button.visible = true
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

	is_dialogue_showing = true
	dialogue_finished = false
	is_typing = true
	typing_finished = false

	$DialogueBox.visible = true
	$DialogueBox/DialogueText.text = ""

	var current_text = ""
	
	for i in text.length():
		if typing_finished:
			break

		current_text += text[i]
		$DialogueBox/DialogueText.text = current_text
		choice_sound.play()
		
		await get_tree().create_timer(0.04).timeout

	$DialogueBox/DialogueText.text = text
	is_typing = false
	typing_finished = true

	while not dialogue_finished:
		await get_tree().process_frame

	$DialogueBox.visible = false
	is_dialogue_showing = false
	dialogue_finished = false
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
	
	var path = "res://data/rooms.json"
	
	if not FileAccess.file_exists(path):
		push_error("rooms.json 파일을 찾을 수 없음: " + path)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("rooms.json 파일 열기 실패: " + path)
		return false
		
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("rooms.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false
		
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("rooms.json 최상위 구조는 Dictionary여야 함")
		return false
		
	rooms = json.data
	
	if not rooms.has(current_room):
		push_error("현재 방이 rooms.json에 없음: " + current_room)
		return false
		
	print("rooms.json 로드 성공")
	return true
# 책상 상호작용 함수	
func _on_desk_button_pressed() -> void:
	await run_interaction("desk")
# 선택지 함수
func show_choices(choices):
	
	is_choosing = true
	choice_index = 0
	current_choices = choices
	
	$DialogueBox.visible = true
	choice_box.visible = true
	
	update_choice_ui()
	
	while is_choosing:
		await get_tree().process_frame

	choice_box.visible = false
	$DialogueBox.visible = false

	return choice_index
# 선택지 UI 갱신 함수
func update_choice_ui():
	
	for i in choice_labels.size():
		if i < current_choices.size():
			choice_labels[i].visible = true
			choice_labels[i].text = get_choice_text(i)
		else:
			choice_labels[i].visible = false
# 선택지 UI 갱신 함수
func get_choice_text(index):
	
	if index >= current_choices.size():
		return ""
		
	if index == choice_index:
		return "> " + current_choices[index]["text"]
	else:
		return "  " + current_choices[index]["text"]
# 상호작용 실행 함수		
func run_interaction(interaction_id):
	
	if is_interacting:
		return

	is_interacting = true
	set_interaction_buttons_disabled(true)

	var room = rooms[current_room]

	if not room.has("interactions"):
		is_interacting = false
		set_interaction_buttons_disabled(false)
		return

	if not room["interactions"].has(interaction_id):
		is_interacting = false
		set_interaction_buttons_disabled(false)
		return

	var interaction = room["interactions"][interaction_id]

	if interaction.has("text"):
		await show_dialogue(interaction["text"])

	if interaction.has("choices"):
		var selected_index = await show_choices(interaction["choices"])
		var selected_choice = interaction["choices"][selected_index]

		if selected_choice.has("result_text") and selected_choice["result_text"] != "":
			await show_dialogue(selected_choice["result_text"])
			
		if selected_choice.has("item"):
			add_item(selected_choice["item"])

	set_interaction_buttons_disabled(false)
	is_interacting = false
# 창문 상호작용 함수		
func _on_window_button_pressed() -> void:
	await run_interaction("window")
# 상호작용 중 버튼 막는 함수
func set_interaction_buttons_disabled(disabled):
	
	desk_button.disabled = disabled
	window_button.disabled = disabled
	door_button.disabled = disabled
	locker_button.disabled = disabled
# 아이템 추가 함수
func has_item(item_id):
	return inventory.has(item_id)

func add_item(item_id):
	if has_item(item_id):
		return

	inventory.append(item_id)
	print("아이템 획득: " + item_id)
# 사물함 상호작용 함수	
func _on_locker_button_pressed() -> void:
	await run_interaction("locker")
