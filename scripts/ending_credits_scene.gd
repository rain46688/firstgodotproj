extends Control


# ============================================================
# 엔딩 크레딧 기본 설정
# ============================================================

const MAIN_MENU_SCENE_PATH = "res://scenes/main_menu_scene.tscn"

# 크레딧이 위로 올라가는 속도
const CREDITS_SCROLL_SPEED = 45.0

# 크레딧 화면 진입 후 스크롤 시작까지의 대기 시간
const CREDITS_START_DELAY = 1.0

# 결과 화면이 나온 직후 실수로 입력되는 것을 막기 위한 시간
const RESULT_INPUT_DELAY = 0.5

# 크레딧 BGM의 기본 볼륨
const CREDIT_BGM_BASE_VOLUME_DB = -5.0


# ============================================================
# 노드 참조
# ============================================================

@onready var credits_text = $CreditsText

@onready var result_center = $ResultCenter
@onready var play_time_label = $ResultCenter/ResultVBox/PlayTimeLabel
@onready var total_defeated_label = $ResultCenter/ResultVBox/TotalDefeatedLabel
@onready var enemy_grid = $ResultCenter/ResultVBox/EnemyGrid
@onready var continue_label = $ResultCenter/ResultVBox/ContinueLabel

@onready var credit_bgm = $CreditBGM


# ============================================================
# 상태 변수
# ============================================================

var credits_running = false
var result_screen_visible = false
var can_return_to_title = false
var is_returning_to_title = false


# ============================================================
# 크레딧 내용
# ============================================================

const CREDITS_TEXT = """
[center]

[font_size=48]CREDITS[/font_size]


[font_size=30]Game Creator[/font_size]

CMS


[font_size=30]GAME ENGINE[/font_size]

Godot Engine


[font_size=30]Tools[/font_size]

ChatGPT
VScode
Paint3d
Pixabay
Picpick

[font_size=30]SPECIAL THANKS[/font_size]

Mandoo


[font_size=32]Thank you for playing.[/font_size]


[/center]
"""


# ============================================================
# 시작
# ============================================================

func _ready():
	# 혹시 이전 씬에서 Pause 상태가 남아있을 경우를 대비한다.
	get_tree().paused = false

	# 크레딧 씬이 처음 표시되는 순간 글자가 잠깐 보이지 않도록
	# 위치 계산이 끝날 때까지 숨겨둔다.
	credits_text.visible = false
	result_center.visible = false

	setup_credits()
	setup_result_screen()
	setup_credit_bgm()

	# RichTextLabel의 실제 콘텐츠 높이가 계산될 시간을 준다.
	# CreditsText는 숨겨져 있으므로 이 프레임 동안 화면에 보이지 않는다.
	await get_tree().process_frame

	# 크레딧을 화면 아래쪽에서 시작시킨다.
	credits_text.position.y = get_viewport_rect().size.y + 80.0

	# 처음에는 잠시 검은 화면만 보여준다.
	await get_tree().create_timer(
		CREDITS_START_DELAY
	).timeout

	# 모든 준비가 끝난 뒤에만 크레딧을 표시하고 움직이기 시작한다.
	credits_text.visible = true
	credits_running = true


# ============================================================
# 크레딧 관련
# ============================================================

func setup_credits():
	credits_text.bbcode_enabled = true
	credits_text.text = CREDITS_TEXT


func _process(delta):
	if not credits_running:
		return

	credits_text.position.y -= CREDITS_SCROLL_SPEED * delta

	var content_height = float(
		credits_text.get_content_height()
	)

	# 크레딧 전체가 화면 위로 완전히 사라졌으면
	# 마지막 결과 화면으로 전환한다.
	if credits_text.position.y + content_height <= -80.0:
		finish_credits_scroll()


func finish_credits_scroll():
	if not credits_running:
		return

	credits_running = false
	credits_text.visible = false

	result_center.visible = true
	result_screen_visible = true

	start_result_input_delay()


func start_result_input_delay():
	can_return_to_title = false

	await get_tree().create_timer(
		RESULT_INPUT_DELAY
	).timeout

	can_return_to_title = true


# ============================================================
# 최종 결과 화면
# ============================================================

