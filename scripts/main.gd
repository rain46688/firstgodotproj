extends Control

# onready 변수 모음
@onready var background = $Background
@onready var footstep_sound = $FootstepSound
@onready var fade = $Fade
@onready var arrow_up = $ArrowUp
@onready var arrow_down = $ArrowDown
@onready var arrow_left = $ArrowLeft
@onready var arrow_right = $ArrowRight
@onready var locked_sound = $LockedSound
@onready var choice_box = $DialogueBox/ChoiceBox
@onready var choice_labels = [
	$DialogueBox/ChoiceBox/Choice1,
	$DialogueBox/ChoiceBox/Choice2,
	$DialogueBox/ChoiceBox/Choice3,
	$DialogueBox/ChoiceBox/Choice4
]
@onready var choice_sound = $ChoiceSound
@onready var unlocked_sound = $UnLockedSound
@onready var move_arrows = {
	"up": arrow_up,
	"down": arrow_down,
	"left": arrow_left,
	"right": arrow_right
}
@onready var interaction_buttons = $InteractionButtons
@onready var inventory_ui = $InventoryUI
@onready var bag_open_sound = $BagOpenSound
@onready var inventory_slots = $InventoryUI/InventorySlots
@onready var selected_item_image = $InventoryUI/SelectedItemImage
@onready var selected_item_description = $InventoryUI/SelectedItemDescription
@onready var item_sound = $ItemSound

# 일반 변수 모음
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
var flags = {}
var arrow_base_positions = {}
var is_inventory_open = false
var items = {}
var inventory_slot_size = 150
var inventory_slot_gap = 5

# 상수 변수 모음
const MSG_NO_FORWARD = "더 이상 앞으로 갈 수 없다..."
const MSG_NO_BACK = "더 이상 뒤로 갈 수 없다..."
const MSG_NO_LEFT = "그쪽으로는 갈 수 없다..."
const MSG_NO_RIGHT = "그쪽으로는 갈 수 없다..."
const MSG_DOOR_LOCKED = "문이 굳게 잠겨있다..."
const MSG_DOOR_UNLOCK = "교실키로 문을 열었다."
const MSG_ITEM_GAINED_SUFFIX = "을 얻었다."

# 프레임 마다 실행 함수
func _process(delta):
	# 입력 우선순위:
	# 1. 선택지 조작
	# 2. 대사 넘기기
	# 3. 이동/상호작용 차단
	# 4. 일반 이동 입력
	
	# 선택지 중이면 선택지만 처리하고 종료
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
		
	# 대사 타이핑중이면 빠르게 넘기기 및 종료
	if is_dialogue_showing:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("mouse_left"):
			if is_typing:
				typing_finished = true
			else:
				dialogue_finished = true
		return

	# 인벤토리가 열려 있으면 게임 이동/상호작용 입력을 막음
	if is_inventory_open:
		if Input.is_action_just_pressed("esc"):
			print("inven")
			close_inventory()
		return

	# 이동 중이면 아무 입력도 받지 않음
	if is_moving:
		return

	# 대사/상호작용 중이면 맵 이동 금지
	if is_interacting:
		return

	# 여기부터 일반 맵 이동 입력
	if Input.is_action_just_pressed("move_forward"):
		await try_move_to_exit("up")

	if Input.is_action_just_pressed("move_back"):
		await try_move_to_exit("down")

	if Input.is_action_just_pressed("move_left"):
		await try_move_to_exit("left")

	if Input.is_action_just_pressed("move_right"):
		await try_move_to_exit("right")

	# 화살표 애니메이션
	arrow_time += delta

	for dir in move_arrows.keys():
		var arrow = move_arrows[dir]

		if not arrow.visible:
			continue

		if not arrow_base_positions.has(dir):
			continue

		var base_pos = arrow_base_positions[dir]
		var offset = sin(arrow_time * 2.0) * 6

		if dir == "up":
			arrow.position = base_pos + Vector2(0, offset)

		elif dir == "down":
			arrow.position = base_pos + Vector2(0, -offset)

		elif dir == "left":
			arrow.position = base_pos + Vector2(offset, 0)

		elif dir == "right":
			arrow.position = base_pos + Vector2(-offset, 0)
