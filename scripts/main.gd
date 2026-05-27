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
@onready var slot_highlight = $InventoryUI/SlotHighlight
@onready var inventory_context_menu = $InventoryUI/InventoryContextMenu
@onready var use_button = $InventoryUI/InventoryContextMenu/MenuTexts/UseButton
@onready var equip_button = $InventoryUI/InventoryContextMenu/MenuTexts/EquipButton
@onready var drop_button = $InventoryUI/InventoryContextMenu/MenuTexts/DropButton
@onready var rotate_button = $InventoryUI/InventoryContextMenu/MenuTexts/RotateButton
@onready var equipped_weapon_text = $InventoryUI/EquippedWeaponText
@onready var healing_sound = $HealingSound
@onready var player_hp_text = $InventoryUI/PlayerHpText
@onready var equip_sound = $EquipSound
@onready var save_ui_open_sound = $SaveUiOpenSound
@onready var save_ui_close_sound = $SaveUiCloseSound
@onready var save_complete_sound = $SaveCompleteSound
@onready var speaker_portrait = $DialogueBox/SpeakerPortrait
@onready var speaker_name = $DialogueBox/SpeakerName
@onready var story_standing = $StoryStanding
@onready var bgm_player = $BGMPlayer

# 일반 변수 모음
var arrow_time = 0.0
var is_moving = false
var current_room = "hallway_2"
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
var selected_inventory_item = null
var dragged_item = null
var dragged_item_button = null
var dragged_item_original_position = Vector2.ZERO
var is_dragging_item = false
var pressed_item = null
var pressed_item_button = null
var pressed_mouse_position = Vector2.ZERO
var context_menu_item = null
var equipped_weapon = null
var player_hp = 75
var player_max_hp = 100
var characters = {}
var story_events = {}
var is_story_playing = false
var enemies = {}
var battle_scene = null
var projectiles = {}

# 상수 변수 모음
const MSG_NO_FORWARD = "더 이상 앞으로 갈 수 없다..."
const MSG_NO_BACK = "더 이상 뒤로 갈 수 없다..."
const MSG_NO_LEFT = "그쪽으로는 갈 수 없다..."
const MSG_NO_RIGHT = "그쪽으로는 갈 수 없다..."
const MSG_DOOR_LOCKED = "문이 굳게 잠겨있다..."
const MSG_DOOR_UNLOCK = "교실키로 문을 열었다."
const MSG_ITEM_GAINED_SUFFIX = "을 얻었다."
const BATTLE_SCENE_PATH = "res://scenes/battle_scene.tscn"