func setup_result_screen():
	var ending_result = GameSession.get_ending_result()

	var play_time_seconds = float(
		ending_result.get(
			"play_time_seconds",
			0.0
		)
	)

	var defeated_enemy_count = int(
		ending_result.get(
			"defeated_enemy_count",
			0
		)
	)

	var enemy_results = ending_result.get(
		"enemy_results",
		[]
	)

	play_time_label.text = (
		"PLAY TIME\n"
		+ format_play_time(play_time_seconds)
	)

	total_defeated_label.text = (
		"ENEMIES DEFEATED\n"
		+ str(defeated_enemy_count)
	)

	setup_enemy_result_grid(enemy_results)


# 플레이 시간을 시:분:초 형식으로 변환
func format_play_time(play_time_seconds):
	var total_seconds = int(play_time_seconds)

	var hours = floori(total_seconds / 3600.0)
	var minutes = floori(
		(total_seconds % 3600) / 60.0
	)
	var seconds = total_seconds % 60

	return "%02d:%02d:%02d" % [
		hours,
		minutes,
		seconds
	]


# 적별 O / --- 결과를 생성
func setup_enemy_result_grid(enemy_results):
	for child in enemy_grid.get_children():
		child.queue_free()

	if typeof(enemy_results) != TYPE_ARRAY:
		return

	for enemy_result in enemy_results:
		if typeof(enemy_result) != TYPE_DICTIONARY:
			continue

		var enemy_name = str(
			enemy_result.get(
				"name",
				"알 수 없음"
			)
		)

		var defeated = bool(
			enemy_result.get(
				"defeated",
				false
			)
		)

		var enemy_name_label = Label.new()
		enemy_name_label.text = enemy_name
		enemy_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		enemy_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

		enemy_name_label.add_theme_font_size_override(
			"font_size",
			24
		)

		enemy_name_label.add_theme_color_override(
			"font_color",
			Color.WHITE
		)

		enemy_grid.add_child(enemy_name_label)

		var result_label = Label.new()

		if defeated:
			result_label.text = "O"
		else:
			result_label.text = "---"

		result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		result_label.add_theme_font_size_override(
			"font_size",
			24
		)

		result_label.add_theme_color_override(
			"font_color",
			Color.WHITE
		)

		enemy_grid.add_child(result_label)


# ============================================================
# BGM
# ============================================================

func setup_credit_bgm():
	if credit_bgm == null:
		return

	if credit_bgm.stream == null:
		return

	# 게임 설정의 BGM 볼륨을 그대로 반영한다.
	credit_bgm.volume_db = (
		CREDIT_BGM_BASE_VOLUME_DB
		+ GameSession.get_bgm_volume_db()
	)

	if not credit_bgm.finished.is_connected(
		_on_credit_bgm_finished
	):
		credit_bgm.finished.connect(
			_on_credit_bgm_finished
		)

	credit_bgm.play()


func _on_credit_bgm_finished():
	if is_returning_to_title:
		return

	# 크레딧과 결과 화면 동안 계속 반복한다.
	credit_bgm.play()


# ============================================================
# 입력 / 타이틀 복귀
# ============================================================

func _unhandled_input(event):
	if not result_screen_visible:
		return

	if not can_return_to_title:
		return

	if is_returning_to_title:
		return

	if event is InputEventKey:
		if not event.pressed:
			return

		if event.echo:
			return

		if (
			event.keycode == KEY_ENTER
			or event.keycode == KEY_KP_ENTER
			or event.keycode == KEY_SPACE
		):
			await return_to_title()


func return_to_title():
	if is_returning_to_title:
		return

	is_returning_to_title = true
	can_return_to_title = false

	# 크레딧 BGM을 부드럽게 줄인다.
	if credit_bgm != null and credit_bgm.playing:
		var tween = create_tween()

		tween.tween_property(
			credit_bgm,
			"volume_db",
			-80.0,
			0.8
		)

		await tween.finished

		credit_bgm.stop()

	# 이전 엔딩 결과가 다음 게임까지 남지 않도록 정리
	GameSession.clear_ending_result()

	get_tree().change_scene_to_file(
		MAIN_MENU_SCENE_PATH
	)
