extends Control

# onready 변수 모음
@onready var background = $Background
@onready var footstep_sound = $FootstepSound
@onready var fade = $Fade
@onready var bag_button = $BagButton
@onready var atmosphere_fade = $AtmosphereFade
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
@onready var encounter_danger_overlay = $EncounterDangerOverlay
@onready var encounter_heartbeat_sound = $EncounterHeartbeatSound
@onready var inventory_arrange_ui = $InventoryArrangeUI
@onready var arrange_background = $InventoryArrangeUI/ArrangeBackground
@onready var arrange_left_items = $InventoryArrangeUI/ArrangeLeftItems
@onready var arrange_right_items = $InventoryArrangeUI/ArrangeRightItems
@onready var dialogue_box = $DialogueBox
@onready var arrange_discard_notice_label = $InventoryArrangeUI/ArrangeDiscardNoticeLabel
@onready var arrange_selected_item_image = $InventoryArrangeUI/ArrangeSelectedItemImage
@onready var arrange_selected_item_text = $InventoryArrangeUI/ArrangeSelectedItemText
@onready var arrange_slot_highlight_container = $InventoryArrangeUI/ArrangeSlotHighlightContainer
@onready var arrange_selected_focus_container = $InventoryArrangeUI/ArrangeSelectedFocusContainer
@onready var inventory_portrait = get_node_or_null("InventoryUI/InventoryPortrait")

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
# 기존 인벤토리 변수
var inventory_slot_size = 150
var inventory_slot_gap = 5
var inventory_cols = 4
var inventory_rows = 4
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
var encounters = {}
var encounter_events = {}
var encounter_overlay_tween = null
# 도주 후 여유 시간 변수
var random_encounter_cooldown_steps = 0
# 가방에 넣지 못한 임시 획득 아이템 목록
var pending_loot = []
# 인벤토리 정리 화면 관련 변수
var is_inventory_arrange_open = false
var inventory_arrange_mode = ""
var arrange_left_inventory = []
# 인벤토리 정리 UI 좌표 설정
var arrange_left_grid_position = Vector2(55, 60)
var arrange_right_grid_position = Vector2(1200, 190)
var arrange_slot_size = 150
var arrange_left_cols = 3
var arrange_left_rows = 6
var arrange_right_cols = 4
var arrange_right_rows = 4
var arrange_slot_gap = 5
# 인벤토리 정리 화면 드래그 변수
var arrange_pressed_item = null
var arrange_pressed_button = null
var arrange_pressed_source = ""
var arrange_pressed_mouse_position = Vector2.ZERO
var arrange_dragged_item = null
var arrange_dragged_button = null
var arrange_dragged_source = ""
var arrange_dragged_original_slot = -1
var arrange_dragged_original_global_position = Vector2.ZERO
var is_arrange_dragging_item = false
# 정리 화면 선택 포커스 변수
var selected_arrange_item = null
var selected_arrange_source = ""
var equipped_weapon_text_scroll = null
var selected_item_description_scroll = null
var arrange_selected_item_text_scroll = null

# 디버그 관련 상수 변수 모음
# false
# true
# consumable_test
# my_test
# combined_candle_students_phase_01
# candle_student
const DEBUG_ADD_START_ITEMS = true
const DEBUG_OPEN_PENDING_LOOT_TEST = false
const DEBUG_START_BATTLE_TEST = false
const DEBUG_TEST_BATTLE_ENEMY_ID = "combined_candle_students_phase_01"
const DEBUG_BATTLE_START_DELAY = 1.0
const DEBUG_START_ITEM_PRESET = "my_test"

# 상수 변수 모음
const MSG_NO_FORWARD = "더 이상 앞으로 갈 수 없다..."
const MSG_NO_BACK = "더 이상 뒤로 갈 수 없다..."
const MSG_NO_LEFT = "그쪽으로는 갈 수 없다..."
const MSG_NO_RIGHT = "그쪽으로는 갈 수 없다..."
const MSG_DOOR_LOCKED = "문이 굳게 잠겨있다..."
const MSG_DOOR_UNLOCK = "교실키로 문을 열었다."
const MSG_ITEM_GAINED_SUFFIX = "을 얻었다."
const BATTLE_SCENE_PATH = "res://scenes/battle_scene.tscn"
const STAT_GOOD_COLOR = "#55ff77"
const STAT_BAD_COLOR = "#ff5555"
const STAT_INFO_COLOR = "#88ccff"

# ============================================================
# 게임 시작 관련 함수 모음
# ============================================================

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
		
	# 인벤토리 정리 화면이 열려 있으면 정리 화면 입력만 처리
	if is_inventory_arrange_open:
		if not is_arrange_dragging_item:
			if arrange_pressed_item != null and arrange_pressed_button != null:
				var distance = get_global_mouse_position().distance_to(arrange_pressed_mouse_position)

				if distance > 12:
					start_arrange_drag_item(
						arrange_pressed_item,
						arrange_pressed_button,
						arrange_pressed_source
					)

		if is_arrange_dragging_item and arrange_dragged_button != null:
			arrange_dragged_button.global_position = get_global_mouse_position() - arrange_dragged_button.size / 2
			update_arrange_drag_slot_highlight()

		if Input.is_action_just_pressed("esc"):
			close_inventory_arrange()
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
# 게임 시작 시 UI의 기본 표시 상태를 초기화하는 함수
func setup_initial_ui_state():
	inventory_ui.visible = false
	inventory_arrange_ui.visible = false

	background.scale = Vector2(1, 1)

	encounter_danger_overlay.color = Color(1, 0, 0, 0)
	# start_random_encounter_effect()에서 다시 visible = true를 해주기 때문에 문제 없음
	encounter_danger_overlay.visible = false
	encounter_danger_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	arrange_discard_notice_label.visible = false

	arrange_selected_item_image.texture = null
	arrange_selected_item_image.visible = false

	if arrange_selected_item_text is RichTextLabel:
		arrange_selected_item_text.clear()
	else:
		arrange_selected_item_text.text = ""

	arrange_selected_item_text.visible = false
# 게임 시작 시 UI 레이어 순서를 초기화하는 함수
func setup_initial_z_index():
	atmosphere_fade.z_index = 1

	arrow_down.z_index = 2
	arrow_up.z_index = 2
	arrow_left.z_index = 2
	arrow_right.z_index = 2
	bag_button.z_index = 2

	story_standing.z_index = 5
	arrange_slot_highlight_container.z_index = 5

	# 인벤토리 정리 아이템 아이콘 레이어
	arrange_left_items.z_index = 10
	arrange_right_items.z_index = 10

	arrange_selected_focus_container.z_index = 20
	dialogue_box.z_index = 20

	inventory_ui.z_index = 30
	inventory_arrange_ui.z_index = 31

	inventory_context_menu.z_index = 100
	inventory_context_menu.mouse_filter = Control.MOUSE_FILTER_STOP

	encounter_danger_overlay.z_index = 4095

	# Fade는 최상단
	fade.z_index = 4096
# 게임 시작 시 UI 보조 기능과 버튼 연결을 초기화하는 함수
func setup_initial_ui_helpers():
	setup_equipped_weapon_text_scroll()
	setup_selected_item_description_scrolls()

	encounter_heartbeat_sound.stop()

	connect_inventory_context_menu_buttons()

	# 버튼이 키보드 포커스를 가져가지 않게 설정
	# Space를 눌렀을 때 버튼이 다시 눌리는 문제 방지
	bag_button.focus_mode = Control.FOCUS_NONE
# 처음에 한번 실행 함수
func _ready():   
	
	# 시작시 기본 브금 실행
	play_bgm("res://sounds/bgm2.mp3")

	# 게임 시작 시 UI의 기본 표시 상태를 초기화하는 함수
	setup_initial_ui_state()
	
	# 게임 시작 시 UI 레이어 순서를 초기화하는 함수
	setup_initial_z_index()
	
	# 게임 시작 시 UI 보조 기능과 버튼 연결을 초기화하는 함수
	setup_initial_ui_helpers()
	
	# 게임 시작 데이터 로드
	if not load_startup_game_data():
		return

	# 세이브 파일 로드 테스트
	#load_game(1)
	
	# 디버그 아이템 테스트
	await add_debug_start_items()
	
	# 디버그 방 갱신 전 개발 테스트 흐름, 아이템 정리 화면 테스트
	await run_debug_before_room_update_flow()

	# 방 갱신 함수 호출
	update_room()
	
	# 디버그 방 갱신 후 개발 테스트 흐름, 적 배틀 테스트
	await run_debug_after_room_update_flow()
# 게임 시작에 필요한 데이터 로드 함수
func load_startup_game_data():
	var load_steps = [
		{
			"loader": Callable(self, "load_rooms"),
			"error": "방 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_items"),
			"error": "아이템 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_characters"),
			"error": "캐릭터 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_story_events"),
			"error": "스토리 이벤트 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_enemies"),
			"error": "적 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_projectiles"),
			"error": "투사체 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_encounters"),
			"error": "인카운터 데이터 로드 실패로 게임 초기화 중단"
		},
		{
			"loader": Callable(self, "load_encounter_events"),
			"error": "인카운터 이벤트 데이터 로드 실패로 게임 초기화 중단"
		}
	]

	for step in load_steps:
		var loader = step["loader"]
		var success = loader.call()

		if success != true:
			push_error(step["error"])
			return false

	return true

# ============================================================
# 전투 관련 함수 모음
# ============================================================

# enemy_id 기준으로 적 데이터 가져오기 함수
func get_enemy_data_by_id(enemy_id, show_error = true):
	if enemy_id == "":
		if show_error:
			push_error("적 ID가 비어있음")
		return {}

	if not enemies.has(enemy_id):
		if show_error:
			push_error("존재하지 않는 적: " + str(enemy_id))
		return {}

	var enemy_data = enemies[enemy_id]

	if typeof(enemy_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("적 데이터가 Dictionary가 아님: " + str(enemy_id))
		return {}

	return enemy_data
# 전투 시작 함수
func start_battle(enemy_id, first_turn = ""):
	var enemy_data = get_enemy_data_by_id(enemy_id)

	if enemy_data.is_empty():
		return

	var skip_flag = enemy_data.get("skip_if_flag", "")

	if skip_flag != "" and has_flag(skip_flag):
		print("이미 처치한 적이라 전투 스킵: " + enemy_id)
		return
	
	is_story_playing = true
	hide_game_ui()

	var battle_scene_resource = load(BATTLE_SCENE_PATH)
	battle_scene = battle_scene_resource.instantiate()

	add_child(battle_scene)
	battle_scene.battle_finished.connect(end_battle)
	
	var effective_stats = get_player_effective_stats()
	var battle_player_max_hp = int(effective_stats.get("max_hp", player_max_hp))
	@warning_ignore("unused_variable")
	var battle_player_hp = min(player_hp, battle_player_max_hp)

	# 전투신으로 넘겨줄 로드한 데이터들 모음
	var battle_data = {
		"enemy_id": enemy_id,
		"enemy_data": enemy_data,
		"enemies": enemies,
		"player_hp": battle_player_hp,
		"player_max_hp": battle_player_max_hp,
		"player_effective_stats": effective_stats,
		"player_portraits": get_character_portrait_data_by_id("protagonist"),
		"items": items,
		"equipped_weapon": equipped_weapon,
		"inventory": inventory,
		"projectiles": projectiles,
		"flags": flags,
		"first_turn": first_turn
	}
	
	if bgm_player.playing:
		bgm_player.stop()

	battle_scene.setup_battle(battle_data)
# 전투 종료 함수
func end_battle(result_data):
	player_hp = result_data.get("player_hp", player_hp)

	for flag_id in result_data.get("reward_flags", []):
		set_flag(flag_id)

	var battle_rewards = result_data.get("rewards", [])

	for reward in battle_rewards:
		if reward.has("once_flag"):
			set_flag(reward["once_flag"])

	if battle_scene != null:
		battle_scene.queue_free()
		battle_scene = null

	is_story_playing = false
	show_game_ui()
	
	bgm_player.play()
	
	await give_items_with_pending_loot(battle_rewards)
	await open_inventory_arrange_if_pending_loot("loot")

	print("전투 종료 결과: " + str(result_data.get("result", "")))

# ============================================================
# 디버그 관련 함수 모음
# ============================================================

# 개발 테스트용 시작 아이템 추가 함수
func add_debug_start_items():
	if not DEBUG_ADD_START_ITEMS:
		return

	var debug_item_ids = get_debug_start_item_ids()

	for item_id in debug_item_ids:
		if get_item_data_by_id(item_id).is_empty():
			push_warning("테스트 시작 아이템이 items.json에 없음: " + str(item_id))
			continue

		await add_item(item_id)
# 방 갱신 전에 실행할 개발 테스트 흐름
func run_debug_before_room_update_flow():
	if DEBUG_OPEN_PENDING_LOOT_TEST:
		await give_items_with_pending_loot([
			{
				"item": "beverage_a",
				"count": 1
			}
		])

		await open_inventory_arrange_if_pending_loot("loot")
# 방 갱신 후 실행할 개발 테스트 흐름
func run_debug_after_room_update_flow():
	if DEBUG_START_BATTLE_TEST:
		await get_tree().create_timer(DEBUG_BATTLE_START_DELAY).timeout
		start_battle(DEBUG_TEST_BATTLE_ENEMY_ID)
# 개발 테스트용 시작 아이템 프리셋 반환 함수
func get_debug_start_item_ids():
	match DEBUG_START_ITEM_PRESET:
		"none":
			return []

		"basic":
			return [
				"holy_sword",
				"beverage_a",
				"beverage_a"
			]

		"relic_basic":
			return [
				"holy_sword",
				"old_water_ball",
				"old_abacus",
				"cube_relic",
				"torn_eyepatch",
				"dice_relic"
			]

		"relic_full":
			return [
				"holy_sword",
				"old_water_ball",
				"old_abacus",
				"cube_relic",
				"torn_eyepatch",
				"dice_relic",
				"broken_headset_relic",
				"teddy_bear_relic",
				"character_figure_relic",
				"music_box_relic",
				"cross_relic",
				"holy_grail_relic",

				"bible_fetish",
				"metal_syringe",
				"rosary_fetish",
				"sneakers_fetish",
				"dumbbell_fetish",
				"sandbag_fetish",
				"lung_model_fetish",
				"first_aid_box_fetish",
				"hourglass_fetish",
				"hand_bone_fetish",
				"skull_model_fetish",
				"small_frame_fetish",
				"hand_candlestick_fetish",
				"brain_model_fetish",
				"heart_model_fetish"
			]

		"consumable_test":
			return [
				"holy_sword",
				"beverage_a",
				"beverage_a",
				"beverage_a",
				"beverage_a",
				"beverage_a",
				"beverage_a",
				"tranquilizer",
				"tranquilizer",
				"tranquilizer",
				"tranquilizer",
				"tranquilizer",
				"lung_model_fetish",
				"holy_grail_relic",
				"music_box_relic",
				"first_aid_box_fetish",
				"cross_relic",
				"razor",
				"cutter_knife"
			]

		"weapon_count_test":
			return [
				"holy_sword",
				"razor",
				"cutter_knife",
				"cross_relic"
			]
			
		"my_test":
			return [
				"holy_grail_relic",
				"old_abacus",
				"old_water_ball",
				"metal_syringe",
				"brain_model_fetish",
				"torn_eyepatch",
				"hourglass_fetish",
				"character_figure_relic",
				"skull_model_fetish",
				"cutter_knife",
				"bible_fetish",
				"classic_camera_fetish",
				"broken_headset_relic",
				"hand_bone_fetish",
				"heart_model_fetish"
			]

		_:
			push_warning("알 수 없는 DEBUG_START_ITEM_PRESET: " + str(DEBUG_START_ITEM_PRESET))
			return []

# ============================================================
# 성물/주물 관련 함수 모음
# ============================================================

# ------------------------------------------------------------
# 성물/주물 능력치 계산
# ------------------------------------------------------------

# 현재 장착 무기 기준 기본/적용 능력치 계산 함수
func get_player_effective_stats():
	var weapon_id = "fist"

	if equipped_weapon != null:
		weapon_id = equipped_weapon.get("id", "fist")

	var weapon_data = get_item_data_by_id(weapon_id)

	var attack_min = int(weapon_data.get("attack_min", weapon_data.get("attack", 1)))
	var attack_max = int(weapon_data.get("attack_max", weapon_data.get("attack", attack_min)))
	var critical_chance = float(weapon_data.get("critical_chance", 0.01))
	var critical_multiplier = float(weapon_data.get("critical_multiplier", 2.0))
	var parry_window = float(weapon_data.get("parry_window", 0.1))
	var attack_swing_speed = float(weapon_data.get("attack_swing_speed", 3.0))
	var defense_move_speed = float(weapon_data.get("defense_move_speed", 500.0))

	var stats = {
		"weapon_id": weapon_id,

		"attack_min_base": attack_min,
		"attack_max_base": attack_max,
		"critical_chance_base": critical_chance,
		"critical_multiplier_base": critical_multiplier,
		"parry_window_base": parry_window,
		"attack_swing_speed_base": attack_swing_speed,
		"defense_move_speed_base": defense_move_speed,
		"max_hp_base": int(player_max_hp),

		"attack_min": attack_min,
		"attack_max": attack_max,
		"critical_chance": critical_chance,
		"critical_multiplier": critical_multiplier,
		"parry_window": parry_window,
		"attack_swing_speed": attack_swing_speed,
		"defense_move_speed": defense_move_speed,
		"max_hp": int(player_max_hp),

		"damage_taken_multiplier": 1.0,
		"turn_player_hp_delta": 0,
		"turn_enemy_hp_delta": 0,
		"turn_start_player_damage": 0,
		"turn_start_player_heal": 0,
		"turn_start_enemy_damage": 0,
		"piercing": bool(weapon_data.get("piercing", false)),
		"cannot_die": false,

		"applied_relic_ids": [],
		"applied_relic_names": []
	}
	
	# 성물/주물 효과 적용 부분
	apply_relic_and_fetish_effects(stats)
	
	# 성물 테스트 용도
	#print("적용 효과: ", stats.get("applied_relic_names", []))
	#print("공격력: ", stats.get("attack_min"), " ~ ", stats.get("attack_max"))
	#print("치명타 확률: ", stats.get("critical_chance"))
	#print("치명타 배율: ", stats.get("critical_multiplier"))
	#print("패링 범위: ", stats.get("parry_window"))
	#print("스윙 속도: ", stats.get("attack_swing_speed"))
	#print("받는 피해 배율: ", stats.get("damage_taken_multiplier"))
	#print("관통 여부: ", stats.get("piercing"))
	#print("최대 체력: ", stats.get("max_hp"))
	#print("장착 무기 주변 슬롯: ", get_equipped_weapon_adjacent_slots())

	return clamp_player_effective_stats(stats)
# 성물/주물 효과 적용 함수
func apply_relic_and_fetish_effects(stats):
	for inventory_item in inventory:
		var item_id = inventory_item.get("id", "")

		if item_id == "":
			continue

		var item_data = get_item_data_by_id(item_id)

		if item_data.is_empty():
			continue

		var item_type = item_data.get("type", "")
		var effect_scope = item_data.get("effect_scope", "")

		if item_type != "relic":
			continue

		if effect_scope == "adjacent_weapon":
			if not is_inventory_item_adjacent_to_equipped_weapon(inventory_item):
				continue

		elif effect_scope != "inventory":
			continue

		match item_id:
			# 오래된 워터볼 : 장착한 무기 최소 공격력 3 증가(합연산)
			"old_water_ball":
				stats["attack_min"] = int(stats.get("attack_min", 1)) + 3
				add_applied_relic_to_stats(stats, item_id)
			# 낡은 주판 : 장착한 무기 최대 공격력 3 증가(합연산)
			"old_abacus":
				stats["attack_max"] = int(stats.get("attack_max", 1)) + 3
				add_applied_relic_to_stats(stats, item_id)
			# 큐브 : 최대 체력 30 증가(합연산)
			"cube_relic":
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) + 30
				add_applied_relic_to_stats(stats, item_id)
			# 찢어진 안대 : 치명타 확률 30% 증가(합연산)
			"torn_eyepatch":
				stats["critical_chance"] = float(stats.get("critical_chance", 0.01)) + 0.3
				add_applied_relic_to_stats(stats, item_id)
			# 주사위 : 패링 범위 30% 증가(곱연산)
			"dice_relic":
				stats["parry_window"] = float(stats.get("parry_window", 0.1)) * 1.3
				add_applied_relic_to_stats(stats, item_id)
			# 성경책 : 장착한 무기 최소 공격력 5 증가(합연산)
			"bible_fetish":
				stats["attack_min"] = int(stats.get("attack_min", 1)) + 5
				add_applied_relic_to_stats(stats, item_id)
			# 금속 주사기 : 장착한 무기 최대 공격력 5 증가(합연산)
			"metal_syringe":
				stats["attack_max"] = int(stats.get("attack_max", 1)) + 5
				add_applied_relic_to_stats(stats, item_id)
			# 묵주 : 받는 피해 30% 감소(곱연산), 최대 공격력 5 하락(합연산)
			"rosary_fetish":
				stats["damage_taken_multiplier"] = float(stats.get("damage_taken_multiplier", 1.0)) * 0.7
				stats["attack_max"] = int(stats.get("attack_max", 1)) - 5
				add_applied_relic_to_stats(stats, item_id)
			# 운동화 : 방어 모드 이동 속도 50% 증가, 스윙 속도 30% 증가
			"sneakers_fetish":
				stats["defense_move_speed"] = float(stats.get("defense_move_speed", 500.0)) * 1.5
				stats["attack_swing_speed"] = float(stats.get("attack_swing_speed", 3.0)) * 1.3
				add_applied_relic_to_stats(stats, item_id)
			# 아령 : 스윙 속도 50% 감소
			"dumbbell_fetish":
				stats["attack_swing_speed"] = float(stats.get("attack_swing_speed", 3.0)) * 0.5
				add_applied_relic_to_stats(stats, item_id)
			# 모래 주머니 : 최대 체력 50 하락
			"sandbag_fetish":
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) - 50
				add_applied_relic_to_stats(stats, item_id)
			# 폐 모형 : 소모품 총개수 * 5 만큼 최대 체력 증가, 치명타 확률 50% 감소(합연산)
			"lung_model_fetish":
				var consumable_count = get_inventory_consumable_total_count()
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) + consumable_count * 5
				stats["critical_chance"] = float(stats.get("critical_chance", 0.01)) - 0.5
				add_applied_relic_to_stats(stats, item_id)						
			# 오르골 : 플레이어 턴 시작 시 현재 체력 3 회복
			"music_box_relic":
				stats["turn_start_player_heal"] = int(stats.get("turn_start_player_heal", 0)) + 3
				add_applied_relic_to_stats(stats, item_id)
			# 구급 상자 : 플레이어 턴 시작 시 현재 체력 5 회복, 최소 공격력 5 하락
			"first_aid_box_fetish":
				stats["turn_start_player_heal"] = int(stats.get("turn_start_player_heal", 0)) + 5
				stats["attack_min"] = int(stats.get("attack_min", 1)) - 5
				add_applied_relic_to_stats(stats, item_id)
			# 클래식 카메라 : 인접 시 최소/최대 공격력 5 증가, 플레이어 턴 시작 시 현재 체력 3 감소
			"classic_camera_fetish":
				stats["attack_min"] = int(stats.get("attack_min", 1)) + 5
				stats["attack_max"] = int(stats.get("attack_max", 1)) + 5
				stats["turn_start_player_damage"] = int(stats.get("turn_start_player_damage", 0)) + 3
				add_applied_relic_to_stats(stats, item_id)
			# 모래 시계 : 플레이어 턴 시작 시 플레이어/적 본체/적 파츠 현재 체력 10 감소
			"hourglass_fetish":
				stats["turn_start_player_damage"] = int(stats.get("turn_start_player_damage", 0)) + 10
				stats["turn_start_enemy_damage"] = int(stats.get("turn_start_enemy_damage", 0)) + 10
				add_applied_relic_to_stats(stats, item_id)
			# 망가진 헤드셋 : 치명타 배율 30% 증가
			"broken_headset_relic":
				stats["critical_multiplier"] = float(stats.get("critical_multiplier", 2.0)) * 1.3
				add_applied_relic_to_stats(stats, item_id)
			# 곰인형 : 최소 공격력 5 증가
			"teddy_bear_relic":
				stats["attack_min"] = int(stats.get("attack_min", 1)) + 5
				add_applied_relic_to_stats(stats, item_id)
			# 캐릭터 피규어 : 최대 공격력 5 증가
			"character_figure_relic":
				stats["attack_max"] = int(stats.get("attack_max", 1)) + 5
				add_applied_relic_to_stats(stats, item_id)
			# 손 뼈 모형 : 치명타 확률 50% 증가, 최대 체력 30 하락
			"hand_bone_fetish":
				stats["critical_chance"] = float(stats.get("critical_chance", 0.01)) + 0.5
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) - 30
				add_applied_relic_to_stats(stats, item_id)
			# 해골 모형 : 치명타 배율 50% 증가, 최대 체력 50 하락
			"skull_model_fetish":
				stats["critical_multiplier"] = float(stats.get("critical_multiplier", 2.0)) * 1.5
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) - 50
				add_applied_relic_to_stats(stats, item_id)
			# 작은 액자 : 패링 범위 50% 증가, 스윙 속도 30% 증가
			"small_frame_fetish":
				stats["parry_window"] = float(stats.get("parry_window", 0.1)) * 1.5
				stats["attack_swing_speed"] = float(stats.get("attack_swing_speed", 3.0)) * 1.3
				add_applied_relic_to_stats(stats, item_id)
			# 손 모양 촛대 : 관통 효과 부여, 받는 피해 50% 증가
			"hand_candlestick_fetish":
				stats["piercing"] = true
				stats["damage_taken_multiplier"] = float(stats.get("damage_taken_multiplier", 1.0)) * 1.5
				add_applied_relic_to_stats(stats, item_id)
			# 십자가 : 인벤토리 내 무기 타입 아이템이 3개 이상이면 최대 공격력 +10
			"cross_relic":
				if get_inventory_weapon_total_count() >= 3:
					stats["attack_max"] = int(stats.get("attack_max", 1)) + 10
					add_applied_relic_to_stats(stats, item_id)
			# 성배 : 인벤토리 내 소모품 타입 아이템 총개수가 0개이면 관통 효과 부여
			"holy_grail_relic":
				if get_inventory_consumable_total_count() <= 0:
					stats["piercing"] = true
					add_applied_relic_to_stats(stats, item_id)
			# 뇌 모형 : 인벤토리가 꽉 찼을 경우 최대 공격력 +10
			"brain_model_fetish":
				if is_inventory_full():
					stats["attack_max"] = int(stats.get("attack_max", 1)) + 10
					add_applied_relic_to_stats(stats, item_id)
			# 심장 모형 : 최대 체력 -30, 효과 적용 후 최대 체력이 30 이하라면 죽지 않음 효과 부여
			"heart_model_fetish":
				stats["max_hp"] = int(stats.get("max_hp", player_max_hp)) - 30

				if int(stats.get("max_hp", player_max_hp)) <= 30:
					stats["cannot_die"] = true

				add_applied_relic_to_stats(stats, item_id)
			_:
				pass