# 처음에 한번 실행 함수
func _ready():
	
	background.scale = Vector2(1, 1)
	
	# 버튼이 키보드 포커스를 가져가지 않게 설정
	# Space를 눌렀을 때 버튼이 다시 눌리는 문제 방지
	$BagButton.focus_mode = Control.FOCUS_NONE
		
	# 방 로드 및 예외 처리
	var success = load_rooms()

	if not success:
		push_error("방 데이터 로드 실패로 게임 초기화 중단")
		return
		
	# 아이템 로드 및 예외 처리
	var item_success = load_items()

	if not item_success:
		push_error("아이템 데이터 로드 실패로 게임 초기화 중단")
		return

	# 테스트
	await add_item("cutter_knife")
	#await add_item("classroom_key")
		
	update_room()
# 방 변경 함수
func update_room():
	
	var room = rooms[current_room]
	
	# 방 예외 처리
	if not rooms.has(current_room):
		push_error("존재하지 않는 방: " + current_room)
		return
		
	if not room.has("background"):
		push_error(current_room + "에 background 값이 없음")
		return
	
	# 기본 배경 이미지
	var background_path = room["background"]

	# 모든 이동 화살표를 먼저 숨김
	for dir in move_arrows.keys():
		move_arrows[dir].visible = false

	# exits 데이터가 있다면 출구 상태 확인
	if room.has("exits"):
		for dir in room["exits"].keys():
			var exit_data = room["exits"][dir]

			# 잠긴 출구인지 확인
			var is_locked = exit_data.has("locked") and exit_data["locked"] == true

			# 잠긴 출구가 이미 열렸는지 확인
			var is_unlocked = false
			if exit_data.has("open_flag") and has_flag(exit_data["open_flag"]):
				is_unlocked = true

			# 열린 플래그가 있으면 현재 방 배경을 열린 배경으로 변경
			if is_unlocked and room.has("opened_background"):
				background_path = room["opened_background"]

			# 잠긴 문은 화살표를 숨김
			if is_locked and not is_unlocked:
				continue
				
			# 열린 출구만 화살표 표시
			if move_arrows.has(dir):
				var arrow = move_arrows[dir]
				arrow.visible = true

				if exit_data.has("position"):
					arrow.position = Vector2(
						exit_data["position"][0],
						exit_data["position"][1]
					)
					arrow_base_positions[dir] = arrow.position

	background.texture = load(background_path)
	
	# 현재 방의 interactions 데이터를 기준으로 클릭 버튼 자동 생성
	create_interaction_buttons(room)
	create_exit_buttons(room)
# 방 이동 함수
func move_to_room(target_room, use_shake, direction):
	# 이동 중에는 추가 입력을 막음
	is_moving = true
	
	# use_shake가 true면 흔들림 사용, false면 암전만 사용
	await effect(true, use_shake, true, direction)
	
	# 실제 방 변경
	current_room = target_room
	update_room()
	
	# 새 방이 보인 뒤 바로 이동하지 못하게 잠깐 대기
	await get_tree().create_timer(1.5).timeout
	
	# 다시 입력 허용
	is_moving = false