# 프레임 마다 실행 함수
func _process(delta):
	# 입력 우선순위:
	# 1. 선택지 조작
	# 2. 대사 넘기기
	# 3. 스토리 이벤트 중 일반 조작 차단
	# 4. 인벤토리 오픈시 상호작용 차단
	# 5. 이동/상호작용 차단
	# 6. 일반 이동 입력
	
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
	
	# 스토리 이벤트 중이면 일반 조작 차단
	if is_story_playing:
		return

	# 인벤토리가 열려 있으면 게임 이동/상호작용 입력을 막음
	if is_inventory_open:
		# 클릭 후 일정 거리 이상 움직이면 드래그 시작
		if not is_dragging_item:
			if pressed_item != null and pressed_item_button != null:

				var distance = get_global_mouse_position().distance_to(
					pressed_mouse_position
				)

				# 12픽셀 이상 움직이면 드래그 시작
				if distance > 12:
					start_drag_item(pressed_item, pressed_item_button)
		if is_dragging_item and dragged_item_button != null:
			dragged_item_button.global_position = get_global_mouse_position() - dragged_item_button.size / 2
			update_slot_highlight()

		if Input.is_action_just_pressed("esc"):
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
	
	play_bgm("res://sounds/bgm2.mp3")
	inventory_ui.visible = false
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
	
	# 캐릭터 로드 및 예외 처리	
	var character_success = load_characters()

	if not character_success:
		push_error("캐릭터 데이터 로드 실패로 게임 초기화 중단")
		return
		
	var story_success = load_story_events()

	if not story_success:
		push_error("스토리 이벤트 데이터 로드 실패로 게임 초기화 중단")
		return
		
	var enemies_success = load_enemies()

	if not enemies_success:
		push_error("적 데이터 로드 실패로 게임 초기화 중단")
		return
		
	var projectiles_success = load_projectiles()

	if not projectiles_success:
		push_error("투사체 데이터 로드 실패로 게임 초기화 중단")
		return

	# 테스트
	load_game(1)
	
	#await add_item("cutter_knife")
	await add_item("beverage_a")
	await add_item("beverage_a")
	await add_item("beverage_a")
	#await add_item("classroom_key")
	#await add_item("holy_sword")
	
	update_room()
	
	await get_tree().create_timer(1.0).timeout
	#start_battle("candle_student")
	start_battle("combined_candle_students_phase_01")
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
	
	# 방 진입시 스토리 이벤트 확인
	await check_room_enter_story()
	
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
func show_dialogue(text, mode = "normal"):
	# - 글자를 한 글자씩 출력
	# - 출력 중 입력하면 전체 문장 즉시 표시
	# - 출력 완료 후 입력하면 대사창 종료
	
	# 대화창 레이아웃 변경
	set_dialogue_layout(mode)

	if mode != "npc" and mode != "story":
		clear_speaker_ui()

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
	
	set_dialogue_layout("choice")
	
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
	# rooms.json의 interaction events 배열을 순서대로 실행
	# text / portrait / choices / item / flag / save 등을 처리
	
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

	if interaction.has("events"):
		await run_events(interaction["events"])
	else:
		push_error("events가 없는 interaction: " + interaction_id)

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
	if not items.has(item_id):
		return false

	var item_data = items[item_id]
	var is_stackable = item_data.get("stackable", false)
	var max_stack = item_data.get("max_stack", 1)

	# stackable 아이템이면 기존 같은 아이템의 count 증가
	if is_stackable:
		for inventory_item in inventory:
			if inventory_item["id"] == item_id:
				var current_count = inventory_item.get("count", 1)

				if current_count < max_stack:
					inventory_item["count"] = current_count + 1
					print("아이템 개수 증가: " + get_item_name(item_id) + " x" + str(inventory_item["count"]))
					return true

				# 이미 최대 개수면 새 슬롯에 추가 시도
				break

	# 비중첩 아이템은 기존처럼 중복 획득 방지
	else:
		if has_item(item_id):
			return false

	var empty_slot = find_empty_slot(item_id)

	if empty_slot == -1:
		await show_dialogue("가방에 공간이 없다.")
		return false

	var new_item = {
		"id": item_id,
		"slot": empty_slot
	}

	if is_stackable:
		new_item["count"] = 1

	inventory.append(new_item)

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
			
		# 잠긴 출구인지 확인
		var is_locked = exit_data.has("locked") and exit_data["locked"] == true

		# 이미 열렸는지 확인
		var is_unlocked = false
		if exit_data.has("open_flag") and has_flag(exit_data["open_flag"]):
			is_unlocked = true

		# 잠겨 있고 아직 열리지 않은 출구만 마우스 클릭 버튼 생성
		if not is_locked or is_unlocked:
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

		consume_item_if_needed(exit_data["required_item"])
		
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
	# 스토리 이벤트 중이면 일반 조작 차단
	if is_story_playing:
		return
	
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
	
	clear_selected_item_info()
	update_inventory_ui()
	update_equipped_weapon_ui()
	update_player_status_ui()
	
	bag_open_sound.play()

	set_interaction_buttons_disabled(true)