# 적용된 성물/주물 목록에 아이템 추가 함수
func add_applied_relic_to_stats(stats, item_id):
	if item_id == "":
		return

	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return

	if not stats.has("applied_relic_ids"):
		stats["applied_relic_ids"] = []

	if not stats.has("applied_relic_names"):
		stats["applied_relic_names"] = []

	if stats["applied_relic_ids"].has(item_id):
		return

	stats["applied_relic_ids"].append(item_id)
	stats["applied_relic_names"].append(get_item_name(item_id))
# 적용 능력치 최종 제한값 보정 함수
func clamp_player_effective_stats(stats):
	stats["max_hp"] = max(1, int(stats.get("max_hp", player_max_hp)))
	stats["attack_min"] = max(1, int(stats.get("attack_min", 1)))
	stats["attack_max"] = max(1, int(stats.get("attack_max", stats["attack_min"])))

	# 최소 공격력이 최대 공격력보다 커지면 최대 공격력을 최소 공격력에 맞춤
	if int(stats["attack_min"]) > int(stats["attack_max"]):
		stats["attack_max"] = int(stats["attack_min"])

	stats["critical_chance"] = clamp(float(stats.get("critical_chance", 0.01)), 0.01, 1.0)
	stats["critical_multiplier"] = max(1.1, float(stats.get("critical_multiplier", 1.1)))
	stats["parry_window"] = max(0.01, float(stats.get("parry_window", 0.1)))
	stats["attack_swing_speed"] = max(0.01, float(stats.get("attack_swing_speed", 3.0)))
	stats["defense_move_speed"] = max(1.0, float(stats.get("defense_move_speed", 500.0)))
	stats["damage_taken_multiplier"] = max(0.01, float(stats.get("damage_taken_multiplier", 1.0)))

	if not stats.has("applied_relic_ids"):
		stats["applied_relic_ids"] = []

	if not stats.has("applied_relic_names"):
		stats["applied_relic_names"] = []

	return stats
# 현재 성물/주물 효과가 적용된 최대 체력 반환 함수
func get_current_player_max_hp():
	var effective_stats = get_player_effective_stats()
	return int(effective_stats.get("max_hp", player_max_hp))
# 현재 체력이 적용 최대 체력을 넘지 않도록 보정하는 함수
func clamp_player_hp_to_current_max():
	var current_max_hp = get_current_player_max_hp()

	if player_hp > current_max_hp:
		player_hp = current_max_hp

	if player_hp < 0:
		player_hp = 0

	return current_max_hp

# ------------------------------------------------------------
# 성물/주물 조건 계산
# ------------------------------------------------------------

# 인벤토리 안의 소모품 총개수 계산 함수
func get_inventory_consumable_total_count():
	var total_count = 0

	for inventory_item in inventory:
		if inventory_item == null:
			continue

		if typeof(inventory_item) != TYPE_DICTIONARY:
			continue

		var item_id = inventory_item.get("id", "")
		var item_data = get_item_data_by_id(item_id)

		if item_data.is_empty():
			continue

		if item_data.get("type", "") != "consumable":
			continue

		total_count += int(inventory_item.get("count", 1))

	return total_count
# 인벤토리 안의 무기 타입 아이템 개수 계산 함수
func get_inventory_weapon_total_count():
	var total_count = 0

	for inventory_item in inventory:
		if inventory_item == null:
			continue

		if typeof(inventory_item) != TYPE_DICTIONARY:
			continue

		var item_id = inventory_item.get("id", "")
		var item_data = get_item_data_by_id(item_id)

		if item_data.is_empty():
			continue

		if item_data.get("type", "") != "weapon":
			continue

		total_count += int(inventory_item.get("count", 1))

	return total_count
# 현재 인벤토리에 빈칸이 있는지 확인하는 함수
func has_empty_inventory_slot():
	var used_slots = []

	for inventory_item in inventory:
		var occupied_slots = get_inventory_item_occupied_slots(inventory_item)

		for slot in occupied_slots:
			if not used_slots.has(slot):
				used_slots.append(slot)

	var total_slots = inventory_cols * inventory_rows

	return used_slots.size() < total_slots
# 인벤토리가 꽉 찼는지 확인하는 함수
func is_inventory_full():
	return not has_empty_inventory_slot()

# ------------------------------------------------------------
# 인벤토리 슬롯 / 장착 무기 인접 판정
# ------------------------------------------------------------

# item_id 기준으로 아이템 데이터 반환 함수
func get_item_data_by_id(item_id):
	if item_id == "":
		return {}

	if not items.has(item_id):
		return {}

	return items[item_id]
