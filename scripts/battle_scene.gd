extends Control

# 시그널 모음
signal battle_finished(result_data)

# onready 변수 모음
@onready var enemy_sprite = $EnemySprite
@onready var weapon_sprite = $WeaponSprite
@onready var battle_text = $CenterPanel/BattleText
@onready var player_hp_text = $LeftPanel/PlayerHpText
@onready var attack_button = $RightPanel/AttackButton
@onready var observe_button = $RightPanel/ObserveButton
@onready var item_button = $RightPanel/ItemButton
@onready var end_turn_button = $RightPanel/EndTurnButton
@onready var run_button = $RightPanel/RunButton
@onready var player_portrait = $LeftPanel/PlayerPortrait
@onready var enemy_hp_text = $EnemyHpText

# 일반 변수 모음
var player_hp = 0
var player_max_hp = 0
var enemy_id = ""
var enemy_data = {}
var is_player_turn = true
var battle_ended = false
var enemy_hp = 0
var enemy_max_hp = 0
var items = {}
var equipped_weapon = null
var is_observing = false
var inventory = []
var is_item_selecting = false
var battle_consumables = []
var item_index = 0
var waiting_enemy_attack = false
var current_enemy_pattern = {}

# 상수 변수 모음

# 프레임 마다 실행 함수
func _process(delta):
	
	if is_observing:
		if Input.is_action_just_pressed("ui_accept"):
			is_observing = false
			start_enemy_turn()			
	
	if is_item_selecting:
		if Input.is_action_just_pressed("ui_down"):
			item_index += 1
			if item_index >= battle_consumables.size():
				item_index = 0
			update_battle_item_list()

		if Input.is_action_just_pressed("ui_up"):
			item_index -= 1
			if item_index < 0:
				item_index = battle_consumables.size() - 1
			update_battle_item_list()

		if Input.is_action_just_pressed("ui_accept"):
			use_selected_battle_item()

		if Input.is_action_just_pressed("esc"):
			is_item_selecting = false
			battle_text.text = "행동을 선택하세요."
			set_action_buttons_disabled(false)

		return
	
	if waiting_enemy_attack:
		if Input.is_action_just_pressed("ui_accept"):
			waiting_enemy_attack = false
			await execute_enemy_attack()

		return
# 처음에 한번 실행 함수
func _ready():
	attack_button.focus_mode = Control.FOCUS_NONE
	observe_button.focus_mode = Control.FOCUS_NONE
	item_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.focus_mode = Control.FOCUS_NONE
	run_button.focus_mode = Control.FOCUS_NONE
	
	attack_button.pressed.connect(_on_attack_button_pressed)
	observe_button.pressed.connect(_on_observe_button_pressed)
	item_button.pressed.connect(_on_item_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
# 전투 화면 설정 함수
func setup_battle(data):
	enemy_id = data.get("enemy_id", "")
	enemy_data = data.get("enemy_data", {})
	enemy_max_hp = enemy_data.get("max_hp", 10)
	enemy_hp = enemy_max_hp
	player_hp = data.get("player_hp", 100)
	player_max_hp = data.get("player_max_hp", 100)
	items = data.get("items", {})
	equipped_weapon = data.get("equipped_weapon", null)
	inventory = data.get("inventory", [])

	update_player_hp_ui()
	update_enemy_hp_ui()

	if enemy_data.has("image"):
		enemy_sprite.texture = load(enemy_data["image"])
		
	if data.has("player_portrait"):
		player_portrait.texture = load(data["player_portrait"])

	battle_text.text = enemy_data.get("name", "무언가") + "가 나타났다..."
	
	await get_tree().create_timer(1.0).timeout
	start_player_turn()
# 플레이어 현재 체력 갱신 함수
func update_player_hp_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
# 공격 버튼 클릭 함수
func _on_attack_button_pressed():
	if not is_player_turn:
		return

	set_action_buttons_disabled(true)

	var damage = get_player_attack_damage()
	enemy_hp -= damage
	
	# 적 HP 감소 후
	update_enemy_hp_ui()

	if enemy_hp < 0:
		enemy_hp = 0

	battle_text.text = enemy_data.get("name", "적") + "에게 " + str(int(damage)) + " 의 피해를 주었다."

	await get_tree().create_timer(1.0).timeout

	if enemy_hp <= 0:
		await win_battle()
		return

	start_enemy_turn()
# 관찰 버튼 클릭 함수
func _on_observe_button_pressed():
	if not is_player_turn:
		return

	set_action_buttons_disabled(true)
	is_observing = true

	var observe_text = enemy_data.get(
		"observe_text",
		"특별한 점은 보이지 않는다."
	)

	var weakness_text = enemy_data.get(
		"weakness_text",
		""
	)

	var hp_text = "\n남은 체력 : " + str(int(enemy_hp)) + "/" + str(int(enemy_max_hp))

	battle_text.text = (
		observe_text
		+ "\n"
		+ weakness_text
		+ hp_text
		+ "\n\n[Space] 관찰을 끝낸다."
	)
# 아이템 버튼 클릭 함수
func _on_item_button_pressed():
	if not is_player_turn:
		return

	open_battle_item_list()
# 턴종료 버튼 클릭 함수
func _on_end_turn_button_pressed():
	if not is_player_turn:
		return

	battle_text.text = "턴을 종료했다."

	set_action_buttons_disabled(true)

	await get_tree().create_timer(0.7).timeout

	start_enemy_turn()
# 도망 버튼 클릭 함수
func _on_run_button_pressed():
	if not is_player_turn:
		return

	set_action_buttons_disabled(true)

	if enemy_data.get("can_escape", true):
		battle_text.text = "도망쳤다."

		await get_tree().create_timer(1.0).timeout

		emit_signal("battle_finished", {
			"result": "escaped",
			"player_hp": player_hp,
			"inventory": inventory
		})
	else:
		battle_text.text = "도망칠 수 없다..."

		await get_tree().create_timer(1.0).timeout

		start_enemy_turn()
# 플레이어 턴 시작 함수
func start_player_turn():
	print("start_player_turn")
	is_player_turn = true

	battle_text.text = "당신의 턴."

	set_action_buttons_disabled(false)
# 적 턴 시작 함수
func start_enemy_turn():
	is_player_turn = false

	set_action_buttons_disabled(true)

	current_enemy_pattern = choose_enemy_pattern()

	waiting_enemy_attack = true

	var warning_text = current_enemy_pattern.get(
		"warning_text",
		enemy_data.get("name", "적") + "이(가) 공격하려고 한다..."
	)

	battle_text.text = warning_text + "\n\n[Space]"
# 버튼 활성/비활성 함수
func set_action_buttons_disabled(disabled):
	attack_button.disabled = disabled
	observe_button.disabled = disabled
	item_button.disabled = disabled
	end_turn_button.disabled = disabled
	run_button.disabled = disabled
# 승리 함수 추가
func win_battle():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = enemy_data.get("name", "적") + "을 쓰러뜨렸다."

	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 1.0)

	await tween.finished

	battle_text.text = "전투에서 승리했다."
	enemy_hp_text.visible = false
	
	await get_tree().create_timer(1.0).timeout

	emit_signal("battle_finished", {
		"result": "win",
		"enemy_id": enemy_id,
		"player_hp": player_hp,
		"inventory": inventory
	})