# 방향키 입력을 받아 exits 데이터 기준으로 이동하는 함수
func try_move_to_exit(direction):

	var room = rooms[current_room]

	# 현재 방에 해당 방향 출구가 없으면 방향별 대사 출력
	if not room.has("exits") or not room["exits"].has(direction):
		if direction == "up":
			await show_dialogue(MSG_NO_FORWARD)
		elif direction == "down":
			await show_dialogue(MSG_NO_BACK)
		elif direction == "left":
			await show_dialogue(MSG_NO_LEFT)
		elif direction == "right":
			await show_dialogue(MSG_NO_RIGHT)
		return

	var exit_data = room["exits"][direction]

	# 잠긴 출구인지 확인
	var is_locked = exit_data.has("locked") and exit_data["locked"] == true

	# 잠긴 출구가 이미 열렸는지 확인
	var is_unlocked = false
	if exit_data.has("open_flag") and has_flag(exit_data["open_flag"]):
		is_unlocked = true

	# 잠겨 있고 아직 열리지 않은 출구는 방향키로 처리하지 않음
	# 잠긴 문은 마우스 클릭으로만 상호작용
	if is_locked and not is_unlocked:
		return

	# 출구별 이동 효과 결정
	var use_shake = true

	# JSON에 "move_effect": "door" 라고 적힌 출구만 흔들림 없이 이동
	if exit_data.has("move_effect") and exit_data["move_effect"] == "door":
		use_shake = false

	# 열린 출구 이동
	await move_to_room(exit_data["target"], use_shake, direction)
# 대사 출력 함수
func show_dialogue(text):
	# - 글자를 한 글자씩 출력
	# - 출력 중 입력하면 전체 문장 즉시 표시
	# - 출력 완료 후 입력하면 대사창 종료

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
		# 타이핑 속도 0.04
		await get_tree().create_timer(0.04).timeout

	$DialogueBox/DialogueText.text = text
	is_typing = false
	typing_finished = true

	while not dialogue_finished:
		await get_tree().process_frame

	$DialogueBox.visible = false
	is_dialogue_showing = false
	dialogue_finished = false
# 방 로드 및 예외 처리 함수
func load_rooms():
	
	# 방 구조 json 파일
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
# 선택지 목록 표시 갱신 함수
func update_choice_ui():
	
	for i in choice_labels.size():
		if i < current_choices.size():
			choice_labels[i].visible = true
			choice_labels[i].text = get_choice_text(i)
		else:
			choice_labels[i].visible = false
# 현재 선택된 선택지 앞에 화살표를 붙이는 함수
func get_choice_text(index):
	
	if index >= current_choices.size():
		return ""
		
	if index == choice_index:
		return "▶ " + current_choices[index]["text"]
	else:
		return "  " + current_choices[index]["text"]
# 상호작용 실행 함수		
func run_interaction(interaction_id):
	# rooms.json의 interactions 데이터를 읽어서
	# 기본 대사 → 선택지 → 결과 대사 → 아이템 획득 순서로 처리
	
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

	# 여러 줄 대사가 있으면 순서대로 출력
	if interaction.has("texts"):
		for text in interaction["texts"]:
			await show_dialogue(text)

	# 기존 단일 대사도 계속 지원
	elif interaction.has("text"):
		await show_dialogue(interaction["text"])

	if interaction.has("choices"):
		var selected_index = await show_choices(interaction["choices"])
		var selected_choice = interaction["choices"][selected_index]

		# 이미 실행된 선택지인지 먼저 확인
		if selected_choice.has("flag") and has_flag(selected_choice["flag"]):
			if selected_choice.has("already_text") and selected_choice["already_text"] != "":
				await show_dialogue(selected_choice["already_text"])

		# 처음 실행하는 선택지라면 결과 처리
		else:
			if selected_choice.has("result_text") and selected_choice["result_text"] != "":
				await show_dialogue(selected_choice["result_text"])

			if selected_choice.has("item"):
				var item_id = selected_choice["item"]
				var added = await add_item(item_id)

				if added:
					await show_dialogue("『" + get_item_name(item_id) + "』" + MSG_ITEM_GAINED_SUFFIX)

			if selected_choice.has("flag"):
				set_flag(selected_choice["flag"])

	set_interaction_buttons_disabled(false)
	is_interacting = false