# 인벤토리 닫기 함수
func close_inventory():
	is_inventory_open = false
	inventory_ui.visible = false
	bag_open_sound.play()
	
	# 드래그 중이었다면 드래그 상태 초기화
	if is_dragging_item and dragged_item_button != null:
		dragged_item_button.position = dragged_item_original_position
		dragged_item_button.z_index = 0

	is_dragging_item = false
	dragged_item = null
	dragged_item_button = null
	pressed_item = null
	pressed_item_button = null
	slot_highlight.visible = false
	
	selected_inventory_item = null
	clear_selected_item_info()
	close_context_menu()

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
		var start_slot = int(inventory_item["slot"])

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
		var row = floori(start_slot / 4.0)

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
		
		# 현재 선택된 아이템이면 밝게 표시
		if selected_inventory_item == inventory_item:
			item_button.modulate = Color(1.4, 1.4, 1.4, 1.0)
		else:
			item_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

		item_button.pressed.connect(
			func():
				item_sound.play()
				selected_inventory_item = inventory_item
				show_selected_item_info(inventory_item)
				update_inventory_ui()
		)
		
		item_button.gui_input.connect(
			func(event):

				# 마우스 버튼 이벤트만 처리
				if event is InputEventMouseButton:

					if event.button_index == MOUSE_BUTTON_LEFT:
						if event.pressed:
							pressed_item = inventory_item
							pressed_item_button = item_button
							pressed_mouse_position = get_global_mouse_position()
						else:
							if is_dragging_item:
								stop_drag_item()
							pressed_item = null
							pressed_item_button = null
					
					if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
						item_sound.play()
						selected_inventory_item = inventory_item
						show_selected_item_info(inventory_item)
						update_inventory_ui()
						open_context_menu(inventory_item)
		)

		inventory_slots.add_child(item_button)
# 선택된 아이템 정보 초기화 함수
func clear_selected_item_info():
	selected_item_image.texture = null
	selected_item_description.text = ""
# 선택된 아이템 정보를 중앙 이미지/설명칸에 표시
func show_selected_item_info(inventory_item):
	
	var item_id = inventory_item["id"]
	
	if not items.has(item_id):
		return

	var item_data = items[item_id]

	if item_data.has("image"):
		selected_item_image.texture = load(item_data["image"])

	var description_text = ""
	
	if item_data.has("description"):
		description_text = item_data["description"]
		
	# stackable 아이템이면 보유 개수 표시
	if inventory_item != null:
		if inventory_item.has("count"):
			description_text = "보유 개수 : " + str(int(inventory_item["count"])) + "\n\n" + description_text

	selected_item_description.text = description_text
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

	var start_slot = int(inventory_item["slot"])
	var start_col = start_slot % 4
	var start_row = floori(start_slot / 4.0)

	var occupied = []

	for y in range(item_height):
		for x in range(item_width):
			var slot = (start_row + y) * 4 + (start_col + x)
			occupied.append(slot)

	return occupied	
# 아이템 드래그 시작 함수
func start_drag_item(inventory_item, item_button):
	is_dragging_item = true
	dragged_item = inventory_item
	dragged_item_button = item_button
	dragged_item_original_position = item_button.position
	
	item_button.z_index = 100
	item_sound.play()
# 아이템 드래그 종료 함수
func stop_drag_item():

	if dragged_item_button == null:
		return

	var item_id = dragged_item["id"]
	var item_data = items[item_id]

	var item_width = item_data.get("width", 1)
	var item_height = item_data.get("height", 1)

	var target_slot = get_slot_from_mouse_position()

	# 정상 슬롯이고 배치 가능하면 이동
	if target_slot != -1:
		if can_place_item_at_except(
			target_slot,
			item_width,
			item_height,
			dragged_item
		):

			dragged_item["slot"] = target_slot
			update_inventory_ui()

		# 놓을 수 없는 위치면 원래 자리 복귀
		else:
			dragged_item_button.position = dragged_item_original_position

	# 가방 밖이면 원래 자리 복귀
	else:
		dragged_item_button.position = dragged_item_original_position

	dragged_item_button.z_index = 0

	is_dragging_item = false
	dragged_item = null
	dragged_item_button = null
	slot_highlight.visible = false
# 마우스 위치 기준 슬롯 번호 계산 함수
func get_slot_from_mouse_position():

	var local_mouse = inventory_slots.get_local_mouse_position()

	var slot_x = int(local_mouse.x / (inventory_slot_size + inventory_slot_gap))
	var slot_y = int(local_mouse.y / (inventory_slot_size + inventory_slot_gap))

	# 가방 범위 밖이면 실패
	if slot_x < 0 or slot_x >= 4:
		return -1

	if slot_y < 0 or slot_y >= 4:
		return -1

	return slot_y * 4 + slot_x	