# 대미지 계산 함수 추가
func get_player_attack_damage():
	var weapon_id = "fist"

	if equipped_weapon != null:
		weapon_id = equipped_weapon["id"]

	if not items.has(weapon_id):
		return 1

	var weapon_data = items[weapon_id]

	return weapon_data.get("attack", 1)
# UI 갱신 함수 추가
func update_enemy_hp_ui():
	enemy_hp_text.text = str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))
# 게임 오버 함수
func game_over():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = "YOU DIED"

	await get_tree().create_timer(2.0).timeout
# 아이템 목록 열기 함수
func open_battle_item_list():
	battle_consumables.clear()
	item_index = 0

	for inventory_item in inventory:
		var item_id = inventory_item["id"]

		if not items.has(item_id):
			continue

		var item_data = items[item_id]

		if item_data.get("type", "") == "consumable":
			battle_consumables.append(inventory_item)

	if battle_consumables.size() == 0:
		set_action_buttons_disabled(true)
		battle_text.text = "사용할 수 있는 아이템이 없다."

		await get_tree().create_timer(1.0).timeout

		set_action_buttons_disabled(false)
		battle_text.text = "행동을 선택하세요."
		return

	set_action_buttons_disabled(true)
	is_item_selecting = true
	update_battle_item_list()
# 아이템 목록 표시 함수
func update_battle_item_list():
	var text = "사용할 아이템을 선택하세요.\n\n"

	for i in battle_consumables.size():
		var inventory_item = battle_consumables[i]
		var item_id = inventory_item["id"]
		var item_name = items[item_id].get("name", item_id)
		var count_text = ""

		if inventory_item.has("count"):
			count_text = " x" + str(int(inventory_item["count"]))

		if i == item_index:
			text += "▶ " + item_name + count_text + "\n"
		else:
			text += "  " + item_name + count_text + "\n"

	text += "\n[Space] 사용 / [ESC] 취소"
	battle_text.text = text
# 아이템 사용 함수
func use_selected_battle_item():
	if battle_consumables.size() == 0:
		return

	var inventory_item = battle_consumables[item_index]
	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]

	if item_data.has("heal"):
		player_hp += item_data["heal"]

		if player_hp > player_max_hp:
			player_hp = player_max_hp

	update_player_hp_ui()

	if inventory_item.has("count"):
		inventory_item["count"] -= 1

		if inventory_item["count"] <= 0:
			inventory.erase(inventory_item)
	else:
		inventory.erase(inventory_item)

	is_item_selecting = false

	battle_text.text = items[item_id].get("name", item_id) + " 을 사용했다."

	await get_tree().create_timer(1.0).timeout

	start_enemy_turn()
# 실제 공격 함수
func execute_enemy_attack():
	var damage = current_enemy_pattern.get("damage", 1)

	player_hp -= damage

	if player_hp < 0:
		player_hp = 0

	update_player_hp_ui()

	battle_text.text = str(int(damage)) + " 의 피해를 입었다."

	if player_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		await game_over()
		return

	await get_tree().create_timer(1.0).timeout

	start_player_turn()
# 패턴 선택 함수
func choose_enemy_pattern():
	var patterns = enemy_data.get("patterns", [])

	if patterns.size() == 0:
		return {}

	return patterns.pick_random()