# 상호작용 중 버튼 클릭 안되게 막는 함수
func set_interaction_buttons_disabled(disabled):
	
	for child in interaction_buttons.get_children():
		if child is Button:
			child.disabled = disabled
# 아이템 보유 여부 확인 함수
func has_item(item_id):
	for item in inventory:
		if item["id"] == item_id:
			return true

	return false
# 아이템 추가 함수
func add_item(item_id):
	if has_item(item_id):
		return false

	var empty_slot = find_empty_slot(item_id)

	if empty_slot == -1:
		await show_dialogue("가방에 공간이 없다.")
		return false

	inventory.append({
		"id": item_id,
		"slot": empty_slot
	})

	print("아이템 획득: " + get_item_name(item_id))
	return true
# 플래그 보유 여부 확인 함수
func has_flag(flag_id):
	return flags.has(flag_id) and flags[flag_id] == true
# 플래그 설정 함수
func set_flag(flag_id):
	flags[flag_id] = true
	print("플래그 설정: " + flag_id)
# 이펙트 효과 함수
func effect(sound_effect, shake_effect, fade_effect, direction):
	
	# 발소리 효과
	if sound_effect:
		footstep_sound.play()
		
	if shake_effect:
		var shake_tween = create_tween()
		if direction == "up":
			# 화면 앞뒤 흔들림
			shake_tween.tween_property(
				background,
				"scale",
				Vector2(1.35, 1.35),
				0.22
			)
			
			# 화면 좌우 흔들림
			shake_tween.tween_property(
				background,
				"position",
				Vector2(40, 0),
				0.06
			)

			shake_tween.tween_property(
				background,
				"position",
				Vector2(-40, 0),
				0.06
			)
			
			shake_tween.tween_property(
				background,
				"position",
				Vector2(0, 0),
				0.06
			)
			
			shake_tween.tween_property(
				background,
				"scale",
				Vector2(1.0, 1.0),
				0.28
			)
		elif direction == "down" or direction == "left" or direction == "right":
						
			# 화면 좌우 흔들림
			shake_tween.tween_property(
				background,
				"position",
				Vector2(40, 0),
				0.06
			)

			shake_tween.tween_property(
				background,
				"position",
				Vector2(-40, 0),
				0.06
			)
			
			shake_tween.tween_property(
				background,
				"position",
				Vector2(0, 0),
				0.06
			)
		else:
			print("no effect")
	
	if fade_effect:
		# 암전 처리
		var fade_tween = create_tween()
		
		# 화면을 즉시 어둡게 만듦
		fade_tween.tween_property(
			fade,
			"color:a",
			1,
			0
		)
		
		# 천천히 다시 밝아짐
		fade_tween.tween_property(
			fade,
			"color:a",
			0.0,
			3.3
		)
	
	await get_tree().create_timer(0.3).timeout
# 현재 방에 생성된 상호작용 버튼들을 전부 제거
func clear_interaction_buttons():
	for child in interaction_buttons.get_children():
		child.queue_free()
# rooms.json의 interactions 데이터를 읽어서 클릭 영역 버튼을 자동 생성
func create_interaction_buttons(room):

	clear_interaction_buttons()

	if not room.has("interactions"):
		return

	for interaction_id in room["interactions"].keys():
		var interaction = room["interactions"][interaction_id]

		# click_rect가 없는 상호작용은 버튼 생성하지 않음
		if not interaction.has("click_rect"):
			continue

		var rect = interaction["click_rect"]

		var button = Button.new()
		# 투명 상호작용 버튼이 Space 입력으로 다시 눌리지 않게 함
		button.focus_mode = Control.FOCUS_NONE
		button.position = Vector2(rect[0], rect[1])
		button.size = Vector2(rect[2], rect[3])

		# 투명 버튼처럼 사용
		button.text = ""
		button.modulate.a = 0.0

		# 디버그할 때는 아래처럼 잠깐 보이게 해도 됨
		# button.modulate.a = 0.25

		button.pressed.connect(
			func():
				await run_interaction(interaction_id)
		)

		interaction_buttons.add_child(button)