# 특정 아이템을 제외하고 슬롯 배치 가능 여부 확인
func can_place_item_at_except(start_slot, item_width, item_height, ignored_item):

	var start_col = start_slot % 4
	var start_row = start_slot / 4

	# 가방 범위 초과
	if start_col + item_width > 4:
		return false

	if start_row + item_height > 4:
		return false

	var target_slots = []

	for y in range(item_height):
		for x in range(item_width):
			var slot = (start_row + y) * 4 + (start_col + x)
			target_slots.append(slot)

	for item in inventory:

		# 현재 드래그 중인 아이템은 무시
		if item == ignored_item:
			continue

		var occupied = get_occupied_slots(item)

		for slot in target_slots:
			if occupied.has(slot):
				return false

	return true	
# 드래그 중 아이템을 놓을 위치 하이라이트 갱신 함수
func update_slot_highlight():
	if not is_dragging_item:
		slot_highlight.visible = false
		return

	if dragged_item == null:
		slot_highlight.visible = false
		return

	var target_slot = get_slot_from_mouse_position()

	if target_slot == -1:
		slot_highlight.visible = false
		return

	var item_id = dragged_item["id"]
	var item_data = items[item_id]

	var item_width = item_data.get("width", 1)
	var item_height = item_data.get("height", 1)

	var can_place = can_place_item_at_except(
		target_slot,
		item_width,
		item_height,
		dragged_item
	)

	var col = target_slot % 4
	var row = floori(target_slot / 4.0)

	slot_highlight.position = inventory_slots.position + Vector2(
		col * (inventory_slot_size + inventory_slot_gap),
		row * (inventory_slot_size + inventory_slot_gap)
	)

	slot_highlight.size = Vector2(
		(inventory_slot_size * item_width) + (inventory_slot_gap * (item_width - 1)),
		(inventory_slot_size * item_height) + (inventory_slot_gap * (item_height - 1))
	)

	if can_place:
		slot_highlight.color = Color(0, 1, 0, 0.025)
	else:
		slot_highlight.color = Color(1, 0, 0, 0.025)

	slot_highlight.visible = true	
# 인벤토리 우클릭 메뉴 열기 함수
func open_context_menu(inventory_item):
	
	if inventory_context_menu.visible and context_menu_item == inventory_item:
		close_context_menu()
		return

	context_menu_item = inventory_item

	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]
	var item_type = item_data.get("type", "")

	# 기본적으로 전부 숨김
	use_button.visible = false
	equip_button.visible = false
	drop_button.visible = false
	rotate_button.visible = false

	# 타입별 메뉴 표시
	if item_type == "weapon":
		equip_button.visible = true
		drop_button.visible = true
		rotate_button.visible = true

		if equipped_weapon == inventory_item:
			equip_button.text = "해제"
		else:
			equip_button.text = "장착"

	elif item_type == "consumable":
		use_button.visible = true
		drop_button.visible = true

	elif item_type == "key":
		drop_button.visible = true

	else:
		drop_button.visible = true

	inventory_context_menu.visible = true
	inventory_context_menu.global_position = get_global_mouse_position()
# 인벤토리 우클릭 메뉴 닫기 함수
func close_context_menu():
	context_menu_item = null
	inventory_context_menu.visible = false	
# 아이템 제거 함수
func remove_item(inventory_item):
	if inventory_item == null:
		return false

	if inventory.has(inventory_item):

		# 장착 중인 아이템을 제거하려는 경우 먼저 장착 해제
		if equipped_weapon == inventory_item:
			equipped_weapon = null
			update_equipped_weapon_ui()

		inventory.erase(inventory_item)

		if selected_inventory_item == inventory_item:
			selected_inventory_item = null
			clear_selected_item_info()

		if context_menu_item == inventory_item:
			close_context_menu()

		update_inventory_ui()
		return true

	return false
# 아이템 사용 시 소모 처리 함수
func consume_item_if_needed(item_id):

	if not items.has(item_id):
		return

	var item_data = items[item_id]

	# consumed_on_use가 없거나 false면 소모 안 함
	if not item_data.get("consumed_on_use", false):
		return

	# 해당 아이템 찾기
	for inventory_item in inventory:
		if inventory_item["id"] == item_id:

			# stackable 아이템이면 count만 1 감소
			if inventory_item.has("count"):
				inventory_item["count"] -= 1

				print("아이템 개수 감소: " + item_id + " x" + str(inventory_item["count"]))

				# count가 0 이하가 되었을 때만 실제 삭제
				if inventory_item["count"] <= 0:
					remove_item(inventory_item)

				return

			# stackable이 아닌 아이템은 기존처럼 삭제
			remove_item(inventory_item)
			print("아이템 소모: " + item_id)
			return
