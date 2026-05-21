extends Control

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

# 일반 변수 모음
var player_hp = 0
var player_max_hp = 0
var enemy_id = ""
var enemy_data = {}

# 상수 변수 모음

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
	player_hp = data.get("player_hp", 100)
	player_max_hp = data.get("player_max_hp", 100)

	update_player_hp_ui()

	if enemy_data.has("image"):
		enemy_sprite.texture = load(enemy_data["image"])

	battle_text.text = enemy_data.get("name", "무언가") + "가 나타났다..."

# 플레이어 현재 체력 갱신 함수
func update_player_hp_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
	
func _on_attack_button_pressed():
	battle_text.text = "공격하기를 선택했다."

func _on_observe_button_pressed():
	battle_text.text = "관찰하기를 선택했다."

func _on_item_button_pressed():
	battle_text.text = "아이템을 선택했다."

func _on_end_turn_button_pressed():
	battle_text.text = "턴을 종료했다."

func _on_run_button_pressed():
	battle_text.text = "도망가기를 선택했다."