# exits 데이터를 읽어서 잠긴 문 클릭 버튼 생성
func create_exit_buttons(room):

	if not room.has("exits"):
		return

	for direction in room["exits"].keys():

		var exit_data = room["exits"][direction]

		# click_rect 없는 출구는 클릭 버튼 생성 안 함
		if not exit_data.has("click_rect"):
			continue

		var button = Button.new()

		button.focus_mode = Control.FOCUS_NONE

		var rect = exit_data["click_rect"]

		button.position = Vector2(rect[0], rect[1])
		button.size = Vector2(rect[2], rect[3])

		button.text = ""
		button.modulate.a = 0.0

		button.pressed.connect(
			func():
				await run_exit_interaction(direction)
		)

		interaction_buttons.add_child(button)
# 잠긴 문 상호작용 실행 함수
func run_exit_interaction(direction):

	if is_interacting or is_dialogue_showing or is_moving:
		return

	var room = rooms[current_room]

	if not room.has("exits"):
		return

	if not room["exits"].has(direction):
		return

	var exit_data = room["exits"][direction]

	var is_locked = exit_data.has("locked") and exit_data["locked"] == true

	var is_unlocked = false

	if exit_data.has("open_flag") and has_flag(exit_data["open_flag"]):
		is_unlocked = true

	# 이미 열린 문이면 바로 이동
	if not is_locked or is_unlocked:
		var use_shake = true

		if exit_data.has("move_effect") and exit_data["move_effect"] == "door":
			use_shake = false

		await move_to_room(exit_data["target"], use_shake, direction)
		return

	is_interacting = true
	set_interaction_buttons_disabled(true)

	# 필요한 아이템이 있으면 문 열기
	if exit_data.has("required_item") and has_item(exit_data["required_item"]):

		unlocked_sound.play()

		if exit_data.has("open_flag"):
			set_flag(exit_data["open_flag"])

		await show_dialogue(MSG_DOOR_UNLOCK)

		await effect(false, false, true, "")

		update_room()

		set_interaction_buttons_disabled(false)
		is_interacting = false
		return

	locked_sound.play()
	await show_dialogue(MSG_DOOR_LOCKED)

	set_interaction_buttons_disabled(false)
	is_interacting = false
# 인벤토리 상호작용 함수
func _on_bag_button_pressed():
	if is_inventory_open:
		close_inventory()
	else:
		open_inventory()
# 인벤토리 열기 함수
func open_inventory():
	if is_moving or is_interacting or is_dialogue_showing or is_choosing:
		return

	is_inventory_open = true
	inventory_ui.visible = true
	update_inventory_ui()
	clear_selected_item_info()
	bag_open_sound.play()

	# 인벤토리 열려 있을 때 상호작용 버튼 비활성화
	set_interaction_buttons_disabled(true)
# 인벤토리 닫기 함수
func close_inventory():
	is_inventory_open = false
	inventory_ui.visible = false
	bag_open_sound.play()

	# 인벤토리 닫으면 상호작용 버튼 다시 활성화
	set_interaction_buttons_disabled(false)