# 아이템 버리기 버튼 함수
func _on_drop_button_pressed():
	if context_menu_item == null:
		return

	item_sound.play()
	remove_item(context_menu_item)
# 아이템 장착 함수
func equip_item(inventory_item):
	if inventory_item == null:
		return

	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]

	if item_data.get("type", "") != "weapon":
		return

	if equipped_weapon == inventory_item:
		equipped_weapon = null
		print(get_item_name(item_id) + " 해제")
	else:
		equipped_weapon = inventory_item
		print(get_item_name(item_id) + " 장착")

	update_equipped_weapon_ui()
	close_context_menu()
# 아이템 장착 버튼 함수
func _on_equip_button_pressed():
	if context_menu_item == null:
		return

	equip_sound.play()
	equip_item(context_menu_item)
# 장착 무기 UI 갱신 함수
func update_equipped_weapon_ui():

	# 아무것도 장착하지 않았으면 기본 무기 사용
	var item_id = "fist"

	if equipped_weapon != null:
		item_id = equipped_weapon["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]

	# 이름 표시
	if item_id == "fist":
		equipped_weapon_text.text = "무기 없음"
	else:
		equipped_weapon_text.text = get_item_name(item_id)

	# 중앙 이미지 표시
	if item_data.has("image"):
		selected_item_image.texture = load(item_data["image"])

	# 설명 표시
	if item_data.has("description"):
		selected_item_description.text = item_data["description"]
# 아이템 사용 함수
func use_item(inventory_item):
	if inventory_item == null:
		return

	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]
	var item_type = item_data.get("type", "")

	if item_type != "consumable":
		return

	if item_data.has("heal"):
		player_hp += item_data["heal"]

		if player_hp > player_max_hp:
			player_hp = player_max_hp

		print("현재 체력: " + str(int(player_hp)))

	consume_item_if_needed(item_id)
	update_inventory_ui()
	# 아이템 사용 횟수 즉시 반영
	if selected_inventory_item != null and inventory.has(selected_inventory_item):
		show_selected_item_info(selected_inventory_item)
	else:
		clear_selected_item_info()
	update_player_status_ui()
	close_context_menu()	
# 아이템 사용 버튼 함수
func _on_use_button_pressed():
	if context_menu_item == null:
		return

	healing_sound.play()
	use_item(context_menu_item)
# 플레이어 체력 UI 갱신 함수
func update_player_status_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
# 저장할 게임 데이터 생성 함수
func get_save_data():
	var equipped_weapon_slot = -1

	if equipped_weapon != null:
		equipped_weapon_slot = int(equipped_weapon["slot"])

	return {
		"room": {
			"current_room": current_room
		},
		"player": {
			"hp": player_hp,
			"max_hp": player_max_hp,
			"equipped_weapon_slot": equipped_weapon_slot
		},
		"inventory": inventory,
		"flags": flags
	}
# 저장 파일 경로 반환 함수
func get_save_path(slot_index):
	
	return "user://save_slot_" + str(slot_index) + ".json"
# 게임 저장 함수
func save_game(slot_index):
	var save_data = get_save_data()
	var json_text = JSON.stringify(save_data, "\t")
	var path = get_save_path(slot_index)

	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("저장 파일 열기 실패: " + path)
		return false

	file.store_string(json_text)
	file.close()

	print("게임 저장 완료: " + path)
	return true
# 저장 포인트 실행 함수
func run_save_point():
	save_ui_open_sound.play()

	var choices = [
		{ "text": "예" },
		{ "text": "아니오" }
	]

	var selected_index = await show_choices(choices)

	if selected_index == 0:
		var success = save_game(1)

		if success:
			save_complete_sound.play()
			await show_dialogue("저장 완료.")
		else:
			await show_dialogue("저장에 실패했다.")
	else:
		save_ui_close_sound.play()	