# item_id 기준으로 아이템 이미지 경로 반환 함수
func get_item_image_path_by_id(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return ""

	return item_data.get("image", "")
# inventory_item 기준으로 아이템 이미지 경로 반환 함수
func get_item_image_path_from_inventory_item(inventory_item):
	if inventory_item == null:
		return ""

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return ""

	var item_id = inventory_item.get("id", "")

	return get_item_image_path_by_id(item_id)
# item_id 기준으로 items.json의 인벤토리 크기 반환 함수
# 앞으로 아이템 크기가 필요하면 직접 items[item_id]["width"]를 읽지 않고 이 함수를 사용
func get_item_grid_size_by_id(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return Vector2i(0, 0)

	var item_width = int(item_data.get("width", 1))
	var item_height = int(item_data.get("height", 1))

	if item_width < 1:
		item_width = 1

	if item_height < 1:
		item_height = 1

	return Vector2i(item_width, item_height)
# inventory_item 기준으로 아이템 인벤토리 크기 반환 함수
# 앞으로 아이템 크기가 필요하면 직접 items[item_id]["width"]를 읽지 않고 이 함수를 사용
func get_inventory_item_grid_size(inventory_item):
	if inventory_item == null:
		return Vector2i(0, 0)

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return Vector2i(0, 0)

	var item_id = inventory_item.get("id", "")

	return get_item_grid_size_by_id(item_id)
# 시작 슬롯, 크기, 가로 칸 수를 기준으로 차지 슬롯 목록 생성 함수
func get_grid_slots_from_size(start_slot, item_width, item_height, cols = -1):
	if cols <= 0:
		cols = inventory_cols

	if start_slot < 0:
		return []

	var start_col = int(start_slot) % int(cols)
	var start_row = floori(int(start_slot) / float(cols))

	var slots = []

	for y in range(int(item_height)):
		for x in range(int(item_width)):
			var slot = (start_row + y) * int(cols) + (start_col + x)
			slots.append(slot)

	return slots
# 인벤토리 아이템이 차지하는 슬롯 목록 반환 함수
func get_inventory_item_occupied_slots(inventory_item):
	if inventory_item == null:
		return []

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return []

	if not inventory_item.has("slot"):
		return []

	var item_size = get_inventory_item_grid_size(inventory_item)

	if item_size.x <= 0 or item_size.y <= 0:
		return []

	var start_slot = int(inventory_item.get("slot", -1))

	return get_grid_slots_from_size(
		start_slot,
		item_size.x,
		item_size.y,
		inventory_cols
	)
# 장착 무기 인벤토리 아이템 찾기 함수
func get_equipped_weapon_inventory_item():
	if equipped_weapon == null:
		return null

	var equipped_weapon_id = equipped_weapon.get("id", "")

	if equipped_weapon_id == "":
		return null

	for inventory_item in inventory:
		if inventory_item.get("id", "") == equipped_weapon_id:
			return inventory_item

	return null
# 장착 무기 주변 1칸 슬롯 목록 반환 함수
func get_equipped_weapon_adjacent_slots():
	var adjacent_slots = []
	var equipped_inventory_item = get_equipped_weapon_inventory_item()

	if equipped_inventory_item == null:
		return adjacent_slots

	var weapon_slots = get_inventory_item_occupied_slots(equipped_inventory_item)

	for slot in weapon_slots:
		var col = slot % inventory_cols
		var row = floori(slot / float(inventory_cols))

		for y in range(-1, 2):    
			for x in range(-1, 2):
				if x == 0 and y == 0:
					continue

				var check_col = col + x
				var check_row = row + y

				if check_col < 0:
					continue

				if check_col >= inventory_cols:
					continue

				if check_row < 0:
					continue

				if check_row >= inventory_rows:
					continue

				var check_slot = check_row * inventory_cols + check_col

				if weapon_slots.has(check_slot):
					continue

				if not adjacent_slots.has(check_slot):
					adjacent_slots.append(check_slot)

	return adjacent_slots
# 해당 아이템이 장착 무기 주변 1칸에 인접해 있는지 확인 함수
func is_inventory_item_adjacent_to_equipped_weapon(inventory_item):
	if inventory_item == null:
		return false

	var item_slots = get_inventory_item_occupied_slots(inventory_item)

	if item_slots.size() == 0:
		return false

	var adjacent_slots = get_equipped_weapon_adjacent_slots()

	for slot in item_slots:
		if adjacent_slots.has(slot):
			return true

	return false

# ============================================================
# 로드 함수 모음
# ============================================================

# Dictionary 구조 JSON 파일 공통 로드 함수
func load_json_dictionary(path, file_label):
	if not FileAccess.file_exists(path):
		push_error(file_label + " 파일을 찾을 수 없음: " + path)
		return null

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error(file_label + " 파일 열기 실패: " + path)
		return null

	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error(file_label + " 파싱 실패: " + json.get_error_message())
		push_error("오류 위치 line: " + str(json.get_error_line()))
		return null

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error(file_label + " 최상위 구조는 Dictionary여야 함")
		return null

	return json.data
# 방 로드 및 예외 처리 함수
func load_rooms():
	var data = load_json_dictionary(
		"res://data/rooms.json",
		"rooms.json"
	)

	if data == null:
		return false

	rooms = data

	if not rooms.has(current_room):
		push_error("현재 방이 rooms.json에 없음: " + current_room)
		return false

	print("rooms.json 로드 성공")
	return true
# 아이템 데이터 로드 및 예외 처리 함수
func load_items():
	var data = load_json_dictionary(
		"res://data/items.json",
		"items.json"
	)

	if data == null:
		return false

	items = data
	print("items.json 로드 성공")
	return true
# NPC 캐릭터 데이터 로드 및 예외 처리 함수
func load_characters():
	var data = load_json_dictionary(
		"res://data/characters.json",
		"characters.json"
	)

	if data == null:
		return false

	characters = data
	print("characters.json 로드 성공")
	return true
# 스토리 이벤트 데이터 로드 함수
func load_story_events():
	var data = load_json_dictionary(
		"res://data/story_events.json",
		"story_events.json"
	)

	if data == null:
		return false

	story_events = data
	print("story_events.json 로드 성공")
	return true
# 적 데이터 로드 및 예외 처리 함수
func load_enemies():
	var data = load_json_dictionary(
		"res://data/enemies.json",
		"enemies.json"
	)

	if data == null:
		return false

	enemies = data
	print("enemies.json 로드 성공")
	return true
# 투사체 데이터 로드 및 예외 처리 함수
func load_projectiles():
	var data = load_json_dictionary(
		"res://data/projectiles.json",
		"projectiles.json"
	)

	if data == null:
		return false

	projectiles = data
	print("projectiles.json 로드 성공")
	return true
# 랜덤 인카운터 데이터 로드 및 예외 처리 함수
func load_encounters():
	var data = load_json_dictionary(
		"res://data/encounters.json",
		"encounters.json"
	)

	if data == null:
		return false

	encounters = data
	print("encounters.json 로드 성공")
	return true
# 인카운터 이벤트 데이터 로드 및 예외 처리 함수
func load_encounter_events():
	var data = load_json_dictionary(
		"res://data/encounter_events.json",
		"encounter_events.json"
	)

	if data == null:
		return false

	encounter_events = data
	print("encounter_events.json 로드 성공")
	return true

# ============================================================
# 방 함수 모음
# ============================================================

# room_id 기준으로 방 데이터 가져오기 함수
func get_room_data_by_id(room_id, show_error = true):
	if room_id == "":
		if show_error:
			push_error("방 ID가 비어있음")
		return {}

	if not rooms.has(room_id):
		if show_error:
			push_error("존재하지 않는 방: " + str(room_id))
		return {}

	var room_data = rooms[room_id]

	if typeof(room_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("방 데이터가 Dictionary가 아님: " + str(room_id))
		return {}

	return room_data
# 현재 방 데이터 가져오기 함수
func get_current_room_data(show_error = true):
	return get_room_data_by_id(current_room, show_error)
# 방 데이터에서 특정 방향 출구 데이터 가져오기 함수
func get_exit_data_from_room(room, direction, show_error = false):
	if room.is_empty():
		return {}

	if not room.has("exits"):
		return {}

	var exits = room["exits"]

	if typeof(exits) != TYPE_DICTIONARY:
		if show_error:
			push_error("exits 데이터가 Dictionary가 아님: " + str(current_room))
		return {}

	if not exits.has(direction):
		return {}

	var exit_data = exits[direction]

	if typeof(exit_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("출구 데이터가 Dictionary가 아님: " + str(current_room) + " / " + str(direction))
		return {}

	return exit_data
# 출구가 잠긴 상태인지 확인하는 함수
func is_exit_locked(exit_data):
	if exit_data.is_empty():
		return false

	return bool(exit_data.get("locked", false))
# 잠긴 출구가 플래그로 열렸는지 확인하는 함수
func is_exit_unlocked(exit_data):
	if exit_data.is_empty():
		return false

	var open_flag = exit_data.get("open_flag", "")

	if open_flag == "":
		return false

	return has_flag(open_flag)
# 현재 이동 입력으로 지나갈 수 없는 출구인지 확인하는 함수
func is_exit_blocked_for_movement(exit_data):
	return is_exit_locked(exit_data) and not is_exit_unlocked(exit_data)
# 출구 이동 시 흔들림 효과를 사용할지 확인하는 함수
func should_use_exit_shake(exit_data):
	if exit_data.is_empty():
		return true

	return exit_data.get("move_effect", "") != "enter"
# 방향별 막힌 길 대사 반환 함수
func get_no_exit_message(direction):
	match direction:
		"up":
			return MSG_NO_FORWARD
		"down":
			return MSG_NO_BACK
		"left":
			return MSG_NO_LEFT
		"right":
			return MSG_NO_RIGHT
		_:
			return "그쪽으로는 갈 수 없다."
# 모든 이동 화살표 숨김 함수
func hide_all_move_arrows():
	for direction in move_arrows.keys():
		move_arrows[direction].visible = false
# 현재 방 배경 경로 결정 함수
func get_room_background_path(room):
	if room.is_empty():
		return ""

	var background_path = room.get("background", "")

	if background_path == "":
		push_error(current_room + "에 background 값이 없음")
		return ""

	if not room.has("exits"):
		return background_path

	var exits = room["exits"]

	if typeof(exits) != TYPE_DICTIONARY:
		return background_path

	for direction in exits.keys():
		var exit_data = get_exit_data_from_room(room, direction)

		if exit_data.is_empty():
			continue

		if is_exit_unlocked(exit_data) and room.has("opened_background"):
			background_path = room["opened_background"]
			break

	return background_path
# 현재 방 배경 이미지 갱신 함수
func update_room_background(room):
	var background_path = get_room_background_path(room)

	if background_path == "":
		return

	background.texture = load(background_path)
# 현재 방 이동 화살표 갱신 함수
func update_room_move_arrows(room):
	hide_all_move_arrows()

	if room.is_empty():
		return

	if not room.has("exits"):
		return

	var exits = room["exits"]

	if typeof(exits) != TYPE_DICTIONARY:
		return

	for direction in exits.keys():
		var exit_data = get_exit_data_from_room(room, direction)

		if exit_data.is_empty():
			continue

		# 잠겨 있고 아직 열리지 않은 출구는 화살표 표시 안 함
		if is_exit_blocked_for_movement(exit_data):
			continue

		if not move_arrows.has(direction):
			continue

		var arrow = move_arrows[direction]
		arrow.visible = true

		if exit_data.has("position"):
			arrow.position = Vector2(
				exit_data["position"][0],
				exit_data["position"][1]
			)
			arrow_base_positions[direction] = arrow.position
# 현재 방 UI 갱신 함수
func update_room():
	var room = get_current_room_data()

	if room.is_empty():
		return

	update_room_background(room)
	update_room_move_arrows(room)

	# 현재 방의 interactions 데이터를 기준으로 클릭 버튼 자동 생성
	create_interaction_buttons(room)
	create_exit_buttons(room)
# 현재 방을 변경하고 방 UI를 갱신하는 함수
func apply_room_change(target_room):
	current_room = target_room
	update_room()
# 방 이동 후 방 진입 스토리 이벤트를 처리하는 함수
func handle_room_enter_story_after_move():
	await check_room_enter_story()
# 방 이동 후 랜덤 인카운터를 처리하는 함수
# 랜덤 인카운터가 시작되면 true 반환
func handle_random_encounter_after_move():
	if random_encounter_cooldown_steps > 0:
		random_encounter_cooldown_steps -= 1
		return false

	if is_story_playing:
		return false

	var encounter_started = await check_random_encounter()

	if encounter_started:
		return true

	return false
# 방 이동 후 이동 입력 잠금을 해제하는 함수
func finish_room_move_input_lock():
	await get_tree().create_timer(1.5).timeout
	is_moving = false
# 방 이동 함수
func move_to_room(target_room, use_shake, direction):
	if get_room_data_by_id(target_room).is_empty():
		return

	# 이동 중에는 추가 입력을 막음
	is_moving = true
	
	# use_shake가 true면 흔들림 사용, false면 암전만 사용
	await effect(true, use_shake, true, direction)
	
	# 실제 방 변경 및 UI 갱신
	apply_room_change(target_room)
	
	# 방 진입 시 스토리 이벤트 확인
	await handle_room_enter_story_after_move()
	
	# 랜덤 인카운터 체크
	var encounter_started = await handle_random_encounter_after_move()

	if encounter_started:
		is_moving = false
		return
	
	# 새 방이 보인 뒤 바로 이동하지 못하게 잠깐 대기
	await finish_room_move_input_lock()
# 방향키 입력을 받아 exits 데이터 기준으로 방 이동하는 함수
func try_move_to_exit(direction):
	var room = get_current_room_data()

	if room.is_empty():
		return

	var exit_data = get_exit_data_from_room(room, direction)

	# 현재 방에 해당 방향 출구가 없으면 방향별 대사 출력
	if exit_data.is_empty():
		await show_dialogue(get_no_exit_message(direction))
		return

	# 잠겨 있고 아직 열리지 않은 출구는 방향키로 처리하지 않음
	# 잠긴 문은 마우스 클릭으로만 상호작용
	if is_exit_blocked_for_movement(exit_data):
		return

	var target_room = exit_data.get("target", "")

	if target_room == "":
		push_error("출구 target 값이 없음: " + current_room + " / " + str(direction))
		return

	var use_shake = should_use_exit_shake(exit_data)

	await move_to_room(target_room, use_shake, direction)
# 현재 방에 생성된 상호작용 버튼들을 전부 제거
func clear_interaction_buttons():
	for child in interaction_buttons.get_children():
		child.queue_free()
# 방 데이터에서 interactions Dictionary 가져오기 함수
func get_interactions_from_room(room, show_error = false):
	if room.is_empty():
		return {}

	if not room.has("interactions"):
		return {}

	var interactions = room["interactions"]

	if typeof(interactions) != TYPE_DICTIONARY:
		if show_error:
			push_error("interactions 데이터가 Dictionary가 아님: " + str(current_room))
		return {}

	return interactions
# 방 데이터에서 특정 interaction 데이터 가져오기 함수
func get_interaction_data_from_room(room, interaction_id, show_error = false):
	var interactions = get_interactions_from_room(room, show_error)

	if interactions.is_empty():
		return {}

	if not interactions.has(interaction_id):
		if show_error:
			push_error("존재하지 않는 interaction: " + str(current_room) + " / " + str(interaction_id))
		return {}

	var interaction_data = interactions[interaction_id]

	if typeof(interaction_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("interaction 데이터가 Dictionary가 아님: " + str(current_room) + " / " + str(interaction_id))
		return {}

	return interaction_data
# 방 데이터에서 진입 스토리 이벤트 ID 가져오기 함수
func get_room_enter_story_id(room):
	if room.is_empty():
		return ""

	if not room.has("enter_story"):
		return ""

	var enter_story = room["enter_story"]

	# 새/단순 구조:
	# "enter_story": "story_event_id"
	if typeof(enter_story) == TYPE_STRING:
		return enter_story

	# 기존/상세 구조:
	# "enter_story": {
	#     "event": "story_event_id",
	#     "required_flag_missing": "..."
	# }
	if typeof(enter_story) == TYPE_DICTIONARY:
		return str(enter_story.get("event", ""))

	push_error("enter_story 데이터 타입이 올바르지 않음: " + str(current_room))
	return ""
# 방 진입 스토리 이벤트 실행 조건 확인 함수
func can_run_room_enter_story(room):
	if room.is_empty():
		return false

	if not room.has("enter_story"):
		return false

	var enter_story = room["enter_story"]

	# enter_story가 문자열이면 별도 조건 없음
	if typeof(enter_story) == TYPE_STRING:
		return true

	if typeof(enter_story) != TYPE_DICTIONARY:
		return false

	# 특정 플래그가 있을 때만 실행
	if enter_story.has("required_flag"):
		var required_flag = str(enter_story.get("required_flag", ""))

		if required_flag != "" and not has_flag(required_flag):
			return false

	# 특정 플래그가 없을 때만 실행
	if enter_story.has("required_flag_missing"):
		var missing_flag = str(enter_story.get("required_flag_missing", ""))

		if missing_flag != "" and has_flag(missing_flag):
			return false

	return true

# ============================================================
# 대사, 상호작용, 이벤트 함수 모음
# ============================================================

# story_event_id 기준으로 스토리 이벤트 데이터 가져오기 함수
func get_story_event_data_by_id(story_event_id, show_error = true):
	if typeof(story_event_id) != TYPE_STRING:
		if show_error:
			push_error("스토리 이벤트 ID가 String이 아님: " + str(story_event_id))
		return {}

	if story_event_id == "":
		if show_error:
			push_error("스토리 이벤트 ID가 비어있음")
		return {}

	if not story_events.has(story_event_id):
		if show_error:
			push_error("존재하지 않는 스토리 이벤트: " + str(story_event_id))
		return {}

	var story_event_data = story_events[story_event_id]

	if typeof(story_event_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("스토리 이벤트 데이터가 Dictionary가 아님: " + str(story_event_id))
		return {}

	return story_event_data
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
	if index < 0:
		return ""

	if index >= current_choices.size():
		return ""

	var choice = current_choices[index]
	var choice_text = get_choice_data_text(choice)

	if choice_text == "":
		return ""

	if index == choice_index:
		return "▶ " + choice_text

	return "  " + choice_text
# 상호작용 실행 함수
func run_interaction(interaction_id):
	# rooms.json의 interaction events 배열을 순서대로 실행
	# text / portrait / choices / item / flag / save 등을 처리

	if is_interacting:
		return

	var room = get_current_room_data()

	if room.is_empty():
		return

	var interaction = get_interaction_data_from_room(
		room,
		interaction_id,
		true
	)

	if interaction.is_empty():
		return

	is_interacting = true
	set_interaction_buttons_disabled(true)

	if interaction.has("events"):
		await run_events(interaction["events"])
	else:
		push_error("events가 없는 interaction: " + str(interaction_id))

	set_interaction_buttons_disabled(false)
	is_interacting = false
# 상호작용 중 버튼 클릭 안되게 막는 함수
func set_interaction_buttons_disabled(disabled):
	
	for child in interaction_buttons.get_children():
		if child is Button:
			child.disabled = disabled
# 플래그 보유 여부 확인 함수
func has_flag(flag_id):
	return flags.has(flag_id) and flags[flag_id] == true
# 플래그 설정 함수
func set_flag(flag_id):
	flags[flag_id] = true
	print("플래그 설정: " + flag_id)
# rooms.json의 interactions 데이터를 읽어서 클릭 영역 버튼을 자동 생성
func create_interaction_buttons(room):
	clear_interaction_buttons()

	var interactions = get_interactions_from_room(room)

	if interactions.is_empty():
		return

	for interaction_id in interactions.keys():
		var interaction = get_interaction_data_from_room(room, interaction_id)

		if interaction.is_empty():
			continue

		# click_rect가 없는 상호작용은 버튼 생성하지 않음
		if not interaction.has("click_rect"):
			continue

		var rect = interaction["click_rect"]

		if typeof(rect) != TYPE_ARRAY:
			continue

		if rect.size() < 4:
			continue

		var button = Button.new()

		# 투명 상호작용 버튼이 Space 입력으로 다시 눌리지 않게 함
		button.focus_mode = Control.FOCUS_NONE
		button.position = Vector2(rect[0], rect[1])
		button.size = Vector2(rect[2], rect[3])

		# 투명 버튼처럼 사용
		button.text = ""
		button.modulate.a = 0.0
		button.mouse_filter = Control.MOUSE_FILTER_STOP

		# 디버그할 때는 아래처럼 잠깐 보이게 해도 됨
		# button.modulate.a = 0.25

		var target_interaction_id = str(interaction_id)

		button.pressed.connect(
			func():
				await run_interaction(target_interaction_id)
		)

		interaction_buttons.add_child(button)
# exits 데이터를 읽어서 잠긴 문 클릭 버튼 생성
func create_exit_buttons(room):
	if room.is_empty():
		return

	if not room.has("exits"):
		return

	var exits = room["exits"]

	if typeof(exits) != TYPE_DICTIONARY:
		return

	for direction in exits.keys():
		var exit_data = get_exit_data_from_room(room, direction)

		if exit_data.is_empty():
			continue

		# click_rect 없는 출구는 클릭 버튼 생성 안 함
		if not exit_data.has("click_rect"):
			continue

		# 잠겨 있고 아직 열리지 않은 출구만 마우스 클릭 버튼 생성
		if not is_exit_blocked_for_movement(exit_data):
			continue

		var rect = exit_data["click_rect"]

		if rect.size() < 4:
			continue

		var button = Button.new()
		button.focus_mode = Control.FOCUS_NONE

		button.position = Vector2(rect[0], rect[1])
		button.size = Vector2(rect[2], rect[3])

		button.text = ""
		button.modulate.a = 0.0
		button.mouse_filter = Control.MOUSE_FILTER_STOP

		var exit_direction = str(direction)

		button.pressed.connect(
			func():
				await run_exit_interaction(exit_direction)
		)

		interaction_buttons.add_child(button)
# 잠긴 문 상호작용 실행 함수
func run_exit_interaction(direction):
	if is_interacting or is_dialogue_showing or is_moving:
		return

	var room = get_current_room_data()

	if room.is_empty():
		return

	var exit_data = get_exit_data_from_room(room, direction)

	if exit_data.is_empty():
		return

	# 이미 열린 출구이거나 잠겨 있지 않은 출구면 바로 이동
	if not is_exit_blocked_for_movement(exit_data):
		var target_room = exit_data.get("target", "")

		if target_room == "":
			push_error("출구 target 값이 없음: " + current_room + " / " + str(direction))
			return

		var use_shake = should_use_exit_shake(exit_data)

		await move_to_room(target_room, use_shake, direction)
		return

	is_interacting = true
	set_interaction_buttons_disabled(true)

	var required_item = exit_data.get("required_item", "")

	# 필요한 아이템이 있으면 문 열기
	if required_item != "" and has_item(required_item):
		unlocked_sound.play()

		var open_flag = exit_data.get("open_flag", "")

		if open_flag != "":
			set_flag(open_flag)

		consume_item_by_id(required_item)
		
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
# character_id 기준으로 캐릭터 데이터 가져오기 함수
func get_character_data_by_id(character_id, show_error = true):
	if character_id == "":
		if show_error:
			push_error("캐릭터 ID가 비어있음")
		return {}

	if not characters.has(character_id):
		if show_error:
			push_error("존재하지 않는 캐릭터: " + str(character_id))
		return {}

	var character_data = characters[character_id]

	if typeof(character_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("캐릭터 데이터가 Dictionary가 아님: " + str(character_id))
		return {}

	return character_data
# character_id 기준으로 캐릭터 이름 가져오기 함수
func get_character_name_by_id(character_id):
	var character_data = get_character_data_by_id(character_id, false)

	if character_data.is_empty():
		return str(character_id)

	return str(character_data.get("name", character_id))
# character_id 기준으로 portrait Dictionary 가져오기 함수
func get_character_portrait_data_by_id(character_id):
	var character_data = get_character_data_by_id(character_id, false)

	if character_data.is_empty():
		return {}

	var portrait_data = character_data.get("portrait", {})

	if typeof(portrait_data) != TYPE_DICTIONARY:
		return {}

	return portrait_data
# character_id / emotion 기준으로 초상화 이미지 경로 가져오기 함수
func get_character_portrait_path(character_id, emotion = "normal"):
	var portrait_data = get_character_portrait_data_by_id(character_id)

	if portrait_data.is_empty():
		return ""

	return str(portrait_data.get(emotion, ""))
# character_id / emotion 기준으로 스탠딩 이미지 경로 가져오기 함수
func get_character_standing_path(character_id, emotion = "normal"):
	var character_data = get_character_data_by_id(character_id, false)

	if character_data.is_empty():
		return ""

	var standing_data = character_data.get("standing", {})

	if typeof(standing_data) != TYPE_DICTIONARY:
		return ""

	return str(standing_data.get(emotion, ""))
# NPC 대화 출력 함수
func show_npc_dialogue(character_id, emotion, text):
	var character_data = get_character_data_by_id(character_id)

	if character_data.is_empty():
		return

	speaker_name.text = get_character_name_by_id(character_id)

	var portrait_path = get_character_portrait_path(character_id, emotion)

	if portrait_path != "":
		speaker_portrait.texture = load(portrait_path)
	else:
		speaker_portrait.texture = null

	await show_dialogue(text, "npc")
# 일반 이벤트 1개 실행 함수
func run_single_event(event):
	if event == null:
		return

	if typeof(event) != TYPE_DICTIONARY:
		push_error("일반 이벤트 데이터가 Dictionary가 아님: " + str(event))
		return

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
		var count = int(event.get("count", 1))

		var reward_results = await give_items_with_pending_loot([
			{
				"item": item_id,
				"count": count
			}
		])

		var has_reward = false

		for reward_result in reward_results:
			if int(reward_result.get("added", 0)) > 0 or int(reward_result.get("remaining", 0)) > 0:
				has_reward = true

		if has_reward:
			if count > 1:
				await show_dialogue(get_item_name(item_id) + " " + str(count) + "개" + MSG_ITEM_GAINED_SUFFIX)
			else:
				await show_dialogue(get_item_name(item_id) + MSG_ITEM_GAINED_SUFFIX)

		await open_inventory_arrange_if_pending_loot("loot")

	elif event_type == "flag":
		set_flag(event.get("flag", ""))

	elif event_type == "choices":
		await run_event_choices(event.get("choices", []))

	else:
		push_error("알 수 없는 event type: " + str(event_type))
# events 배열을 순서대로 실행하는 함수
func run_events(events):
	if typeof(events) != TYPE_ARRAY:
		push_error("일반 events 데이터가 Array가 아님")
		return

	for event in events:
		await run_single_event(event)
# 선택지 Dictionary에서 표시 텍스트 가져오기 함수
func get_choice_data_text(choice):
	if choice == null:
		return ""

	if typeof(choice) != TYPE_DICTIONARY:
		return ""

	return str(choice.get("text", ""))
# 선택지 Dictionary에서 실행 events 가져오기 함수
func get_choice_data_events(choice):
	if choice == null:
		return []

	if typeof(choice) != TYPE_DICTIONARY:
		return []

	var events = choice.get("events", [])

	if typeof(events) != TYPE_ARRAY:
		return []

	return events
# 선택지 Dictionary에서 이미 실행된 경우의 events 가져오기 함수
func get_choice_data_already_events(choice):
	if choice == null:
		return []

	if typeof(choice) != TYPE_DICTIONARY:
		return []

	var events = choice.get("already_events", [])

	if typeof(events) != TYPE_ARRAY:
		return []

	return events
# 선택지 Dictionary에서 flag 값 가져오기 함수
func get_choice_data_flag(choice):
	if choice == null:
		return ""

	if typeof(choice) != TYPE_DICTIONARY:
		return ""

	return str(choice.get("flag", ""))
# 선택지 데이터가 유효한지 확인하는 함수
func is_valid_choice_data(choice):
	if choice == null:
		return false

	if typeof(choice) != TYPE_DICTIONARY:
		return false

	if get_choice_data_text(choice) == "":
		return false

	return true
# 일반 이벤트 선택지 실행 함수
func run_event_choices(choices):
	if typeof(choices) != TYPE_ARRAY:
		push_error("선택지 데이터가 Array가 아님")
		return

	var valid_choices = []

	for choice in choices:
		if is_valid_choice_data(choice):
			valid_choices.append(choice)

	if valid_choices.size() == 0:
		return

	var selected_index = await show_choices(valid_choices)

	if selected_index < 0:
		return

	if selected_index >= valid_choices.size():
		return

	var selected_choice = valid_choices[selected_index]
	var choice_flag = get_choice_data_flag(selected_choice)

	if choice_flag != "" and has_flag(choice_flag):
		var already_events = get_choice_data_already_events(selected_choice)

		if already_events.size() > 0:
			await run_events(already_events)

		return

	var choice_events = get_choice_data_events(selected_choice)

	if choice_events.size() > 0:
		await run_events(choice_events)

	if choice_flag != "":
		set_flag(choice_flag)
# 스토리 스탠딩 CG 표시 함수
func show_story_standing(character_id, emotion, position_name = "center"):
	var character_data = get_character_data_by_id(character_id)

	if character_data.is_empty():
		return

	var standing_path = get_character_standing_path(character_id, emotion)

	if standing_path == "":
		push_error("존재하지 않는 standing emotion: " + str(character_id) + " / " + str(emotion))
		return

	story_standing.texture = load(standing_path)
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
		0.25
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

	var story_data = get_story_event_data_by_id(event_id)

	if story_data.is_empty():
		return

	if story_data.has("start_flag") and has_flag(story_data["start_flag"]):
		return

	if not story_data.has("events"):
		push_error("events가 없는 스토리 이벤트: " + str(event_id))
		return

	var events = story_data["events"]

	if typeof(events) != TYPE_ARRAY:
		push_error("스토리 이벤트 events가 Array가 아님: " + str(event_id))
		return

	is_story_playing = true
	set_interaction_buttons_disabled(true)

	await run_story_events(events)

	is_story_playing = false
# 스토리 이벤트 1개 실행 함수
func run_single_story_event(event):
	if event == null:
		return

	if typeof(event) != TYPE_DICTIONARY:
		push_error("스토리 이벤트 데이터가 Dictionary가 아님: " + str(event))
		return

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
		push_error("알 수 없는 story event type: " + str(event_type))
# 스토리 events 배열 실행 함수
func run_story_events(events):
	if typeof(events) != TYPE_ARRAY:
		push_error("스토리 events 데이터가 Array가 아님")
		return

	for event in events:
		await run_single_story_event(event)
# 스토리 이벤트 선택지 실행 함수
func run_story_choices(choices):
	if typeof(choices) != TYPE_ARRAY:
		push_error("스토리 선택지 데이터가 Array가 아님")
		return

	var valid_choices = []

	for choice in choices:
		if is_valid_choice_data(choice):
			valid_choices.append(choice)

	if valid_choices.size() == 0:
		return

	var selected_index = await show_choices(valid_choices)

	if selected_index < 0:
		return

	if selected_index >= valid_choices.size():
		return

	var selected_choice = valid_choices[selected_index]
	var choice_flag = get_choice_data_flag(selected_choice)

	if choice_flag != "" and has_flag(choice_flag):
		var already_events = get_choice_data_already_events(selected_choice)

		if already_events.size() > 0:
			await run_story_events(already_events)

		return

	var choice_events = get_choice_data_events(selected_choice)

	if choice_events.size() > 0:
		await run_story_events(choice_events)

	if choice_flag != "":
		set_flag(choice_flag)
# 스토리 대화 출력 함수
func show_story_dialogue(speaker, text):
	set_dialogue_layout("normal")

	speaker_name.visible = true
	speaker_name.text = speaker

	$DialogueBox/DialogueText.position = Vector2(50, 80)
	$DialogueBox/DialogueText.size = Vector2(1600, 180)

	await show_dialogue(text, "story")
# 방 진입 시 스토리 이벤트 확인 함수
func check_room_enter_story():
	var room = get_current_room_data()

	if room.is_empty():
		return

	var story_event_id = get_room_enter_story_id(room)

	if story_event_id == "":
		return
		
	if not can_run_room_enter_story(room):
		return

	# 이미 실행한 일회성 방 진입 이벤트라면 실행하지 않음
	var enter_story_flag = "room_enter_story_done_" + str(story_event_id)

	if has_flag(enter_story_flag):
		return

	var story_event_data = get_story_event_data_by_id(story_event_id)

	if story_event_data.is_empty():
		return

	if not story_event_data.has("events"):
		push_error("events가 없는 스토리 이벤트: " + str(story_event_id))
		return

	set_flag(enter_story_flag)

	await run_story_event(story_event_id)
# 스토리 이벤트용 방 변경 함수
func change_room_by_story(room_id):
	if get_room_data_by_id(room_id).is_empty():
		return

	apply_room_change(room_id)

# ============================================================
# 기타 함수 모음
# ============================================================

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
# 플레이어 체력 UI 갱신 함수
func update_player_status_ui():
	var display_max_hp = clamp_player_hp_to_current_max()

	player_hp_text.text = str(int(player_hp)) + " / " + str(int(display_max_hp))
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

# ============================================================
# 인벤토리 함수 모음
# ============================================================

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

	context_menu_item = null
	inventory_context_menu.visible = false

	selected_inventory_item = null

	update_inventory_ui()
	update_equipped_weapon_ui()
	update_player_status_ui()
	update_inventory_portrait_ui()

	if bag_open_sound != null:
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
# 인벤토리 UI 아이템 표시 갱신 함수
func update_inventory_ui():

	# 기존에 표시된 아이템 이미지 제거
	for child in inventory_slots.get_children():
		child.queue_free()

	# 현재 가진 아이템을 슬롯 위치 기준으로 표시
	for inventory_item in inventory:

		if inventory_item == null:
			continue

		if typeof(inventory_item) != TYPE_DICTIONARY:
			continue

		if not inventory_item.has("slot"):
			continue

		var image_path = get_item_image_path_from_inventory_item(inventory_item)

		if image_path == "":
			continue

		var item_size = get_inventory_item_grid_size(inventory_item)

		if item_size.x <= 0 or item_size.y <= 0:
			continue

		var start_slot = int(inventory_item.get("slot", -1))

		if start_slot < 0:
			continue

		var item_width = item_size.x
		var item_height = item_size.y

		var col = start_slot % inventory_cols
		var row = floori(start_slot / float(inventory_cols))

		var item_button = TextureButton.new()
		# 아이템 버튼이 Space 입력을 가져가지 않게 함
		item_button.focus_mode = Control.FOCUS_NONE
		item_button.texture_normal = load(image_path)
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
		item_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		item_button.z_index = 10

		item_button.pressed.connect(
			func():
				item_sound.play()
				select_inventory_item(inventory_item)
		)
		
		item_button.gui_input.connect(
			func(event):

				# 마우스 버튼 이벤트만 처리
				if event is InputEventMouseButton:
					# 기존 인벤토리 좌클릭 이벤트 처리
					if event.button_index == MOUSE_BUTTON_LEFT:
						if event.pressed:
							if inventory_context_menu.visible:
								close_context_menu()

							pressed_item = inventory_item
							pressed_item_button = item_button
							pressed_mouse_position = get_global_mouse_position()
						else:
							if is_dragging_item:
								stop_drag_item()

							pressed_item = null
							pressed_item_button = null
					# 기존 인벤토리 우클릭 이벤트 처리
					if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
						item_sound.play()
						selected_inventory_item = inventory_item
						show_selected_item_info(inventory_item)
						update_inventory_ui()
						open_context_menu(inventory_item)
						get_viewport().set_input_as_handled()
		)

		inventory_slots.add_child(item_button)
		add_item_count_label(item_button, inventory_item)

		if selected_inventory_item == inventory_item:
			create_inventory_selected_focus(start_slot, item_width, item_height)
# 인벤토리 가방에 넣지 못한 아이템을 임시 보관함에 추가하는 함수
func add_pending_loot(item_id, count = 1):
	if item_id == "":
		return

	if count <= 0:
		return

	for loot_item in pending_loot:
		if loot_item.get("id", "") == item_id:
			loot_item["count"] = int(loot_item.get("count", 1)) + count
			return

	pending_loot.append({
		"id": item_id,
		"count": count
	})
# 기존 인벤토리 선택 포커스 생성 함수
func create_inventory_selected_focus(start_slot, item_width, item_height):
	var col = start_slot % inventory_cols
	var row = floori(start_slot / float(inventory_cols))

	var focus_panel = Panel.new()
	focus_panel.position = Vector2(
		col * (inventory_slot_size + inventory_slot_gap),
		row * (inventory_slot_size + inventory_slot_gap)
	)

	focus_panel.size = Vector2(
		(inventory_slot_size * item_width) + (inventory_slot_gap * (item_width - 1)),
		(inventory_slot_size * item_height) + (inventory_slot_gap * (item_height - 1))
	)

	focus_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_panel.z_index = 20

	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.08)
	style.border_color = Color(1, 1, 1, 0.08)
	style.set_border_width_all(4)

	focus_panel.add_theme_stylebox_override("panel", style)

	inventory_slots.add_child(focus_panel)
# 기존 인벤토리 선택 아이템 지정 함수
func select_inventory_item(inventory_item):
	selected_inventory_item = inventory_item

	if inventory_item == null:
		clear_selected_item_info()
		update_inventory_ui()
		return

	show_selected_item_info(inventory_item)
	update_inventory_ui()
# 아이템이 차지하는 슬롯 목록 반환 함수
# 기존 인벤토리 코드 호환용 래퍼
func get_occupied_slots(inventory_item):
	return get_inventory_item_occupied_slots(inventory_item)
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

	if dragged_item == null or dragged_item_button == null:
		is_dragging_item = false
		dragged_item = null
		dragged_item_button = null
		slot_highlight.visible = false
		return

	var item_size = get_inventory_item_grid_size(dragged_item)

	if item_size.x <= 0 or item_size.y <= 0:
		if dragged_item_button != null:
			dragged_item_button.position = dragged_item_original_position
			dragged_item_button.z_index = 0

		is_dragging_item = false
		dragged_item = null
		dragged_item_button = null
		slot_highlight.visible = false
		return

	var item_width = item_size.x
	var item_height = item_size.y

	var target_slot = get_slot_from_mouse_position()

	# 스택 아이템이면 먼저 합치기 시도
	if target_slot != -1:
		var merged = try_merge_inventory_stack_item(
			dragged_item,
			target_slot
		)

		if merged:
			dragged_item_button.z_index = 0

			is_dragging_item = false
			dragged_item = null
			dragged_item_button = null
			slot_highlight.visible = false

			update_inventory_ui()
			update_equipped_weapon_ui()
			update_player_status_ui()
			return

	# 스택 병합이 안 되는 1x1 아이템끼리는 자리 교환
	if target_slot != -1:
		var swapped = try_swap_inventory_1x1_items(
			dragged_item,
			target_slot
		)

		if swapped:
			item_sound.play()

			dragged_item_button.z_index = 0

			is_dragging_item = false
			dragged_item = null
			dragged_item_button = null
			slot_highlight.visible = false

			update_inventory_ui()
			update_equipped_weapon_ui()
			update_player_status_ui()
			return
			
	# 정상 슬롯이고 배치 가능하면 이동
	if target_slot != -1:
		if can_place_item_at_except(
			target_slot,
			item_width,
			item_height,
			dragged_item
		):
			dragged_item["slot"] = target_slot
			item_sound.play()
			update_inventory_ui()
			update_equipped_weapon_ui()
			update_player_status_ui()

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
# 인벤토리 아이템이 1x1 크기인지 확인하는 함수
func is_inventory_item_1x1(inventory_item):
	var item_size = get_inventory_item_grid_size(inventory_item)

	if item_size.x <= 0 or item_size.y <= 0:
		return false

	return item_size.x == 1 and item_size.y == 1
# 기존 인벤토리에서 1x1 아이템끼리 자리 교환 가능한지 확인하는 함수
func can_swap_inventory_1x1_items(source_item, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if target_slot == -1:
		return false

	if not is_inventory_item_1x1(source_item):
		return false

	var target_index = find_inventory_item_index_at_slot(target_slot, source_item)

	if target_index < 0:
		return false

	if target_index >= inventory.size():
		return false

	if inventory[target_index] == null:
		return false

	if typeof(inventory[target_index]) != TYPE_DICTIONARY:
		return false

	if inventory[target_index] == source_item:
		return false

	if not is_inventory_item_1x1(inventory[target_index]):
		return false

	# 스택 병합이 가능한 경우에는 자리 교환보다 병합을 우선함
	if can_merge_inventory_stack_item(source_item, target_slot):
		return false

	return true
# 기존 인벤토리에서 1x1 아이템끼리 자리 교환 실행 함수
func try_swap_inventory_1x1_items(source_item, target_slot):
	if not can_swap_inventory_1x1_items(source_item, target_slot):
		return false

	var target_index = find_inventory_item_index_at_slot(target_slot, source_item)

	if target_index < 0:
		return false

	if target_index >= inventory.size():
		return false

	if inventory[target_index] == null:
		return false

	if typeof(inventory[target_index]) != TYPE_DICTIONARY:
		return false

	var source_slot = int(source_item.get("slot", -1))
	var target_item_slot = int(inventory[target_index].get("slot", -1))

	if source_slot < 0:
		return false

	if target_item_slot < 0:
		return false

	source_item["slot"] = target_item_slot
	inventory[target_index]["slot"] = source_slot

	selected_inventory_item = source_item
	show_selected_item_info(source_item)

	return true
# 기존 인벤토리에서 스택 합치기 가능 여부 확인 함수
func can_merge_inventory_stack_item(source_item, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if target_slot == -1:
		return false

	var source_id = source_item.get("id", "")

	if source_id == "":
		return false

	var item_data = get_item_data_by_id(source_id)

	if item_data.is_empty():
		return false

	if not item_data.get("stackable", false):
		return false

	var max_stack = max(int(item_data.get("max_stack", 1)), 1)

	if max_stack <= 1:
		return false

	var target_index = find_inventory_item_index_at_slot(target_slot, source_item)

	if target_index < 0:
		return false

	if target_index >= inventory.size():
		return false

	var target_item = inventory[target_index]

	if target_item == null:
		return false

	if typeof(target_item) != TYPE_DICTIONARY:
		return false

	if target_item.get("id", "") != source_id:
		return false

	var target_count = int(target_item.get("count", 1))

	if target_count >= max_stack:
		return false

	return true
# 기존 인벤토리 스택 합치기 실행 함수
func try_merge_inventory_stack_item(source_item, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if not can_merge_inventory_stack_item(source_item, target_slot):
		return false

	var source_id = source_item.get("id", "")

	if source_id == "":
		return false

	var item_data = get_item_data_by_id(source_id)

	if item_data.is_empty():
		return false

	var max_stack = max(int(item_data.get("max_stack", 1)), 1)

	var target_index = find_inventory_item_index_at_slot(target_slot, source_item)

	if target_index < 0:
		return false

	if target_index >= inventory.size():
		return false

	var source_count = int(source_item.get("count", 1))
	var target_count = int(inventory[target_index].get("count", 1))

	var move_count = min(source_count, max_stack - target_count)

	if move_count <= 0:
		return false

	# target_item 변수에 직접 대입하지 않고 inventory index로 수정
	inventory[target_index]["count"] = target_count + move_count
	source_count -= move_count

	if source_count <= 0:
		if selected_inventory_item == source_item:
			selected_inventory_item = inventory[target_index]

		inventory.erase(source_item)
	else:
		source_item["count"] = source_count

	selected_inventory_item = inventory[target_index]
	show_selected_item_info(selected_inventory_item)

	if item_sound != null:
		item_sound.play()

	return true
# 특정 슬롯을 차지하고 있는 인벤토리 아이템 index 찾기 함수
func find_inventory_item_index_at_slot(slot, ignored_item = null):
	if slot < 0:
		return -1

	for i in range(inventory.size()):
		var item = inventory[i]

		if item == ignored_item:
			continue

		if item == null:
			continue

		if typeof(item) != TYPE_DICTIONARY:
			continue

		if not item.has("slot"):
			continue

		var occupied_slots = get_occupied_slots(item)

		if occupied_slots.has(slot):
			return i

	return -1
# 인벤토리 우클릭 메뉴 버튼 연결 함수
func connect_inventory_context_menu_buttons():
	if not use_button.pressed.is_connected(_on_use_button_pressed):
		use_button.pressed.connect(_on_use_button_pressed)

	if not equip_button.pressed.is_connected(_on_equip_button_pressed):
		equip_button.pressed.connect(_on_equip_button_pressed)

	if not drop_button.pressed.is_connected(_on_drop_button_pressed):
		drop_button.pressed.connect(_on_drop_button_pressed)

	var rotate_callable = Callable(self, "_on_rotate_button_pressed")

	if has_method("_on_rotate_button_pressed"):
		if not rotate_button.pressed.is_connected(rotate_callable):
			rotate_button.pressed.connect(rotate_callable)
# 장착 무기 효과 텍스트를 ScrollContainer 안에 넣는 함수
func setup_equipped_weapon_text_scroll():
	if equipped_weapon_text == null:
		return

	if equipped_weapon_text_scroll != null:
		return

	var parent_node = equipped_weapon_text.get_parent()

	if parent_node == null:
		return

	var old_position = equipped_weapon_text.position
	var old_size = equipped_weapon_text.size
	var old_index = equipped_weapon_text.get_index()

	equipped_weapon_text_scroll = ScrollContainer.new()
	equipped_weapon_text_scroll.name = "EquippedWeaponTextScroll"
	equipped_weapon_text_scroll.position = old_position
	equipped_weapon_text_scroll.size = old_size
	equipped_weapon_text_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	# 스크롤바 안보이게 처리
	equipped_weapon_text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	equipped_weapon_text_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

	parent_node.remove_child(equipped_weapon_text)
	parent_node.add_child(equipped_weapon_text_scroll)
	parent_node.move_child(equipped_weapon_text_scroll, old_index)

	equipped_weapon_text.position = Vector2.ZERO
	equipped_weapon_text.size = Vector2(old_size.x - 24, old_size.y)
	equipped_weapon_text.custom_minimum_size = Vector2(old_size.x - 24, 0)
	equipped_weapon_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	equipped_weapon_text.clip_text = false
	equipped_weapon_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equipped_weapon_text.add_theme_constant_override("line_separation", 8)

	equipped_weapon_text_scroll.add_child(equipped_weapon_text)
# 선택 아이템 설명 텍스트를 ScrollContainer 안에 넣는 공통 함수
func setup_text_node_scroll(text_node, scroll_name):
	if text_node == null:
		return null

	var parent_node = text_node.get_parent()

	if parent_node == null:
		return null

	if parent_node is ScrollContainer:
		return parent_node

	var old_position = text_node.position
	var old_size = text_node.size
	var old_index = text_node.get_index()

	var scroll = ScrollContainer.new()
	scroll.name = scroll_name
	scroll.position = old_position
	scroll.size = old_size
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	# 스크롤바 안보이게 처리 인벤토리 설명
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

	parent_node.remove_child(text_node)
	parent_node.add_child(scroll)
	parent_node.move_child(scroll, old_index)

	text_node.position = Vector2.ZERO
	text_node.size = Vector2(old_size.x - 24, old_size.y)
	text_node.custom_minimum_size = Vector2(old_size.x - 24, old_size.y)
	text_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if text_node is Label:
		text_node.clip_text = false

	if text_node is RichTextLabel:
		text_node.bbcode_enabled = true
		text_node.fit_content = true
		text_node.scroll_active = false

	scroll.add_child(text_node)

	return scroll
# 인벤토리 / 인벤토리 정리 설명창 RichTextLabel 변환 + 스크롤 세팅 함수
func setup_selected_item_description_scrolls():
	selected_item_description = convert_label_to_rich_text_label(
		selected_item_description,
		"SelectedItemDescriptionRichText"
	)

	arrange_selected_item_text = convert_label_to_rich_text_label(
		arrange_selected_item_text,
		"ArrangeSelectedItemTextRichText"
	)

	selected_item_description_scroll = setup_text_node_scroll(
		selected_item_description,
		"SelectedItemDescriptionScroll"
	)

	arrange_selected_item_text_scroll = setup_text_node_scroll(
		arrange_selected_item_text,
		"ArrangeSelectedItemTextScroll"
	)
# BBCode 충돌 방지용 텍스트 이스케이프
func escape_rich_text(value):
	var text = str(value)
	text = text.replace("[", "[lb]")
	text = text.replace("]", "[rb]")
	return text
# 텍스트 색상 적용 함수
func make_colored_text(text, color):
	return "[color=" + color + "]" + str(text) + "[/color]"
# 기존 Label을 RichTextLabel로 교체하는 함수
func convert_label_to_rich_text_label(text_node, rich_name):
	if text_node == null:
		return null

	if text_node is RichTextLabel:
		text_node.bbcode_enabled = true
		text_node.fit_content = true
		text_node.scroll_active = false
		text_node.add_theme_constant_override("line_separation", 8)
		return text_node

	var parent_node = text_node.get_parent()

	if parent_node == null:
		return text_node

	var old_position = text_node.position
	var old_size = text_node.size
	var old_index = text_node.get_index()
	var old_visible = text_node.visible
	var old_text = text_node.text
	var old_z_index = text_node.z_index
	var old_modulate = text_node.modulate

	var rich = RichTextLabel.new()
	rich.name = rich_name
	rich.position = old_position
	rich.size = old_size
	rich.custom_minimum_size = old_size
	rich.visible = old_visible
	rich.z_index = old_z_index
	rich.modulate = old_modulate
	
	var font = load("res://fonts/x12y12pxMaruMinyaHangul.ttf")
	rich.add_theme_color_override("font_color",Color("#d8d0c8"))
	rich.add_theme_font_override("normal_font", font)
	rich.add_theme_font_size_override("normal_font_size", 25)
	rich.add_theme_constant_override("line_separation", 8)

	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.selection_enabled = false
	rich.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rich.mouse_filter = Control.MOUSE_FILTER_IGNORE

	parent_node.remove_child(text_node)
	parent_node.add_child(rich)
	parent_node.move_child(rich, old_index)

	rich.text = old_text

	return rich
# 변화가 있으면 상승/하락 색상으로 표시하는 함수
func make_changed_value_text(base_value, effective_value, suffix = "", digit_count = 0, higher_is_better = true):
	var base_float = float(base_value)
	var effective_float = float(effective_value)

	var value_text = ""

	if digit_count <= 0:
		value_text = str(int(round(effective_float)))
	else:
		value_text = format_stat_float(effective_float, digit_count)

	value_text += suffix

	if is_equal_approx(base_float, effective_float):
		return value_text

	var is_increased = effective_float > base_float
	var is_good_change = is_increased == higher_is_better

	if is_good_change:
		return make_colored_text(value_text, STAT_GOOD_COLOR)

	return make_colored_text(value_text, STAT_BAD_COLOR)
# 패링 범위 등급 텍스트
func make_parry_window_grade_text(parry_window):
	var value = float(parry_window)

	if value <= 0.1:
		return make_colored_text("낮음", STAT_BAD_COLOR)

	if value >= 0.3:
		return make_colored_text("넓음", STAT_GOOD_COLOR)

	return "보통"
# 스윙 속도 등급 텍스트
func make_attack_swing_speed_grade_text(attack_swing_speed):
	var value = float(attack_swing_speed)

	if value <= 2.0:
		return make_colored_text("느림", STAT_BAD_COLOR)

	if value >= 3.0:
		return make_colored_text("빠름", STAT_GOOD_COLOR)

	return "보통"
# 방어 이동 속도 등급 텍스트
func make_defense_move_speed_grade_text(defense_move_speed):
	var value = float(defense_move_speed)

	if value <= 200.0:
		return make_colored_text("느림", STAT_BAD_COLOR)

	if value >= 400.0:
		return make_colored_text("빠름", STAT_GOOD_COLOR)

	return "보통"
# 선택한 무기에 관통 효과 표시가 필요한지 확인하는 함수
func should_show_weapon_piercing_effect(_item_id, item_data, is_current_equipped_weapon, effective_stats):
	if bool(item_data.get("piercing", false)):
		return true

	if is_current_equipped_weapon:
		if bool(effective_stats.get("piercing", false)):
			return true

	return false
# 인벤토리 정리 화면 열기 함수
func open_inventory_arrange(mode, left_items):
	is_inventory_arrange_open = true
	inventory_arrange_mode = mode
	arrange_left_inventory = left_items.duplicate(true)
	selected_arrange_item = null
	selected_arrange_source = ""
	clear_arrange_selected_focus()
	clear_arrange_selected_item_info()
	
	normalize_arrange_left_slots()

	# 기존 인벤토리 여는 효과음과 동일하게 사용
	if bag_open_sound != null:
		bag_open_sound.play()

	inventory_arrange_ui.visible = true
	clear_arrange_selected_item_info()
	
	if inventory_arrange_mode == "loot":
		arrange_discard_notice_label.visible = true
		arrange_discard_notice_label.text = "※ 왼쪽에 남은 아이템은 버려집니다."
	else:
		arrange_discard_notice_label.visible = false
	
	update_inventory_arrange_ui()

	print("인벤토리 정리 화면 열림 mode: ", inventory_arrange_mode)
	print("left items: ", arrange_left_inventory)
# 인벤토리 정리 화면 왼쪽 아이템 slot 보정 함수
func normalize_arrange_left_slots():
	var next_slot = 0

	for item in arrange_left_inventory:
		if item.has("slot"):
			continue

		item["slot"] = next_slot
		next_slot += 1
# 인벤토리 정리 화면 UI 갱신 함수
func update_inventory_arrange_ui():
	for child in arrange_left_items.get_children():
		child.queue_free()

	for child in arrange_right_items.get_children():
		child.queue_free()

	for item in arrange_left_inventory:
		create_arrange_item_icon(
			item,
			arrange_left_items,
			arrange_left_grid_position,
			arrange_left_cols,
			"left"
		)

	for item in inventory:
		create_arrange_item_icon(
			item,
			arrange_right_items,
			arrange_right_grid_position,
			arrange_right_cols,
			"right"
		)

	update_arrange_selected_focus()
# 인벤토리 정리 화면 아이템 아이콘 생성 함수
func create_arrange_item_icon(inventory_item, parent_node, grid_position, grid_cols, source):
	if inventory_item == null:
		return

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return

	if not inventory_item.has("slot"):
		return

	var item_size = get_inventory_item_grid_size(inventory_item)

	if item_size.x <= 0 or item_size.y <= 0:
		return

	var image_path = get_item_image_path_from_inventory_item(inventory_item)

	if image_path == "":
		return

	var slot = int(inventory_item["slot"])
	var item_width = item_size.x
	var item_height = item_size.y

	var col = slot % grid_cols
	var row = floori(slot / float(grid_cols))

	var icon = TextureButton.new()
	icon.focus_mode = Control.FOCUS_NONE

	if image_path != "":
		icon.texture_normal = load(image_path)

	icon.ignore_texture_size = true
	icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	var slot_step = arrange_slot_size + arrange_slot_gap

	icon.position = grid_position + Vector2(
		col * slot_step,
		row * slot_step
	)
	
	icon.size = Vector2(
		item_width * arrange_slot_size + (item_width - 1) * arrange_slot_gap,
		item_height * arrange_slot_size + (item_height - 1) * arrange_slot_gap
	)

	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.z_index = 10

	icon.gui_input.connect(
		func(event):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						arrange_pressed_item = inventory_item
						arrange_pressed_button = icon
						arrange_pressed_source = source
						arrange_pressed_mouse_position = get_global_mouse_position()
					else:
						if is_arrange_dragging_item:
							stop_arrange_drag_item()
						else:
							item_sound.play()
							select_arrange_item(inventory_item, source)

						arrange_pressed_item = null
						arrange_pressed_button = null
						arrange_pressed_source = ""
			)

	parent_node.add_child(icon)

	add_item_count_label(icon, inventory_item)
# 인벤토리 정리 화면 아이템 드래그 시작 함수
func start_arrange_drag_item(inventory_item, item_button, source):
	is_arrange_dragging_item = true

	arrange_dragged_item = inventory_item
	arrange_dragged_button = item_button
	arrange_dragged_source = source
	arrange_dragged_original_slot = int(inventory_item.get("slot", -1))
	arrange_dragged_original_global_position = item_button.global_position

	item_button.z_index = 100
# 인벤토리 정리 화면 아이템 드래그 종료 함수
func stop_arrange_drag_item():
	if arrange_dragged_item == null or arrange_dragged_button == null:
		reset_arrange_drag_state()
		return

	var mouse_pos = get_global_mouse_position()
	var target_source = get_arrange_drop_target_source(mouse_pos)

	if target_source == "":
		cancel_arrange_drag_item()
		return

	var target_slot = get_arrange_slot_from_global_position(mouse_pos, target_source)

	if target_slot == -1:
		cancel_arrange_drag_item()
		return
		
	var swapped = try_swap_arrange_1x1_items(
		arrange_dragged_item,
		arrange_dragged_source,
		target_source,
		target_slot
	)

	if swapped:
		var swapped_item = arrange_dragged_item
		var swapped_target_source = target_source

		if item_sound != null:
			item_sound.play()

		reset_arrange_drag_state()
		clear_arrange_selected_focus()
		update_inventory_arrange_ui()
		update_equipped_weapon_ui()
		update_player_status_ui()

		select_arrange_item(swapped_item, swapped_target_source)

		clear_arrange_slot_highlights()
		return

	var merged = try_merge_arrange_stack_item(
		arrange_dragged_item,
		arrange_dragged_source,
		target_source,
		target_slot
	)

	if merged:
		var merged_source_item = arrange_dragged_item
		var merged_source = arrange_dragged_source
		
		if item_sound != null:
			item_sound.play()

		reset_arrange_drag_state()
		clear_arrange_selected_focus()
		update_inventory_arrange_ui()

		if merged_source_item != null and int(merged_source_item.get("count", 0)) > 0:
			select_arrange_item(merged_source_item, merged_source)
		else:
			selected_arrange_item = null
			selected_arrange_source = ""
			clear_arrange_selected_item_info()
			clear_arrange_selected_focus()

		clear_arrange_slot_highlights()
		return

	var moved = move_arrange_item_to_grid(
		arrange_dragged_item,
		arrange_dragged_source,
		target_source,
		target_slot
	)

	if not moved:
		cancel_arrange_drag_item()
		return

	var moved_item = arrange_dragged_item
	var moved_target_source = target_source
	
	if item_sound != null:
		item_sound.play()

	reset_arrange_drag_state()
	clear_arrange_selected_focus()
	update_inventory_arrange_ui()

	select_arrange_item(moved_item, moved_target_source)

	clear_arrange_slot_highlights()
# 인벤토리 정리 화면 드롭 위치가 왼쪽/오른쪽 중 어디인지 반환하는 함수
func get_arrange_drop_target_source(global_pos):
	var left_rect = Rect2(
		arrange_left_grid_position,
		get_arrange_grid_pixel_size(arrange_left_cols, arrange_left_rows)
	)

	var right_rect = Rect2(
		arrange_right_grid_position,
		get_arrange_grid_pixel_size(arrange_right_cols, arrange_right_rows)
	)

	if left_rect.has_point(global_pos):
		return "left"

	if right_rect.has_point(global_pos):
		return "right"

	return ""
# 인벤토리 정리 화면 사이즈 그리드 사이즈 함수
func get_arrange_grid_pixel_size(cols, rows):
	return Vector2(
		cols * arrange_slot_size + (cols - 1) * arrange_slot_gap,
		rows * arrange_slot_size + (rows - 1) * arrange_slot_gap
	)
# 인벤토리 정리 화면 전역 좌표를 슬롯 번호로 변환하는 함수
func get_arrange_slot_from_global_position(global_pos, source):
	var grid_position = arrange_left_grid_position
	var cols = arrange_left_cols
	var rows = arrange_left_rows

	if source == "right":
		grid_position = arrange_right_grid_position
		cols = arrange_right_cols
		rows = arrange_right_rows

	var local_pos = global_pos - grid_position
	var slot_step = arrange_slot_size + arrange_slot_gap

	var col = int(local_pos.x / slot_step)
	var row = int(local_pos.y / slot_step)

	if col < 0 or col >= cols:
		return -1

	if row < 0 or row >= rows:
		return -1

	# 슬롯 사이 gap 영역에 놓았으면 실패 처리
	var inside_x = fmod(local_pos.x, slot_step)
	var inside_y = fmod(local_pos.y, slot_step)

	if inside_x > arrange_slot_size:
		return -1

	if inside_y > arrange_slot_size:
		return -1

	return row * cols + col
# 인벤토리 정리 화면 아이템 이동 함수
func move_arrange_item_to_grid(item, from_source, to_source, target_slot):
	if item == null:
		return false

	if typeof(item) != TYPE_DICTIONARY:
		return false

	var item_size = get_inventory_item_grid_size(item)

	if item_size.x <= 0 or item_size.y <= 0:
		return false

	var item_width = item_size.x
	var item_height = item_size.y

	var target_list = get_arrange_item_list(to_source)
	var target_cols = get_arrange_grid_cols(to_source)
	var target_rows = get_arrange_grid_rows(to_source)

	if not can_place_item_at_arrange_grid(
		target_list,
		target_slot,
		item_width,
		item_height,
		target_cols,
		target_rows,
		item
	):
		return false

	# 오른쪽 가방에서 왼쪽 임시 영역으로 나가는 경우 장착 해제
	if from_source == "right" and to_source == "left":
		unequip_item_if_moved_out_from_inventory(item)

	remove_arrange_item_from_source(item, from_source)

	item["slot"] = target_slot

	if to_source == "left":
		arrange_left_inventory.append(item)
	else:
		inventory.append(item)

	if selected_arrange_item == item:
		selected_arrange_source = to_source
		
	return true
# 인벤토리 정리 화면 source에 맞는 아이템 목록 반환 함수
func get_arrange_item_list(source):
	if source == "left":
		return arrange_left_inventory

	return inventory
# 인벤토리 정리 화면 source에 맞는 열 개수 반환 함수
func get_arrange_grid_cols(source):
	if source == "left":
		return arrange_left_cols

	return arrange_right_cols
# 인벤토리 정리 화면 source에 맞는 행 개수 반환 함수
func get_arrange_grid_rows(source):
	if source == "left":
		return arrange_left_rows

	return arrange_right_rows
# 인벤토리 정리 화면 source에서 특정 아이템 제거 함수
func remove_arrange_item_from_source(item, source):
	var target_list = get_arrange_item_list(source)

	if target_list.has(item):
		target_list.erase(item)
# 인벤토리 정리 화면 아이템이 차지하는 슬롯 목록 반환 함수
func get_arrange_occupied_slots(item, cols):
	if item == null:
		return []

	if typeof(item) != TYPE_DICTIONARY:
		return []

	if not item.has("slot"):
		return []

	var item_size = get_inventory_item_grid_size(item)

	if item_size.x <= 0 or item_size.y <= 0:
		return []

	var start_slot = int(item.get("slot", -1))

	return get_grid_slots_from_size(
		start_slot,
		item_size.x,
		item_size.y,
		cols
	)
# 인벤토리 정리 화면 특정 위치에 아이템 배치 가능 여부 확인 함수
func can_place_item_at_arrange_grid(item_list, start_slot, item_width, item_height, cols, rows, ignore_item = null):
	if start_slot < 0:
		return false

	if cols <= 0:
		return false

	if rows <= 0:
		return false

	var start_col = int(start_slot) % int(cols)
	var start_row = floori(int(start_slot) / float(cols))

	# 오른쪽/아래로 정리 가방 범위를 넘으면 배치 불가
	if start_col + int(item_width) > int(cols):
		return false

	if start_row + int(item_height) > int(rows):
		return false

	var target_slots = get_grid_slots_from_size(
		start_slot,
		item_width,
		item_height,
		cols
	)

	for other_item in item_list:
		if other_item == ignore_item:
			continue

		var occupied_slots = get_arrange_occupied_slots(other_item, cols)

		for slot in target_slots:
			if occupied_slots.has(slot):
				return false

	return true
# 인벤토리 정리 화면 드래그 취소 함수
func cancel_arrange_drag_item():
	if arrange_dragged_button != null:
		arrange_dragged_button.global_position = arrange_dragged_original_global_position
		arrange_dragged_button.z_index = 10

	reset_arrange_drag_state()
	clear_arrange_slot_highlights()
# 인벤토리 정리 화면 드래그 상태 초기화 함수
func reset_arrange_drag_state():
	is_arrange_dragging_item = false
	arrange_dragged_item = null
	arrange_dragged_button = null
	arrange_dragged_source = ""
	arrange_dragged_original_slot = -1
	arrange_dragged_original_global_position = Vector2.ZERO

	arrange_pressed_item = null
	arrange_pressed_button = null
	arrange_pressed_source = ""
# 인벤토리 정리 화면 닫기 함수 (추후에 창고 만들때 여기서 분리 처리!)
func close_inventory_arrange():
	selected_arrange_item = null
	selected_arrange_source = ""
	clear_arrange_selected_focus()
	clear_arrange_selected_item_info()

	if is_arrange_dragging_item:
		cancel_arrange_drag_item()
		
	var discarded_items = []

	if inventory_arrange_mode == "loot":
		discarded_items = arrange_left_inventory.duplicate(true)

	is_inventory_arrange_open = false
	inventory_arrange_mode = ""
	# 추후에 창고 만들때 여기서 분리 처리!
	arrange_left_inventory.clear()
	
	#if inventory_arrange_mode == "storage":
		#storage_inventory = arrange_left_inventory.duplicate(true)
	#else:
		#arrange_left_inventory.clear()

	inventory_arrange_ui.visible = false
	arrange_discard_notice_label.visible = false

	# 클리어 처리
	clear_selected_item_info()
	clear_arrange_selected_item_info()

	if bag_open_sound != null:
		bag_open_sound.play()

	set_interaction_buttons_disabled(false)

	var discard_messages = make_discarded_item_messages(discarded_items)

	for message in discard_messages:
		print(message)
	
	clear_arrange_slot_highlights()
	print("인벤토리 정리 화면 종료")
# 인벤토리 정리 화면 스택 아이템 병합 시도 함수
func try_merge_arrange_stack_item(source_item, from_source, to_source, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if from_source == "":
		return false

	if to_source == "":
		return false

	if target_slot == -1:
		return false

	var source_item_id = source_item.get("id", "")

	if source_item_id == "":
		return false

	var item_data = get_item_data_by_id(source_item_id)

	if item_data.is_empty():
		return false

	if not item_data.get("stackable", false):
		return false

	var max_stack = max(int(item_data.get("max_stack", 1)), 1)

	if max_stack <= 1:
		return false

	var target_list = get_arrange_item_list(to_source)
	var target_index = get_arrange_item_index_at_slot(to_source, target_slot, source_item)

	# 타겟 슬롯에 아이템이 없으면 병합이 아니라 일반 이동 대상
	if target_index < 0:
		return false

	if target_index >= target_list.size():
		return false

	var target_item = target_list[target_index]

	if target_item == null:
		return false

	if typeof(target_item) != TYPE_DICTIONARY:
		return false

	# 자기 자신 위에 놓은 경우는 병합 아님
	if target_item == source_item:
		return false

	if target_item.get("id", "") != source_item_id:
		return false

	var source_count = int(source_item.get("count", 1))
	var target_count = int(target_item.get("count", 1))

	if source_count <= 0:
		return false

	if target_count >= max_stack:
		return false

	var space = max_stack - target_count
	var move_count = min(source_count, space)

	if move_count <= 0:
		return false

	# 여기부터 실제 병합
	target_list[target_index]["count"] = target_count + move_count
	source_item["count"] = source_count - move_count

	print("스택 병합: " + source_item_id + " +" + str(move_count))

	# 전부 병합됐으면 원래 아이템 제거
	if int(source_item["count"]) <= 0:
		if selected_arrange_item == source_item:
			selected_arrange_item = target_list[target_index]
			selected_arrange_source = to_source

		if from_source == "right" and to_source == "left":
			unequip_item_if_moved_out_from_inventory(source_item)

		remove_arrange_item_from_source(source_item, from_source)

	return true
# 정리 화면 스택 병합 가능 여부 확인 함수
func can_merge_arrange_stack_item(source_item, to_source, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if to_source == "":
		return false

	if target_slot == -1:
		return false

	var source_item_id = source_item.get("id", "")

	if source_item_id == "":
		return false

	var item_data = get_item_data_by_id(source_item_id)

	if item_data.is_empty():
		return false

	if not item_data.get("stackable", false):
		return false

	var max_stack = max(int(item_data.get("max_stack", 1)), 1)

	if max_stack <= 1:
		return false

	var target_index = get_arrange_item_index_at_slot(to_source, target_slot, source_item)

	if target_index < 0:
		return false

	var target_list = get_arrange_item_list(to_source)

	if target_index >= target_list.size():
		return false

	var target_item = target_list[target_index]

	if target_item == null:
		return false

	if typeof(target_item) != TYPE_DICTIONARY:
		return false

	if target_item == source_item:
		return false

	if target_item.get("id", "") != source_item_id:
		return false

	var target_count = int(target_item.get("count", 1))

	return target_count < max_stack
# 인벤토리 정리 화면 특정 슬롯을 차지하고 있는 아이템 index 찾기 함수
# ignore_item을 넣으면 해당 아이템은 검사에서 제외함
func get_arrange_item_index_at_slot(source, slot, ignore_item = null):
	if slot < 0:
		return -1

	var item_list = get_arrange_item_list(source)
	var cols = get_arrange_grid_cols(source)

	for i in range(item_list.size()):
		var item = item_list[i]

		if item == ignore_item:
			continue

		if item == null:
			continue

		if typeof(item) != TYPE_DICTIONARY:
			continue

		if not item.has("slot"):
			continue

		var occupied_slots = get_arrange_occupied_slots(item, cols)

		if occupied_slots.has(slot):
			return i

	return -1
# 인벤토리 정리 화면 특정 슬롯을 차지하고 있는 아이템 반환 함수
# 선택 사항: 아이템 자체 반환 함수 추가
func get_arrange_item_at_slot(source, slot, ignore_item = null):
	var item_index = get_arrange_item_index_at_slot(source, slot, ignore_item)

	if item_index < 0:
		return null

	var item_list = get_arrange_item_list(source)

	if item_index >= item_list.size():
		return null

	return item_list[item_index]
# 인벤토리 정리 화면 아이템이 1x1 크기인지 확인하는 함수
func is_arrange_item_1x1(item):
	var item_size = get_inventory_item_grid_size(item)

	if item_size.x <= 0 or item_size.y <= 0:
		return false

	return item_size.x == 1 and item_size.y == 1
# 인벤토리 정리 화면에서 1x1 아이템끼리 자리 교환 가능한지 확인하는 함수
func can_swap_arrange_1x1_items(source_item, from_source, to_source, target_slot):
	if source_item == null:
		return false

	if typeof(source_item) != TYPE_DICTIONARY:
		return false

	if from_source == "":
		return false

	if to_source == "":
		return false

	if target_slot == -1:
		return false

	if not is_arrange_item_1x1(source_item):
		return false

	var target_list = get_arrange_item_list(to_source)
	var target_index = get_arrange_item_index_at_slot(to_source, target_slot)

	if target_index < 0:
		return false

	if target_index >= target_list.size():
		return false

	var target_item = target_list[target_index]

	if target_item == null:
		return false

	if typeof(target_item) != TYPE_DICTIONARY:
		return false

	if target_item == source_item:
		return false

	if not is_arrange_item_1x1(target_item):
		return false

	# 스택 병합이 가능한 경우에는 교환보다 병합을 우선함
	if can_merge_arrange_stack_item(source_item, to_source, target_slot):
		return false

	return true
# 인벤토리 정리 화면에서 1x1 아이템끼리 자리 교환 실행 함수
func try_swap_arrange_1x1_items(source_item, from_source, to_source, target_slot):
	if not can_swap_arrange_1x1_items(source_item, from_source, to_source, target_slot):
		return false

	var from_list = get_arrange_item_list(from_source)
	var to_list = get_arrange_item_list(to_source)
	var target_index = get_arrange_item_index_at_slot(to_source, target_slot)

	if target_index < 0:
		return false

	if target_index >= to_list.size():
		return false

	var target_item = to_list[target_index]

	if target_item == null:
		return false

	var source_slot = int(source_item.get("slot", -1))
	var target_item_slot = int(target_item.get("slot", -1))

	if source_slot < 0:
		return false

	if target_item_slot < 0:
		return false

	# 같은 영역 안에서 자리만 교환
	if from_source == to_source:
		source_item["slot"] = target_item_slot
		to_list[target_index]["slot"] = source_slot
		return true

	# 서로 다른 영역이면 실제 목록도 교환
	if not from_list.has(source_item):
		return false

	from_list.erase(source_item)
	to_list.erase(target_item)

	source_item["slot"] = target_item_slot
	target_item["slot"] = source_slot

	from_list.append(target_item)
	to_list.append(source_item)

	# 오른쪽 가방에서 왼쪽 임시 영역으로 나간 아이템은 장착 해제
	if from_source == "right" and to_source == "left":
		unequip_item_if_moved_out_from_inventory(source_item)

	if from_source == "left" and to_source == "right":
		unequip_item_if_moved_out_from_inventory(target_item)

	return true
# 인벤토리 정리 화면에서 버린 아이템 메시지 생성 함수
func make_discarded_item_messages(discarded_items):
	var messages = []

	for discarded_item in discarded_items:
		var item_id = discarded_item.get("id", "")

		if item_id == "":
			continue

		var item_data = get_item_data_by_id(item_id)

		if item_data.is_empty():
			continue

		var item_name = get_item_name(item_id)
		var count = int(discarded_item.get("count", 1))

		messages.append(item_name + " " + str(count) + "개를 버렸다.")

	return messages
# 인벤토리 정리 화면 선택 아이템 정보 표시 함수
func show_arrange_selected_item_info(inventory_item):
	show_item_info_ui(
		inventory_item,
		arrange_selected_item_image,
		arrange_selected_item_text
	)
# 인벤토리 정리 화면 선택 아이템 정보 제거 함수
func clear_arrange_selected_item_info():
	clear_item_info_ui(
		arrange_selected_item_image,
		arrange_selected_item_text
	)
# 인벤토리 정리 화면 슬롯 하이라이트 제거 함수
func clear_arrange_slot_highlights():
	for child in arrange_slot_highlight_container.get_children():
		arrange_slot_highlight_container.remove_child(child)
		child.free()
# 인벤토리 정리 화면 슬롯 하이라이트 칸 생성 함수
func create_arrange_slot_highlight(slot_position, is_valid):
	var rect = ColorRect.new()

	# 너무 진해서 알파 값 줄임
	if is_valid:
		rect.color = Color(0, 1, 0, 0.025)
	else:
		rect.color = Color(1, 0, 0, 0.025)

	rect.position = slot_position
	rect.size = Vector2(arrange_slot_size, arrange_slot_size)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = 5

	arrange_slot_highlight_container.add_child(rect)
# 인벤토리 정리 화면 특정 슬롯의 화면 좌표 반환 함수
func get_arrange_slot_position(source, slot):
	var grid_position = arrange_left_grid_position
	var cols = arrange_left_cols

	if source == "right":
		grid_position = arrange_right_grid_position
		cols = arrange_right_cols

	var slot_step = arrange_slot_size + arrange_slot_gap
	var col = slot % cols
	var row = floori(slot / float(cols))

	return grid_position + Vector2(col * slot_step, row * slot_step)
# 인벤토리 정리 화면 드래그 예상 위치 하이라이트 갱신 함수
func update_arrange_drag_slot_highlight():
	clear_arrange_slot_highlights()

	if not is_arrange_dragging_item:
		return

	if arrange_dragged_item == null:
		return

	var mouse_pos = get_global_mouse_position()
	var target_source = get_arrange_drop_target_source(mouse_pos)

	if target_source == "":
		return

	var target_slot = get_arrange_slot_from_global_position(mouse_pos, target_source)

	if target_slot == -1:
		return

	var item_size = get_inventory_item_grid_size(arrange_dragged_item)

	if item_size.x <= 0 or item_size.y <= 0:
		arrange_slot_highlight_container.visible = false
		return

	var item_width = item_size.x
	var item_height = item_size.y

	var target_list = get_arrange_item_list(target_source)
	var target_cols = get_arrange_grid_cols(target_source)
	var target_rows = get_arrange_grid_rows(target_source)

	var can_merge = can_merge_arrange_stack_item(
		arrange_dragged_item,
		target_source,
		target_slot
	)

	var can_swap = can_swap_arrange_1x1_items(
		arrange_dragged_item,
		arrange_dragged_source,
		target_source,
		target_slot
	)

	var can_place = can_place_item_at_arrange_grid(
		target_list,
		target_slot,
		item_width,
		item_height,
		target_cols,
		target_rows,
		arrange_dragged_item
	)

	var is_valid = can_merge or can_swap or can_place

	var start_col = target_slot % target_cols
	var start_row = floori(target_slot / float(target_cols))

	for y in range(item_height):
		for x in range(item_width):
			var col = start_col + x
			var row = start_row + y

			if col < 0 or col >= target_cols:
				continue

			if row < 0 or row >= target_rows:
				continue

			var slot = row * target_cols + col
			var slot_position = get_arrange_slot_position(target_source, slot)

			create_arrange_slot_highlight(slot_position, is_valid)
# 인벤토리 정리 화면 선택 포커스 제거 함수
func clear_arrange_selected_focus():
	for child in arrange_selected_focus_container.get_children():
		arrange_selected_focus_container.remove_child(child)
		child.free()
# 인벤토리 정리 화면 선택 포커스 갱신 함수
func update_arrange_selected_focus():
	clear_arrange_selected_focus()
	arrange_selected_focus_container.visible = true

	if selected_arrange_item == null:
		return

	if typeof(selected_arrange_item) != TYPE_DICTIONARY:
		return

	if selected_arrange_source == "":
		return

	if not selected_arrange_item.has("slot"):
		return

	var item_size = get_inventory_item_grid_size(selected_arrange_item)

	if item_size.x <= 0 or item_size.y <= 0:
		return

	var item_width = item_size.x
	var item_height = item_size.y
	
	var slot = int(selected_arrange_item.get("slot", 0))

	var focus_panel = Panel.new()
	focus_panel.position = get_arrange_slot_position(selected_arrange_source, slot)
	focus_panel.size = Vector2(
		item_width * arrange_slot_size + (item_width - 1) * arrange_slot_gap,
		item_height * arrange_slot_size + (item_height - 1) * arrange_slot_gap
	)
	focus_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_panel.z_index = 20

	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.08)
	style.border_color = Color(1, 1, 1, 0.08)
	style.set_border_width_all(4)

	focus_panel.add_theme_stylebox_override("panel", style)

	arrange_selected_focus_container.add_child(focus_panel)
# 인벤토리 정리 화면 선택 아이템 지정 함수
func select_arrange_item(inventory_item, _source):
	if inventory_item == null:
		selected_arrange_item = null
		selected_arrange_source = ""
		clear_arrange_selected_item_info()
		clear_arrange_selected_focus()
		return

	var real_source = get_real_arrange_item_source(inventory_item)

	if real_source == "":
		selected_arrange_item = null
		selected_arrange_source = ""
		clear_arrange_selected_item_info()
		clear_arrange_selected_focus()
		return

	selected_arrange_item = inventory_item
	selected_arrange_source = real_source

	show_arrange_selected_item_info(inventory_item)
	update_arrange_selected_focus()
# 인벤토리 정리 화면에서 장착 중인 아이템이 가방 밖으로 나갈 때 장착 해제하는 함수
func unequip_item_if_moved_out_from_inventory(item):
	if item == null:
		return

	if equipped_weapon == item:
		equipped_weapon = null
		update_equipped_weapon_ui()
		clamp_player_hp_to_current_max()
		update_player_status_ui()

		if selected_inventory_item == item:
			selected_inventory_item = null
			clear_selected_item_info()

		print("장착 중인 아이템이 가방 밖으로 이동되어 장착 해제됨")
# 인벤토리 정리 화면 아이템이 실제로 어느 쪽 목록에 있는지 찾는 함수
func get_real_arrange_item_source(item):
	if item == null:
		return ""

	if arrange_left_inventory.has(item):
		return "left"

	if inventory.has(item):
		return "right"

	return ""
# 인벤토리 초상화 출력 함수
func update_inventory_portrait_ui():
	if inventory_portrait == null:
		return

	var portrait_path = get_character_portrait_path("protagonist", "normal")

	if portrait_path == "":
		inventory_portrait.texture = null
		inventory_portrait.visible = false
		return

	inventory_portrait.texture = load(portrait_path)
	inventory_portrait.visible = true

# ============================================================
# 아이템 함수 모음
# ============================================================

# 아이템 보유 여부 확인 함수
func has_item(item_id):
	if item_id == "":
		return false

	for item in inventory:
		if item == null:
			continue

		if typeof(item) != TYPE_DICTIONARY:
			continue

		if item.get("id", "") == item_id:
			return true

	return false
# item_id 기준으로 스택 가능한 아이템인지 확인하는 함수
func is_item_stackable_by_id(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return false

	return bool(item_data.get("stackable", false))
# 아이템 중복 획득을 막아야 하는지 확인하는 함수
# 현재 규칙: 스택 불가능한 아이템은 중복 획득 불가
func should_block_duplicate_item_gain(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return true

	if is_item_stackable_by_id(item_id):
		return false

	return has_item(item_id)
# 아이템 추가 함수
func add_item(item_id, count = 1, show_full_message = true):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		push_error("아이템 데이터가 없음: " + str(item_id))
		return false

	var is_stackable = item_data.get("stackable", false)
	var max_stack = max(int(item_data.get("max_stack", 1)), 1)
	var remaining = int(count)
	var added_any = false

	if remaining <= 0:
		return false

	# 스택 가능한 아이템은 기존 스택부터 먼저 채움
	if is_stackable:
		for inventory_item in inventory:
			if remaining <= 0:
				break

			if inventory_item.get("id", "") != item_id:
				continue

			var current_count = int(inventory_item.get("count", 1))

			if current_count >= max_stack:
				continue

			var add_count = min(remaining, max_stack - current_count)
			inventory_item["count"] = current_count + add_count
			remaining -= add_count
			added_any = true

	# 남은 수량은 새 슬롯에 배치
	while remaining > 0:
		var empty_slot = find_empty_slot(item_id)

		if empty_slot == -1:
			if show_full_message:
				await show_dialogue("가방에 공간이 없다.")
			return added_any

		var new_item = {
			"id": item_id,
			"slot": empty_slot
		}

		if is_stackable:
			var add_count = min(remaining, max_stack)
			new_item["count"] = add_count
			remaining -= add_count
		else:
			if should_block_duplicate_item_gain(item_id):
				return added_any

			remaining -= 1

		inventory.append(new_item)
		added_any = true

	print("아이템 획득: " + get_item_name(item_id))
	return added_any
# 아이템 추가 시 실제로 넣은 개수 계산 함수
func get_inventory_item_count(item_id):
	var total_count = 0

	for inventory_item in inventory:
		if inventory_item.get("id", "") != item_id:
			continue

		total_count += int(inventory_item.get("count", 1))

	return total_count
# 아이템 id 기준으로 첫 번째 아이템을 찾아 소모하는 함수 (문 열쇠처럼 id만 아는 경우)
func consume_item_by_id(item_id):
	for inventory_item in inventory:
		if inventory_item.get("id", "") == item_id:
			return consume_item_if_needed(inventory_item)

	return false
# 아이템 타입 한글 이름 반환 함수 (성물/주물 타입 반영 필요!)
func get_item_type_text(item_type_or_data):
	var item_type = ""
	var relic_type = ""

	if typeof(item_type_or_data) == TYPE_DICTIONARY:
		item_type = item_type_or_data.get("type", "")
		relic_type = item_type_or_data.get("relic_type", "")
	else:
		item_type = str(item_type_or_data)

	if item_type == "key":
		return "열쇠"
	elif item_type == "weapon":
		return "무기"
	elif item_type == "consumable":
		return "소모품"
	elif item_type == "coin":
		return "주화"
	elif item_type == "relic":
		if relic_type == "holy":
			return "성물"
		elif relic_type == "fetish":
			return "주물"
		else:
			return "유물"
	elif item_type == "holy":
		return "성물"
	elif item_type == "fetish":
		return "주물"
	elif item_type == "":
		return ""
	else:
		return "기타"
# item_id 기준으로 아이템 타입 한글 이름 반환 함수
func get_item_type_text_by_id(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return ""

	return get_item_type_text(item_data)
# inventory_item 기준으로 아이템 타입 한글 이름 반환 함수
func get_item_type_text_from_inventory_item(inventory_item):
	if inventory_item == null:
		return ""

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return ""

	var item_id = inventory_item.get("id", "")

	return get_item_type_text_by_id(item_id)
# 아이템 개수 라벨 생성 함수
func add_item_count_label(icon_node, inventory_item):
	var count = int(inventory_item.get("count", 1))

	if count <= 1:
		return

	var count_label = Label.new()
	var font = load("res://fonts/x12y12pxMaruMinyaHangul.ttf")
	count_label.add_theme_color_override("font_color",Color("#d8d0c8"))
	count_label.add_theme_font_override("font", font)
	count_label.text = str(count)
	count_label.size = Vector2(50, 32)
	count_label.position = Vector2(icon_node.size.x - 58, icon_node.size.y - 38)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.z_index = 50

	# 숫자만 너무 떠 보이면 나중에 LabelSettings로 외곽선 추가 가능
	icon_node.add_child(count_label)
# 아이템 설명 텍스트 생성 함수
func make_item_info_text(inventory_item):
	if inventory_item == null:
		return ""

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return ""

	var item_id = inventory_item.get("id", "")

	if item_id == "":
		return ""

	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return ""

	var item_name = get_item_name(item_id)
	var description = item_data.get("description", "")
	var item_type = item_data.get("type", "")
	var item_type_text = get_item_type_text_from_inventory_item(inventory_item)
	
	var count = int(inventory_item.get("count", 1))

	var text_lines = []

	text_lines.append(escape_rich_text(item_name))
	text_lines.append("")

	if count > 1:
		text_lines.append("보유 수량 : " + str(count))
		text_lines.append("")

	var is_weapon = item_type == "weapon"
	var is_current_equipped_weapon = false
	var effective_stats = {}

	if is_weapon:
		is_current_equipped_weapon = is_selected_item_current_equipped_weapon(item_id)

		var attack_min_base = int(item_data.get("attack_min", item_data.get("attack", 1)))
		var attack_max_base = int(item_data.get("attack_max", item_data.get("attack", attack_min_base)))

		if is_current_equipped_weapon:
			effective_stats = get_player_effective_stats()

			var attack_min = int(effective_stats.get("attack_min", attack_min_base))
			var attack_max = int(effective_stats.get("attack_max", attack_max_base))

			var attack_min_text = make_changed_value_text(
				attack_min_base,
				attack_min,
				"",
				0,
				true
			)

			var attack_max_text = make_changed_value_text(
				attack_max_base,
				attack_max,
				"",
				0,
				true
			)

			text_lines.append("공격력 : " + attack_min_text + " ~ " + attack_max_text)
		else:
			text_lines.append("공격력 : " + str(attack_min_base) + " ~ " + str(attack_max_base))

	if item_type_text != "":
		text_lines.append("종류 : " + escape_rich_text(item_type_text))

	if is_weapon:
		var critical_chance_base = float(item_data.get("critical_chance", 0.01))
		var critical_multiplier_base = float(item_data.get("critical_multiplier", 2.0))
		var parry_window_base = float(item_data.get("parry_window", 0.1))
		var attack_swing_speed_base = float(item_data.get("attack_swing_speed", 3.0))
		var defense_move_speed_base = float(item_data.get("defense_move_speed", 500.0))

		var critical_chance = critical_chance_base
		var critical_multiplier = critical_multiplier_base
		var parry_window = parry_window_base
		var attack_swing_speed = attack_swing_speed_base
		var defense_move_speed = defense_move_speed_base

		if is_current_equipped_weapon:
			critical_chance_base = float(effective_stats.get("critical_chance_base", critical_chance_base))
			critical_multiplier_base = float(effective_stats.get("critical_multiplier_base", critical_multiplier_base))
			parry_window_base = float(effective_stats.get("parry_window_base", parry_window_base))
			attack_swing_speed_base = float(effective_stats.get("attack_swing_speed_base", attack_swing_speed_base))
			defense_move_speed_base = float(effective_stats.get("defense_move_speed_base", defense_move_speed_base))

			critical_chance = float(effective_stats.get("critical_chance", critical_chance_base))
			critical_multiplier = float(effective_stats.get("critical_multiplier", critical_multiplier_base))
			parry_window = float(effective_stats.get("parry_window", parry_window_base))
			attack_swing_speed = float(effective_stats.get("attack_swing_speed", attack_swing_speed_base))
			defense_move_speed = float(effective_stats.get("defense_move_speed", defense_move_speed_base))

		var critical_chance_text = ""

		if is_current_equipped_weapon:
			critical_chance_text = make_changed_value_text(
				critical_chance_base * 100.0,
				critical_chance * 100.0,
				"%",
				0,
				true
			)
		else:
			critical_chance_text = str(int(round(critical_chance * 100.0))) + "%"

		var critical_multiplier_text = ""

		if is_current_equipped_weapon:
			critical_multiplier_text = make_changed_value_text(
				critical_multiplier_base,
				critical_multiplier,
				"x",
				2,
				true
			)
		else:
			critical_multiplier_text = format_stat_float(critical_multiplier, 2) + "x"

		text_lines.append("치명타 확률 : " + critical_chance_text)
		text_lines.append("치명타 배율 : " + critical_multiplier_text)
		text_lines.append("패링 범위 : " + make_parry_window_grade_text(parry_window))
		text_lines.append("스윙 속도 : " + make_attack_swing_speed_grade_text(attack_swing_speed))
		text_lines.append("방어 이동 속도 : " + make_defense_move_speed_grade_text(defense_move_speed))
		
	if is_weapon:
		if should_show_weapon_piercing_effect(
			item_id,
			item_data,
			is_current_equipped_weapon,
			effective_stats
		):
			text_lines.append("관통 효과")

	if description != "":
		text_lines.append("")
		text_lines.append(escape_rich_text(description))

	return "\n".join(text_lines)
# 현재 선택한 아이템이 장착 중인 무기인지 확인하는 함수
func is_selected_item_current_equipped_weapon(item_id):
	if item_id == "":
		return false

	var current_weapon_id = "fist"

	if equipped_weapon != null:
		current_weapon_id = equipped_weapon.get("id", "fist")

	return item_id == current_weapon_id
# 소수 표시 정리 함수
func format_stat_float(value, digit_count = 2):
	var format_text = "%." + str(digit_count) + "f"
	return format_text % float(value)
# 퍼센트 표시 함수
func format_stat_percent(value):
	return format_stat_float(float(value) * 100.0, 1) + "%"
# 기본값과 적용값 비교 텍스트 생성 함수
# higher_is_better가 false면 수치가 낮아지는 쪽을 좋은 변화로 표시
func make_stat_compare_line(label_text, base_value, effective_value, suffix = "", digit_count = 0, higher_is_better = true):
	var base_text = ""
	var effective_text = ""

	if digit_count <= 0:
		base_text = str(int(base_value))
		effective_text = str(int(effective_value))
	else:
		base_text = format_stat_float(base_value, digit_count)
		effective_text = format_stat_float(effective_value, digit_count)

	if suffix != "":
		base_text += suffix
		effective_text += suffix

	if str(base_text) == str(effective_text):
		return label_text + " : " + effective_text

	var is_increased = float(effective_value) > float(base_value)
	var is_good_change = is_increased == higher_is_better
	var color = STAT_GOOD_COLOR

	if not is_good_change:
		color = STAT_BAD_COLOR

	var change_text = ""

	if is_increased:
		change_text = effective_text + " 상승"
	else:
		change_text = effective_text + " 하락"

	return label_text + " : " + base_text + " → " + make_colored_text(change_text, color)
# 현재 장착 무기 기준 적용 능력치 설명 생성 함수
func make_current_weapon_effective_stat_text(item_id, item_data):
	if not is_selected_item_current_equipped_weapon(item_id):
		return []

	var effective_stats = get_player_effective_stats()
	var lines = []

	var attack_min_base = int(effective_stats.get("attack_min_base", item_data.get("attack_min", item_data.get("attack", 1))))
	var attack_max_base = int(effective_stats.get("attack_max_base", item_data.get("attack_max", item_data.get("attack", attack_min_base))))
	var attack_min = int(effective_stats.get("attack_min", attack_min_base))
	var attack_max = int(effective_stats.get("attack_max", attack_max_base))

	lines.append("")
	lines.append(make_colored_text("[현재 적용 능력치]", STAT_INFO_COLOR))
		
	if attack_min_base == attack_min and attack_max_base == attack_max:
		lines.append("공격력 : " + str(attack_min) + " ~ " + str(attack_max))
	else:
		var base_attack_text = str(attack_min_base) + " ~ " + str(attack_max_base)
		var effective_attack_text = str(attack_min) + " ~ " + str(attack_max)

		var attack_is_good = true

		if attack_min < attack_min_base or attack_max < attack_max_base:
			attack_is_good = false

		var attack_color = STAT_GOOD_COLOR

		if not attack_is_good:
			attack_color = STAT_BAD_COLOR

		lines.append("공격력 : " + base_attack_text + " → " + make_colored_text(effective_attack_text, attack_color))

	lines.append(
		make_stat_compare_line(
			"최대 체력",
			int(effective_stats.get("max_hp_base", player_max_hp)),
			int(effective_stats.get("max_hp", player_max_hp))
		)
	)

	var critical_chance_base = float(effective_stats.get("critical_chance_base", item_data.get("critical_chance", 0.01)))
	var critical_chance = float(effective_stats.get("critical_chance", critical_chance_base))

	if critical_chance_base == critical_chance:
		lines.append("치명타 확률 : " + format_stat_percent(critical_chance))
	else:
		var critical_color = STAT_GOOD_COLOR

		if critical_chance < critical_chance_base:
			critical_color = STAT_BAD_COLOR

		var critical_change_text = format_stat_percent(critical_chance)

		if critical_chance > critical_chance_base:
			critical_change_text += " 상승"
		else:
			critical_change_text += " 하락"

		lines.append(
			"치명타 확률 : " + format_stat_percent(critical_chance_base) + " → " + make_colored_text(critical_change_text, critical_color)
		)

	lines.append(
		make_stat_compare_line(
			"치명타 배율",
			float(effective_stats.get("critical_multiplier_base", item_data.get("critical_multiplier", 2.0))),
			float(effective_stats.get("critical_multiplier", item_data.get("critical_multiplier", 2.0))),
			"x",
			2
		)
	)

	lines.append(
		make_stat_compare_line(
			"패링 범위",
			float(effective_stats.get("parry_window_base", item_data.get("parry_window", 0.1))),
			float(effective_stats.get("parry_window", item_data.get("parry_window", 0.1))),
			"",
			3
		)
	)

	lines.append(
		make_stat_compare_line(
			"스윙 속도",
			float(effective_stats.get("attack_swing_speed_base", item_data.get("attack_swing_speed", 3.0))),
			float(effective_stats.get("attack_swing_speed", item_data.get("attack_swing_speed", 3.0))),
			"",
			2
		)
	)

	lines.append(
		make_stat_compare_line(
			"방어 이동 속도",
			float(effective_stats.get("defense_move_speed_base", item_data.get("defense_move_speed", 500.0))),
			float(effective_stats.get("defense_move_speed", item_data.get("defense_move_speed", 500.0))),
			"",
			0
		)
	)

	var base_piercing = bool(item_data.get("piercing", false))
	var effective_piercing = bool(effective_stats.get("piercing", base_piercing))

	if base_piercing == effective_piercing:
		if effective_piercing:
			lines.append("관통 : 있음")
		else:
			lines.append("관통 : 없음")
	else:
		if effective_piercing:
			lines.append("관통 : 없음 → " + make_colored_text("있음 상승", STAT_GOOD_COLOR))
		else:
			lines.append("관통 : 있음 → " + make_colored_text("없음 하락", STAT_BAD_COLOR))

	lines.append(
		make_stat_compare_line(
			"받는 피해 배율",
			1.0,
			float(effective_stats.get("damage_taken_multiplier", 1.0)),
			"x",
			2,
			false
		)
	)

	var turn_damage = int(effective_stats.get("turn_start_player_damage", 0))
	var turn_heal = int(effective_stats.get("turn_start_player_heal", 0))
	var enemy_damage = int(effective_stats.get("turn_start_enemy_damage", 0))

	if turn_damage > 0:
		lines.append("턴 시작 피해 : " + make_colored_text(str(turn_damage), STAT_BAD_COLOR))

	if turn_heal > 0:
		lines.append("턴 시작 회복 : " + make_colored_text(str(turn_heal), STAT_GOOD_COLOR))

	if enemy_damage > 0:
		lines.append("턴 시작 적 피해 : " + make_colored_text(str(enemy_damage), STAT_GOOD_COLOR))

	if bool(effective_stats.get("cannot_die", false)):
		lines.append("죽음 방지 : " + make_colored_text("활성화", STAT_GOOD_COLOR))

	return lines
# 아이템 정보 UI 표시 공통 함수
func show_item_info_ui(inventory_item, image_node, text_node):
	if inventory_item == null:
		clear_item_info_ui(image_node, text_node)
		return

	var info_text = make_item_info_text(inventory_item)
	var image_path = get_item_image_path_from_inventory_item(inventory_item)

	if info_text == "":
		clear_item_info_ui(image_node, text_node)
		return

	if image_node != null:
		if image_path != "":
			image_node.texture = load(image_path)
			image_node.visible = true
		else:
			image_node.texture = null
			image_node.visible = false

	if text_node != null:
		if text_node is RichTextLabel:
			text_node.clear()
			text_node.append_text(info_text)
		else:
			text_node.text = info_text

		text_node.visible = true

		if text_node == selected_item_description and selected_item_description_scroll != null:
			selected_item_description_scroll.scroll_vertical = 0

		if text_node == arrange_selected_item_text and arrange_selected_item_text_scroll != null:
			arrange_selected_item_text_scroll.scroll_vertical = 0
# 아이템 정보 UI 초기화 공통 함수
func clear_item_info_ui(image_node, text_node):
	if image_node != null:
		image_node.texture = null
		image_node.visible = false

	if text_node != null:
		if text_node is RichTextLabel:
			text_node.clear()
		else:
			text_node.text = ""

		text_node.visible = false

		if text_node == selected_item_description and selected_item_description_scroll != null:
			selected_item_description_scroll.scroll_vertical = 0

		if text_node == arrange_selected_item_text and arrange_selected_item_text_scroll != null:
			arrange_selected_item_text_scroll.scroll_vertical = 0
# 아이템을 가방에 넣고, 못 넣은 수량은 pending_loot에 저장하는 함수
func give_item_with_pending_loot(item_id, count = 1):
	var result = {
		"item": item_id,
		"requested": int(count),
		"added": 0,
		"remaining": 0
	}

	if item_id == "":
		return result

	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		push_error("아이템 데이터가 없음: " + str(item_id))
		return result

	var is_stackable = item_data.get("stackable", false)
	var requested_count = int(count)

	if requested_count <= 0:
		return result

	var before_count = get_inventory_item_count(item_id)

	await add_item(item_id, requested_count, false)

	var after_count = get_inventory_item_count(item_id)
	var added_count = max(after_count - before_count, 0)
	var remaining_count = requested_count - added_count

	# 비중첩 아이템은 현재 구조상 중복 소지 불가.
	# 이미 가지고 있는 아이템 때문에 못 들어간 경우는 pending_loot로 보내지 않음.
	if not is_stackable and after_count > 0:
		remaining_count = 0

	if remaining_count > 0:
		add_pending_loot(item_id, remaining_count)

	result["added"] = added_count
	result["remaining"] = remaining_count

	return result
# 여러 보상 아이템을 가방에 넣고, 못 넣은 수량은 pending_loot에 저장하는 함수
func give_items_with_pending_loot(rewards):
	var results = []

	for reward in rewards:
		var item_id = reward.get("item", "")
		var count = int(reward.get("count", 1))

		if item_id == "":
			continue

		var result = await give_item_with_pending_loot(item_id, count)
		results.append(result)

	return results
# pending_loot가 있으면 인벤토리 정리 화면을 여는 함수
func open_inventory_arrange_if_pending_loot(mode = "loot"):
	if pending_loot.size() <= 0:
		return

	var loot_to_arrange = pending_loot.duplicate(true)
	pending_loot.clear()

	await open_inventory_arrange(mode, loot_to_arrange)
# 아이템 이름 가져오기 함수
func get_item_name(item_id):
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return str(item_id)

	return item_data.get("name", str(item_id))
# 선택 아이템 정보 제거 함수
func clear_selected_item_info():
	show_equipped_weapon_info()
# 선택 아이템 정보 표시 함수
func show_selected_item_info(inventory_item):
	show_item_info_ui(
		inventory_item,
		selected_item_image,
		selected_item_description
	)
# 아이템이 들어갈 수 있는 빈 슬롯 찾기 함수
func find_empty_slot(item_id):
	var item_size = get_item_grid_size_by_id(item_id)

	if item_size.x <= 0 or item_size.y <= 0:
		return -1

	var item_width = item_size.x
	var item_height = item_size.y
	var total_slots = inventory_cols * inventory_rows

	for slot in range(total_slots):
		if can_place_item_at(slot, item_width, item_height):
			return slot

	return -1
# 선택 아이템 특정 슬롯에 아이템을 놓을 수 있는지 확인하는 함수
func can_place_item_at(start_slot, item_width, item_height):
	return can_place_item_at_except(
		start_slot,
		item_width,
		item_height,
		null
	)
# 마우스 위치 기준 슬롯 번호 계산 함수
func get_slot_from_mouse_position():
	
	var local_mouse = inventory_slots.get_local_mouse_position()

	var slot_x = int(local_mouse.x / (inventory_slot_size + inventory_slot_gap))
	var slot_y = int(local_mouse.y / (inventory_slot_size + inventory_slot_gap))

	# 가방 범위 밖이면 실패
	if slot_x < 0 or slot_x >= inventory_cols:
		return -1

	if slot_y < 0 or slot_y >= inventory_rows:
		return -1

	return slot_y * inventory_cols + slot_x	
# 특정 아이템을 제외하고 슬롯 배치 가능 여부 확인
# ignored_item이 null이면 모든 기존 아이템을 검사함
func can_place_item_at_except(start_slot, item_width, item_height, ignored_item = null):
	if start_slot < 0:
		return false

	var start_col = int(start_slot) % inventory_cols
	var start_row = floori(int(start_slot) / float(inventory_cols))

	# 오른쪽/아래로 가방 범위를 넘으면 배치 불가
	if start_col + int(item_width) > inventory_cols:
		return false

	if start_row + int(item_height) > inventory_rows:
		return false

	var target_slots = get_grid_slots_from_size(
		start_slot,
		item_width,
		item_height,
		inventory_cols
	)

	# 기존 아이템들과 겹치는지 확인
	for item in inventory:
		if item == ignored_item:
			continue

		var occupied_slots = get_inventory_item_occupied_slots(item)

		for slot in target_slots:
			if occupied_slots.has(slot):
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

	var item_size = get_inventory_item_grid_size(dragged_item)

	if item_size.x <= 0 or item_size.y <= 0:
		slot_highlight.visible = false
		return

	var item_width = item_size.x
	var item_height = item_size.y

	var can_merge = can_merge_inventory_stack_item(
		dragged_item,
		target_slot
	)

	var can_swap = can_swap_inventory_1x1_items(
		dragged_item,
		target_slot
	)

	var can_place = can_merge or can_swap or can_place_item_at_except(
		target_slot,
		item_width,
		item_height,
		dragged_item
	)

	var col = target_slot % inventory_cols
	var row = floori(target_slot / float(inventory_cols))

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

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return

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
	inventory_context_menu.z_index = 100
	inventory_context_menu.move_to_front()
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
		update_equipped_weapon_ui()
		update_player_status_ui()
		return true

	return false
# 아이템 사용 시 소모 처리 함수
func consume_item_if_needed(inventory_item):
	if inventory_item == null:
		return false

	if not inventory.has(inventory_item):
		return false

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return false

	# consumed_on_use가 없거나 false면 소모 안 함
	if not item_data.get("consumed_on_use", false):
		return false

	# stackable 아이템이면 선택한 스택의 count만 1 감소
	if inventory_item.has("count"):
		inventory_item["count"] = int(inventory_item["count"]) - 1

		print("아이템 개수 감소: " + item_id + " x" + str(inventory_item["count"]))

		if int(inventory_item["count"]) <= 0:
			remove_item(inventory_item)

		return true

	# stackable이 아닌 아이템은 선택한 아이템 제거
	remove_item(inventory_item)
	print("아이템 소모: " + item_id)
	return true
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

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return

	if item_data.get("type", "") != "weapon":
		return

	if equipped_weapon == inventory_item:
		equipped_weapon = null
		print(get_item_name(item_id) + " 해제")
	else:
		equipped_weapon = inventory_item
		print(get_item_name(item_id) + " 장착")

	update_equipped_weapon_ui()
	clamp_player_hp_to_current_max()
	update_player_status_ui()
	close_context_menu()
# 아이템 장착 버튼 함수
func _on_equip_button_pressed():
	if context_menu_item == null:
		return

	equip_sound.play()
	equip_item(context_menu_item)
# 장착 무기 UI 갱신 함수
func update_equipped_weapon_ui():
	show_equipped_weapon_info()
# 현재 장착 무기 정보 표시 함수
func show_equipped_weapon_info():
	var item_id = "fist"

	if equipped_weapon != null:
		item_id = equipped_weapon.get("id", "fist")

	if get_item_data_by_id(item_id).is_empty():
		selected_item_image.texture = null
		selected_item_image.visible = false

		if selected_item_description is RichTextLabel:
			selected_item_description.clear()
		else:
			selected_item_description.text = ""

		selected_item_description.visible = false
		equipped_weapon_text.text = "무기 없음"
		return

	var fake_inventory_item = {
		"id": item_id,
		"count": 1
	}

	var effective_stats = get_player_effective_stats()
	var applied_relic_names = effective_stats.get("applied_relic_names", [])

	if item_id == "fist":
		equipped_weapon_text.text = get_item_name(item_id)
	else:
		equipped_weapon_text.text = get_item_name(item_id)

	if applied_relic_names.size() > 0:
		equipped_weapon_text.text += "\n\n적용 효과:"

		for relic_name in applied_relic_names:
			equipped_weapon_text.text += "\n- " + str(relic_name)
	else:
		equipped_weapon_text.text += "\n\n적용 효과 없음"

	show_item_info_ui(
		fake_inventory_item,
		selected_item_image,
		selected_item_description
	)
	
	if equipped_weapon_text_scroll != null:
		equipped_weapon_text_scroll.scroll_vertical = 0
# 아이템 사용 함수
func use_item(inventory_item):
	if inventory_item == null:
		return

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return

	var item_type = item_data.get("type", "")

	if item_type != "consumable":
		return
		
	# 이렇게 해야 최대 체력이 100 이상 올라갔을 때도 소모품 회복이 제대로 적용
	if item_data.has("heal"):
		var current_max_hp = get_current_player_max_hp()

		player_hp += int(item_data["heal"])

		if player_hp > current_max_hp:
			player_hp = current_max_hp

		print("현재 체력: " + str(int(player_hp)))

	consume_item_if_needed(inventory_item)
	clamp_player_hp_to_current_max()
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

# ============================================================
# 저장 함수 모음
# ============================================================

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

# ============================================================
# 랜덤 인카운터 함수 모음
# ============================================================

# 방 데이터에서 random_encounter 데이터 가져오기 함수
func get_random_encounter_data_from_room(room, show_error = false):
	if room.is_empty():
		return {}

	if not room.has("random_encounter"):
		return {}

	var random_encounter_data = room["random_encounter"]

	if typeof(random_encounter_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("random_encounter 데이터가 Dictionary가 아님: " + str(current_room))
		return {}

	return random_encounter_data
# 랜덤 인카운터 발생 확률 가져오기 함수
func get_random_encounter_chance(encounter_data):
	if encounter_data.is_empty():
		return 0.0

	return float(encounter_data.get("chance", 0.0))
# 랜덤 인카운터 적 테이블 ID 가져오기 함수
func get_random_encounter_enemy_table_id(encounter_data):
	if encounter_data.is_empty():
		return ""

	return str(encounter_data.get("enemy_table", encounter_data.get("table", "")))
# 랜덤 인카운터 이벤트 테이블 ID 가져오기 함수
func get_random_encounter_event_table_id(encounter_data, enemy_table_id):
	if encounter_data.is_empty():
		return ""

	return str(encounter_data.get("event_table", enemy_table_id))
# 현재 방 랜덤 인카운터 확인 함수
func check_random_encounter():
	var room = get_current_room_data(false)

	if room.is_empty():
		return false

	var encounter_data = get_random_encounter_data_from_room(room)

	if encounter_data.is_empty():
		return false

	var chance = get_random_encounter_chance(encounter_data)

	if chance <= 0.0:
		return false

	if randf() * 100.0 > chance:
		return false

	var enemy_table_id = get_random_encounter_enemy_table_id(encounter_data)

	if enemy_table_id == "":
		return false

	var event_table_id = get_random_encounter_event_table_id(
		encounter_data,
		enemy_table_id
	)

	var enemy_id = pick_random_encounter_enemy(enemy_table_id)

	if enemy_id == "":
		return false

	start_random_encounter_effect()

	var start_text = get_random_encounter_start_text(event_table_id)

	if start_text != "":
		await show_dialogue(start_text)

	var choices = make_random_encounter_choices(event_table_id)

	if choices.size() == 0:
		await stop_random_encounter_effect()
		start_battle(enemy_id)
		return true

	var selected_index = await show_choices(choices)

	if selected_index < 0 or selected_index >= choices.size():
		await stop_random_encounter_effect()
		start_battle(enemy_id)
		return true

	var selected_choice = choices[selected_index]

	var encounter_result = await run_random_encounter_choice(selected_choice, enemy_id)

	await stop_random_encounter_effect()

	if encounter_result.get("result", "battle") == "escape":
		# 도주 후 여유 시간 부여
		random_encounter_cooldown_steps = 2
		return false

	start_battle(
		encounter_result.get("enemy_id", enemy_id),
		encounter_result.get("first_turn", "")
	)

	return true
# 인카운터 데이터가 기본적으로 유효한지 확인하는 함수
func is_valid_encounter_data(encounter):
	if encounter == null:
		return false

	if typeof(encounter) != TYPE_DICTIONARY:
		return false

	var enemy_id = encounter.get("enemy", "")

	if enemy_id == "":
		return false

	var enemy_data = get_enemy_data_by_id(enemy_id, false)

	if enemy_data.is_empty():
		return false

	return true
# 인카운터 후보가 현재 플래그 조건에 맞는지 확인하는 함수
func can_use_encounter_candidate(encounter):
	if not is_valid_encounter_data(encounter):
		return false

	var enemy_id = encounter.get("enemy", "")
	var enemy_data = get_enemy_data_by_id(enemy_id, false)

	if enemy_data.is_empty():
		return false

	var required_flag = str(encounter.get("required_flag", ""))

	if required_flag != "" and not has_flag(required_flag):
		return false

	var missing_flag = str(encounter.get("missing_flag", ""))

	if missing_flag != "" and has_flag(missing_flag):
		return false

	var skip_flag = str(enemy_data.get("skip_if_flag", ""))

	if skip_flag != "" and has_flag(skip_flag):
		return false

	return true
# 인카운터 테이블에서 현재 사용 가능한 후보 목록 생성 함수
func get_available_encounter_candidates(encounter_table):
	var candidates = []

	if typeof(encounter_table) != TYPE_ARRAY:
		return candidates

	for encounter in encounter_table:
		if can_use_encounter_candidate(encounter):
			candidates.append(encounter)

	return candidates
# 인카운터 후보의 가중치 가져오기 함수
func get_encounter_weight(encounter):
	if encounter == null:
		return 0

	if typeof(encounter) != TYPE_DICTIONARY:
		return 0

	var weight = int(encounter.get("weight", 1))

	if weight < 0:
		weight = 0

	return weight
# 후보 목록에서 weight 기준으로 인카운터 하나 선택하는 함수
func pick_weighted_encounter(candidates):
	if typeof(candidates) != TYPE_ARRAY:
		return {}

	if candidates.size() == 0:
		return {}

	var total_weight = 0

	for encounter in candidates:
		total_weight += get_encounter_weight(encounter)

	if total_weight <= 0:
		return {}

	var roll = randi_range(1, total_weight)
	var current_weight = 0

	for encounter in candidates:
		current_weight += get_encounter_weight(encounter)

		if roll <= current_weight:
			return encounter

	return {}
# 랜덤 인카운터 테이블에서 적 하나 선택하는 함수
func pick_random_encounter_enemy(table_id):
	var encounter_table = get_encounter_table_by_id(table_id)

	if encounter_table.is_empty():
		return ""

	var candidates = get_available_encounter_candidates(encounter_table)

	if candidates.size() == 0:
		return ""

	var selected_encounter = pick_weighted_encounter(candidates)

	if selected_encounter.is_empty():
		return ""

	return str(selected_encounter.get("enemy", ""))
# encounter event_table_id 기준으로 인카운터 이벤트 데이터 가져오기 함수
func get_encounter_event_data_by_id(event_table_id, show_error = true):
	if event_table_id == "":
		if show_error:
			push_error("인카운터 이벤트 테이블 ID가 비어있음")
		return {}

	if not encounter_events.has(event_table_id):
		if show_error:
			push_error("존재하지 않는 인카운터 이벤트 테이블: " + str(event_table_id))
		return {}

	var event_data = encounter_events[event_table_id]

	if typeof(event_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("인카운터 이벤트 데이터가 Dictionary가 아님: " + str(event_table_id))
		return {}

	return event_data
# 인카운터 발생 텍스트 가져오기 함수
func get_random_encounter_start_text(event_table_id):
	var event_data = get_encounter_event_data_by_id(event_table_id)

	if event_data.is_empty():
		return ""

	var start_texts = event_data.get("start_texts", [])

	if typeof(start_texts) != TYPE_ARRAY:
		return ""

	if start_texts.size() == 0:
		return ""

	return str(start_texts.pick_random())
# 인카운터 선택지 생성 함수
func make_random_encounter_choices(event_table_id):
	var result_choices = []
	var event_data = get_encounter_event_data_by_id(event_table_id)

	if event_data.is_empty():
		return result_choices

	var choice_pools = event_data.get("choice_pools", {})

	if typeof(choice_pools) != TYPE_DICTIONARY:
		return result_choices

	var pool_order = ["escape", "player_first", "enemy_first"]

	for pool_id in pool_order:
		var pool = choice_pools.get(pool_id, [])

		if typeof(pool) != TYPE_ARRAY:
			continue

		if pool.size() == 0:
			continue

		var picked_choice = pool.pick_random()

		if picked_choice == null:
			continue

		if typeof(picked_choice) != TYPE_DICTIONARY:
			continue

		var choice = picked_choice.duplicate(true)
		result_choices.append(choice)

	result_choices.shuffle()
	return result_choices
# 랜덤 인카운터 선택지 결과 텍스트 가져오기 함수
func get_random_encounter_choice_result_text(choice):
	if choice == null:
		return ""

	if typeof(choice) != TYPE_DICTIONARY:
		return ""

	return str(choice.get("result_text", ""))
# 랜덤 인카운터 선택지 결과 타입 가져오기 함수
func get_random_encounter_choice_result(choice):
	if choice == null:
		return "battle"

	if typeof(choice) != TYPE_DICTIONARY:
		return "battle"

	var result = str(choice.get("result", "battle"))

	if result == "":
		return "battle"

	return result
# 랜덤 인카운터 선택지 선공 정보 가져오기 함수
func get_random_encounter_choice_first_turn(choice):
	if choice == null:
		return ""

	if typeof(choice) != TYPE_DICTIONARY:
		return ""

	var first_turn = str(choice.get("first_turn", ""))

	if first_turn != "player" and first_turn != "enemy":
		return ""

	return first_turn
# 랜덤 인카운터 선택지 결과 Dictionary 생성 함수
func make_random_encounter_choice_result(choice, enemy_id):
	return {
		"result": get_random_encounter_choice_result(choice),
		"enemy_id": enemy_id,
		"first_turn": get_random_encounter_choice_first_turn(choice)
	}
# 인카운터 선택 결과 실행 함수
func run_random_encounter_choice(choice, enemy_id):
	var result_text = get_random_encounter_choice_result_text(choice)

	if result_text != "":
		await show_dialogue(result_text)

	return make_random_encounter_choice_result(choice, enemy_id)
# 랜덤 인카운터 오버레이 트윈 정리 함수
func kill_random_encounter_overlay_tween():
	if encounter_overlay_tween != null and encounter_overlay_tween.is_valid():
		encounter_overlay_tween.kill()

	encounter_overlay_tween = null


# 랜덤 인카운터 오버레이 초기화 함수
func reset_random_encounter_overlay():
	if encounter_danger_overlay == null:
		return

	encounter_danger_overlay.color = Color(1, 0, 0, 0)
	encounter_danger_overlay.visible = false


# 랜덤 인카운터 심장박동 사운드 시작 함수
func play_random_encounter_heartbeat():
	if encounter_heartbeat_sound == null:
		return

	encounter_heartbeat_sound.stop()
	encounter_heartbeat_sound.play()


# 랜덤 인카운터 심장박동 사운드 종료 함수
func stop_random_encounter_heartbeat():
	if encounter_heartbeat_sound == null:
		return

	encounter_heartbeat_sound.stop()
# 랜덤 인카운터 공통 연출 시작 함수
func start_random_encounter_effect():
	kill_random_encounter_overlay_tween()

	if encounter_danger_overlay != null:
		encounter_danger_overlay.visible = true
		encounter_danger_overlay.color = Color(1, 0, 0, 0)

		encounter_overlay_tween = create_tween()
		encounter_overlay_tween.tween_property(
			encounter_danger_overlay,
			"color:a",
			0.35,
			3.0
		)

	play_random_encounter_heartbeat()
# 랜덤 인카운터 공통 연출 종료 함수
func stop_random_encounter_effect():
	kill_random_encounter_overlay_tween()

	if encounter_danger_overlay != null:
		encounter_overlay_tween = create_tween()
		encounter_overlay_tween.tween_property(
			encounter_danger_overlay,
			"color:a",
			0.0,
			0.4
		)

		await encounter_overlay_tween.finished

		encounter_danger_overlay.color = Color(1, 0, 0, 0)
		encounter_danger_overlay.visible = false

	encounter_overlay_tween = null
	stop_random_encounter_heartbeat()
# 랜덤 인카운터 encounter table_id 기준으로 인카운터 테이블 가져오기 함수
func get_encounter_table_by_id(table_id, show_error = true):
	if table_id == "":
		if show_error:
			push_error("인카운터 테이블 ID가 비어있음")
		return []

	if not encounters.has(table_id):
		if show_error:
			push_error("존재하지 않는 인카운터 테이블: " + str(table_id))
		return []

	var encounter_table = encounters[table_id]

	if typeof(encounter_table) != TYPE_ARRAY:
		if show_error:
			push_error("인카운터 테이블 데이터가 Array가 아님: " + str(table_id))
		return []

	return encounter_table