# 아이템 데이터 로드 함수
func load_items():
	var path = "res://data/items.json"

	if not FileAccess.file_exists(path):
		push_error("items.json 파일을 찾을 수 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("items.json 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("items.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("items.json 최상위 구조는 Dictionary여야 함")
		return false

	items = json.data
	print("items.json 로드 성공")
	return true
# 아이템 이름 가져오기 함수
func get_item_name(item_id):
	if not items.has(item_id):
		return item_id

	if not items[item_id].has("name"):
		return item_id

	return items[item_id]["name"]
# 인벤토리 UI 아이템 표시 갱신 함수
func update_inventory_ui():

	# 기존에 표시된 아이템 이미지 제거
	for child in inventory_slots.get_children():
		child.queue_free()

	# 현재 가진 아이템을 슬롯 위치 기준으로 표시
	for inventory_item in inventory:

		var item_id = inventory_item["id"]
		var start_slot = inventory_item["slot"]

		if not items.has(item_id):
			continue

		var item_data = items[item_id]

		if not item_data.has("image"):
			continue

		var item_width = 1
		var item_height = 1

		if item_data.has("width"):
			item_width = item_data["width"]

		if item_data.has("height"):
			item_height = item_data["height"]

		var col = start_slot % 4
		var row = start_slot / 4

		var item_button = TextureButton.new()
		# 아이템 버튼이 Space 입력을 가져가지 않게 함
		item_button.focus_mode = Control.FOCUS_NONE
		item_button.texture_normal = load(item_data["image"])
		item_button.ignore_texture_size = true
		item_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

		# 아이템이 시작되는 슬롯 위치
		item_button.position = Vector2(
			col * (inventory_slot_size + inventory_slot_gap),
			row * (inventory_slot_size + inventory_slot_gap)
		)

		# 아이템 크기: width/height만큼 슬롯을 차지
		item_button.size = Vector2(
			(inventory_slot_size * item_width) + (inventory_slot_gap * (item_width - 1)),
			(inventory_slot_size * item_height) + (inventory_slot_gap * (item_height - 1))
		)

		# 아이템 클릭 시 중앙 이미지/설명 표시
		item_button.pressed.connect(
			func():
				item_sound.play()
				show_selected_item_info(item_id)
		)

		inventory_slots.add_child(item_button)
# 선택된 아이템 정보 초기화 함수
func clear_selected_item_info():
	selected_item_image.texture = null
	selected_item_description.text = ""
# 선택된 아이템 정보를 중앙 이미지/설명칸에 표시
func show_selected_item_info(item_id):
	if not items.has(item_id):
		return

	var item_data = items[item_id]

	if item_data.has("image"):
		selected_item_image.texture = load(item_data["image"])

	if item_data.has("description"):
		selected_item_description.text = item_data["description"]
	else:
		selected_item_description.text = ""
# 아이템이 들어갈 수 있는 빈 슬롯 찾기 함수
func find_empty_slot(item_id):
	if not items.has(item_id):
		return -1

	var item_data = items[item_id]
	var item_width = item_data.get("width", 1)
	var item_height = item_data.get("height", 1)

	for slot in range(16):
		if can_place_item_at(slot, item_width, item_height):
			return slot

	return -1
# 특정 슬롯에 아이템을 놓을 수 있는지 확인하는 함수
func can_place_item_at(start_slot, item_width, item_height):
	var start_col = start_slot % 4
	var start_row = start_slot / 4

	# 오른쪽/아래로 가방 범위를 넘으면 배치 불가
	if start_col + item_width > 4:
		return false

	if start_row + item_height > 4:
		return false

	# 새 아이템이 차지할 슬롯 목록
	var target_slots = []

	for y in range(item_height):
		for x in range(item_width):
			var slot = (start_row + y) * 4 + (start_col + x)
			target_slots.append(slot)

	# 기존 아이템들과 겹치는지 확인
	for item in inventory:
		var occupied = get_occupied_slots(item)

		for slot in target_slots:
			if occupied.has(slot):
				return false

	return true	
# 아이템이 차지하는 슬롯 목록 반환 함수
func get_occupied_slots(inventory_item):
	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return []

	var item_data = items[item_id]
	var item_width = item_data.get("width", 1)
	var item_height = item_data.get("height", 1)

	var start_slot = inventory_item["slot"]
	var start_col = start_slot % 4
	var start_row = start_slot / 4

	var occupied = []

	for y in range(item_height):
		for x in range(item_width):
			var slot = (start_row + y) * 4 + (start_col + x)
			occupied.append(slot)

	return occupied	
	
	
	
	
	
	
	
	
	
	