# 게임 불러오기 함수
func load_game(slot_index):
	var path = get_save_path(slot_index)

	if not FileAccess.file_exists(path):
		push_error("저장 파일이 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("저장 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("저장 파일 파싱 실패: " + json.get_error_message())
		return false

	var save_data = json.data

	var room_data = save_data.get("room", {})
	var player_data = save_data.get("player", {})

	current_room = room_data.get("current_room", "hallway_1")

	player_hp = player_data.get("hp", 100)
	player_max_hp = player_data.get("max_hp", 100)

	inventory = save_data.get("inventory", [])
	flags = save_data.get("flags", {})

	restore_equipped_weapon(player_data.get("equipped_weapon_slot", -1))

	update_room()
	update_inventory_ui()
	update_equipped_weapon_ui()
	update_player_status_ui()
	
	await effect(false, false, true, "")

	print("게임 불러오기 완료: " + path)
	return true	
# 저장된 장착 무기 복구 함수
func restore_equipped_weapon(saved_slot):
	equipped_weapon = null

	if saved_slot == -1:
		return

	for inventory_item in inventory:
		if inventory_item.has("slot") and int(inventory_item["slot"]) == int(saved_slot):
			equipped_weapon = inventory_item
			return
# 대화창 레이아웃 변경 함수
func set_dialogue_layout(mode):
	
	# choice
	if mode == "choice":
		speaker_portrait.visible = false
		speaker_name.visible = false
	
		$DialogueBox/DialogueText.position = Vector2(50, 40)
		$DialogueBox/DialogueText.size = Vector2(1600, 100)

		choice_box.visible = true
		choice_box.position = Vector2(50, 140)
		choice_box.size = Vector2(1600, 140)
	# npc
	elif mode == "npc":
		speaker_portrait.visible = true
		speaker_name.visible = true
		
		speaker_name.position = Vector2(280, 20)
		speaker_name.size = Vector2(400, 40)

		$DialogueBox/DialogueText.position = Vector2(290, 70)
		$DialogueBox/DialogueText.size = Vector2(1360, 180)

		choice_box.visible = false
	# stroy	
	elif mode == "story":
		speaker_portrait.visible = false
		speaker_name.visible = true

		speaker_name.position = Vector2(50, 25)
		speaker_name.size = Vector2(400, 40)

		$DialogueBox/DialogueText.position = Vector2(50, 80)
		$DialogueBox/DialogueText.size = Vector2(1600, 180)

		choice_box.visible = false
	# normal
	else:
		speaker_portrait.visible = false
		speaker_name.visible = false
		
		$DialogueBox/DialogueText.position = Vector2(50, 40)
		$DialogueBox/DialogueText.size = Vector2(1600, 220)

		choice_box.visible = false	
# NPC 대화 UI 초기화 함수
func clear_speaker_ui():
	speaker_portrait.visible = false
	speaker_name.visible = false
# NPC 대화 출력 함수
func show_npc_dialogue(character_id, emotion, text):

	if not characters.has(character_id):
		push_error("존재하지 않는 캐릭터: " + character_id)
		return

	var character_data = characters[character_id]

	speaker_name.text = character_data["name"]

	if character_data.has("portrait"):
		var portrait_data = character_data["portrait"]

		if portrait_data.has(emotion):
			speaker_portrait.texture = load(portrait_data[emotion])

	await show_dialogue(text, "npc")
# NPC 캐릭터 데이터 로드 함수
func load_characters():
	var path = "res://data/characters.json"

	if not FileAccess.file_exists(path):
		push_error("characters.json 파일을 찾을 수 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("characters.json 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("characters.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("characters.json 최상위 구조는 Dictionary여야 함")
		return false

	characters = json.data
	print("characters.json 로드 성공")
	return true	
# events 배열을 순서대로 실행하는 함수
func run_events(events):
	for event in events:
		var event_type = event.get("type", "")

		if event_type == "text":
			await show_dialogue(event.get("text", ""))

		elif event_type == "portrait":
			await show_npc_dialogue(
				event.get("character", ""),
				event.get("emotion", "normal"),
				event.get("text", "")
			)

		elif event_type == "save":
			await run_save_point()

		elif event_type == "item":
			var item_id = event.get("item", "")
			var added = await add_item(item_id)

			if added:
				await show_dialogue("『" + get_item_name(item_id) + "』" + MSG_ITEM_GAINED_SUFFIX)

		elif event_type == "flag":
			set_flag(event.get("flag", ""))

		elif event_type == "choices":
			await run_event_choices(event.get("choices", []))

		else:
			push_error("알 수 없는 event type: " + event_type)
# events 방식 선택지 실행 함수
func run_event_choices(choices):
	if choices.size() == 0:
		return

	var selected_index = await show_choices(choices)
	var selected_choice = choices[selected_index]

	if selected_choice.has("flag") and has_flag(selected_choice["flag"]):
		if selected_choice.has("already_events"):
			await run_events(selected_choice["already_events"])
		return

	if selected_choice.has("events"):
		await run_events(selected_choice["events"])

	if selected_choice.has("flag"):
		set_flag(selected_choice["flag"])
# 스토리 이벤트 데이터 로드 함수
func load_story_events():
	var path = "res://data/story_events.json"

	if not FileAccess.file_exists(path):
		push_error("story_events.json 파일을 찾을 수 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("story_events.json 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("story_events.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("story_events.json 최상위 구조는 Dictionary여야 함")
		return false

	story_events = json.data
	print("story_events.json 로드 성공")
	return true
# 스토리 스탠딩 CG 표시 함수
func show_story_standing(character_id, emotion, position_name = "center"):

	if not characters.has(character_id):
		push_error("존재하지 않는 캐릭터: " + character_id)
		return

	var character_data = characters[character_id]

	if not character_data.has("standing"):
		push_error("standing 데이터가 없는 캐릭터: " + character_id)
		return

	var standing_data = character_data["standing"]

	if not standing_data.has(emotion):
		push_error("존재하지 않는 standing emotion: " + emotion)
		return

	story_standing.texture = load(standing_data[emotion])
	story_standing.visible = true

	if position_name == "center":
		story_standing.position = Vector2(770, 140)

	elif position_name == "left":
		story_standing.position = Vector2(420, 140)

	elif position_name == "right":
		story_standing.position = Vector2(1120, 140)
		
	story_standing.modulate.a = 0.0
	story_standing.visible = true

	var tween = create_tween()
	tween.tween_property(
		story_standing,
		"modulate:a",
		1.0,
		0.35
	)

	await tween.finished
# 스토리 스탠딩 CG 숨김 함수
func hide_story_standing():
	if not story_standing.visible:
		return

	var tween = create_tween()
	tween.tween_property(
		story_standing,
		"modulate:a",
		0.0,
		0.25
	)

	await tween.finished

	story_standing.visible = false
	story_standing.texture = null
	story_standing.modulate.a = 1.0
# 스토리 이벤트 중 게임 UI 숨김 함수
func hide_game_ui():
	$BagButton.visible = false

	for dir in move_arrows.keys():
		move_arrows[dir].visible = false

	set_interaction_buttons_disabled(true)
# 스토리 이벤트 종료 후 게임 UI 복구 함수
func show_game_ui():
	await hide_story_standing()

	$BagButton.visible = true

	update_room()

	set_interaction_buttons_disabled(false)
# 스토리 이벤트 실행 함수
func run_story_event(event_id):

	if is_story_playing:
		return

	if not story_events.has(event_id):
		push_error("존재하지 않는 스토리 이벤트: " + event_id)
		return

	var story_data = story_events[event_id]

	if story_data.has("start_flag") and has_flag(story_data["start_flag"]):
		return

	if not story_data.has("events"):
		push_error("events가 없는 스토리 이벤트: " + event_id)
		return

	is_story_playing = true
	set_interaction_buttons_disabled(true)

	await run_story_events(story_data["events"])

	is_story_playing = false
# 스토리 events 배열 실행 함수
func run_story_events(events):
	for event in events:
		var event_type = event.get("type", "")

		if event_type == "hide_game_ui":
			hide_game_ui()

		elif event_type == "show_game_ui":
			show_game_ui()

		elif event_type == "fade":
			await effect(false, false, true, "")
			
		elif event_type == "bgm":
			play_bgm(event.get("path", ""))
			
		elif event_type == "stop_bgm":
			stop_bgm()
			
		elif event_type == "change_room":
			change_room_by_story(event.get("room", ""))
		
		elif event_type == "background":
			change_background(event.get("path", ""))		

		elif event_type == "standing":
			await show_story_standing(
				event.get("character", ""),
				event.get("emotion", "normal"),
				event.get("position", "center")
			)

		elif event_type == "story_dialogue":
			await show_story_dialogue(
				event.get("name", ""),
				event.get("text", "")
			)

		elif event_type == "choices":
			await run_story_choices(event.get("choices", []))

		elif event_type == "flag":
			set_flag(event.get("flag", ""))

		else:
			push_error("알 수 없는 story event type: " + event_type)
# 스토리 이벤트 선택지 실행 함수
func run_story_choices(choices):
	if choices.size() == 0:
		return

	var selected_index = await show_choices(choices)
	var selected_choice = choices[selected_index]

	if selected_choice.has("events"):
		await run_story_events(selected_choice["events"])
# 스토리 대화 출력 함수
func show_story_dialogue(speaker, text):
	set_dialogue_layout("normal")

	speaker_name.visible = true
	speaker_name.text = speaker

	$DialogueBox/DialogueText.position = Vector2(50, 80)
	$DialogueBox/DialogueText.size = Vector2(1600, 180)

	await show_dialogue(text, "story")
# 방 입장 시 실행할 스토리 이벤트 확인 함수
func check_room_enter_story():
	var room = rooms[current_room]

	if not room.has("enter_story"):
		return

	var enter_story = room["enter_story"]

	if not enter_story.has("event"):
		return

	var event_id = enter_story["event"]

	# 특정 플래그가 없을 때만 실행
	if enter_story.has("required_flag_missing"):
		var flag_id = enter_story["required_flag_missing"]

		if has_flag(flag_id):
			return

	await run_story_event(event_id)
# BGM 재생 함수
func play_bgm(path, volume_db = -5.0, loop = true):
	if path == "":
		return

	var stream = load(path)

	# 반복 재생 설정
	if stream is AudioStreamMP3:
		stream.loop = loop
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop

	bgm_player.stream = stream
	bgm_player.volume_db = volume_db
	bgm_player.play()
# BGM 정지 함수
func stop_bgm():
	bgm_player.stop()
# 배경 변경 함수
func change_background(path):
	if path == "":
		return

	background.texture = load(path)
# 스토리 이벤트용 방 변경 함수
func change_room_by_story(room_id):
	if not rooms.has(room_id):
		push_error("존재하지 않는 방: " + room_id)
		return

	current_room = room_id
	update_room()
# 적 데이터 로드 함수
func load_enemies():
	var path = "res://data/enemies.json"

	if not FileAccess.file_exists(path):
		push_error("enemies.json 파일을 찾을 수 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("enemies.json 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("enemies.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("enemies.json 최상위 구조는 Dictionary여야 함")
		return false

	enemies = json.data
	print("enemies.json 로드 성공")
	return true
# 전투 시작 함수
func start_battle(enemy_id):
	if not enemies.has(enemy_id):
		push_error("존재하지 않는 적: " + enemy_id)
		return
	
	is_story_playing = true
	hide_game_ui()

	var battle_scene_resource = load(BATTLE_SCENE_PATH)
	battle_scene = battle_scene_resource.instantiate()

	add_child(battle_scene)
	battle_scene.battle_finished.connect(end_battle)

	# 전투신으로 넘겨줄 로드한 데이터들 모음
	var battle_data = {
		"enemy_id": enemy_id,
		"enemy_data": enemies[enemy_id],
		"enemies": enemies,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_portrait": characters["protagonist"]["portrait"]["normal"],
		"items": items,
		"equipped_weapon": equipped_weapon,
		"inventory": inventory,
		"projectiles": projectiles
	}
	
	if bgm_player.playing:
		bgm_player.stop()

	battle_scene.setup_battle(battle_data)
# 전투 종료 함수
func end_battle(result_data):
	player_hp = result_data.get("player_hp", player_hp)
	inventory = result_data.get("inventory", inventory)

	if battle_scene != null:
		battle_scene.queue_free()
		battle_scene = null

	is_story_playing = false
	show_game_ui()
	
	bgm_player.play()

	print("전투 종료 결과: " + str(result_data.get("result", "")))
# 탄막 데이터 로드 함수
func load_projectiles():
	var path = "res://data/projectiles.json"

	if not FileAccess.file_exists(path):
		push_error("projectiles.json 파일을 찾을 수 없음: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("projectiles.json 파일 열기 실패: " + path)
		return false

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("projectiles.json 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("projectiles.json 최상위 구조는 Dictionary여야 함")
		return false

	projectiles = json.data
	print("projectiles.json 로드 성공")
	return true
