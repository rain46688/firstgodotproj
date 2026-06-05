extends Control

# ============================================================
# MainMenuScene
# ------------------------------------------------------------
# 게임 시작 시 가장 먼저 보여줄 메인 메뉴 화면.
#
# 역할:
# - 처음부터 시작
# - 이어하기
# - 종료
# - 난이도 선택 창 표시
# - 메인 메뉴 UI 스타일 적용
# - 버튼 클릭/이동 사운드 재생
#
# 현재 단계에서는 실제 main.tscn으로 이동하지 않고,
# GameSession에 선택 정보가 정상 저장되는지만 확인한다.
# ============================================================

# ------------------------------------------------------------
# 폰트 경로
# ------------------------------------------------------------
# 프로젝트 안의 실제 폰트 위치가 다르면 이 경로만 수정하면 된다.
const TITLE_FONT_PATH = "res://fonts/SB 어그로 L.ttf"
const TEXT_FONT_PATH = "res://fonts/x12y12pxMaruMinyaHangul.ttf"

# ------------------------------------------------------------
# 씬 경로
# ------------------------------------------------------------
# 기존 실제 게임 플레이 씬 경로.
# 네 프로젝트에서 main.tscn 위치가 다르면 이 경로만 수정하면 된다.
const MAIN_SCENE_PATH = "res://scenes/main.tscn"

# ------------------------------------------------------------
# UI 색상 설정
# ------------------------------------------------------------
const BACKGROUND_COLOR = Color("#000000")

const TEXT_COLOR = Color("#ffffff")
const DISABLED_TEXT_COLOR = Color(0.45, 0.45, 0.45, 1.0)

const BUTTON_NORMAL_COLOR = Color(0.02, 0.02, 0.02, 0.65)
const BUTTON_HOVER_COLOR = Color(0.18, 0.18, 0.18, 0.75)
const BUTTON_PRESSED_COLOR = Color(0.35, 0.35, 0.35, 0.85)
const BUTTON_DISABLED_COLOR = Color(0.02, 0.02, 0.02, 0.35)

const BUTTON_BORDER_COLOR = Color(0.75, 0.75, 0.75, 0.45)
const BUTTON_FOCUS_BORDER_COLOR = Color(1.0, 1.0, 1.0, 0.9)

const PANEL_COLOR = Color(0.0, 0.0, 0.0, 0.78)
const PANEL_BORDER_COLOR = Color(0.7, 0.7, 0.7, 0.35)

# ------------------------------------------------------------
# 메인 메뉴 UI 노드
# ------------------------------------------------------------

# 검은 배경
@onready var background = $Background

# 중앙 메인 버튼 박스
@onready var center_box = $CenterBox

# 난이도 선택 패널
@onready var difficulty_panel = $DifficultyPanel

# 제목 라벨
@onready var title_label = $CenterBox/TitleLabel
@onready var difficulty_title_label = $DifficultyPanel/DifficultyBox/DifficultyTitleLabel

# 메인 메뉴 버튼
@onready var start_button = $CenterBox/StartButton
@onready var continue_button = $CenterBox/ContinueButton
@onready var setting_button = $CenterBox/SettingButton
@onready var quit_button = $CenterBox/QuitButton

# 난이도 선택 버튼
@onready var normal_button = $DifficultyPanel/DifficultyBox/NormalButton
@onready var hard_button = $DifficultyPanel/DifficultyBox/HardButton
@onready var nightmare_button = $DifficultyPanel/DifficultyBox/NightmareButton
@onready var hardcore_button = $DifficultyPanel/DifficultyBox/HardcoreButton
@onready var back_button = $DifficultyPanel/DifficultyBox/BackButton

# 버튼 클릭/이동 사운드
@onready var click_sound = $ClickSound

# 설정 패널
@onready var settings_panel = $SettingsPanel
@onready var settings_box = $SettingsPanel/SettingsBox

@onready var settings_title_label = $SettingsPanel/SettingsBox/SettingsTitleLabel
@onready var bgm_volume_label = $SettingsPanel/SettingsBox/BgmVolumeLabel
@onready var bgm_volume_slider = $SettingsPanel/SettingsBox/BgmVolumeSlider
@onready var sfx_volume_label = $SettingsPanel/SettingsBox/SfxVolumeLabel
@onready var sfx_volume_slider = $SettingsPanel/SettingsBox/SfxVolumeSlider
@onready var settings_reset_button = $SettingsPanel/SettingsBox/SettingsResetButton
@onready var settings_back_button = $SettingsPanel/SettingsBox/SettingsBackButton

# 전환 암전 / 로딩 표시
@onready var fade_rect = $FadeRect
@onready var loading_label = $LoadingLabel

# 메인 메뉴 BGM
@onready var main_menu_bgm = get_node_or_null("MainMenuBgm")

# 포커스가 처음 잡힐 때 바로 효과음이 나는 것을 막기 위한 변수
var can_play_focus_sound = false

# 씬 전환 중 중복 입력 방지
var is_transitioning = false


func _ready():
	# UI 기본 텍스트 설정
	setup_texts()

	# UI 스타일 적용
	apply_ui_style()

	# 이어하기 버튼 활성/비활성 상태 갱신
	update_continue_button_state()

	# 버튼 시그널 연결
	connect_button_signals()

	# 설정 패널 초기화
	setup_settings_panel()

	# 메인 메뉴 클릭 효과음에 현재 SFX 설정 적용
	register_main_menu_sfx_base_volumes()
	apply_main_menu_sfx_volume()

	# 메인 메뉴 BGM 설정 적용 및 재생
	register_main_menu_bgm_base_volume()
	apply_main_menu_bgm_volume()
	play_main_menu_bgm()

	# 시작 화면은 메인 버튼 화면으로 표시
	difficulty_panel.visible = false
	settings_panel.visible = false
	center_box.visible = true
	
	# 전환 연출 초기 상태
	setup_transition_ui()

	# 키보드 조작을 위해 첫 버튼에 포커스 부여
	start_button.grab_focus()

	# 첫 프레임이 지난 뒤부터 포커스 이동 사운드를 허용한다.
	await get_tree().process_frame
	can_play_focus_sound = true

# ------------------------------------------------------------
# UI 기본 텍스트 설정
# ------------------------------------------------------------
func setup_texts():
	title_label.text = "TEST"

	start_button.text = "처음부터"
	continue_button.text = "이어하기"
	setting_button.text = "설정"
	quit_button.text = "종료"

	difficulty_title_label.text = "난이도를 선택하세요"

	normal_button.text = "일반 - 기본 난이도"
	hard_button.text = "어려움 - 적 체력 1.5배 / 빨간 탄막 증가"
	nightmare_button.text = "악몽 - 적 체력 2배 / 모든 탄막 빨간색"
	hardcore_button.text = "하드코어 - 사망 시 세이브 삭제"
	back_button.text = "뒤로"

	settings_title_label.text = "설정"
	settings_reset_button.text = "초기화"
	settings_back_button.text = "뒤로"

# ------------------------------------------------------------
# UI 스타일 전체 적용
# ------------------------------------------------------------
func apply_ui_style():
	# 배경 색상 적용
	background.color = BACKGROUND_COLOR

	# 폰트 로드
	var title_font = load_font_or_null(TITLE_FONT_PATH)
	var text_font = load_font_or_null(TEXT_FONT_PATH)

	# 타이틀 스타일
	apply_label_style(title_label, title_font, 54)
	apply_label_style(difficulty_title_label, title_font, 34)
	apply_label_style(settings_title_label, title_font, 34)

	# 설정 라벨 스타일
	apply_label_style(bgm_volume_label, text_font, 22)
	apply_label_style(sfx_volume_label, text_font, 22)

	# 패널 스타일
	apply_panel_style(difficulty_panel)
	apply_panel_style(settings_panel)

	# 모든 버튼 스타일 적용
	for button in get_all_menu_buttons():
		apply_button_style(button, text_font)

# ------------------------------------------------------------
# 폰트 로드
# ------------------------------------------------------------
func load_font_or_null(font_path):
	# 경로에 폰트가 없으면 오류를 내지 않고 기본 폰트를 사용한다.
	if ResourceLoader.exists(font_path):
		return load(font_path)

	print("폰트 파일을 찾을 수 없음: " + font_path)
	return null

# ------------------------------------------------------------
# 라벨 스타일 적용
# ------------------------------------------------------------
func apply_label_style(label, font, font_size):
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.add_theme_font_size_override("font_size", font_size)

	if font != null:
		label.add_theme_font_override("font", font)

# ------------------------------------------------------------
# 패널 스타일 적용
# ------------------------------------------------------------
func apply_panel_style(panel):
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = PANEL_COLOR
	panel_style.border_color = PANEL_BORDER_COLOR
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24

	panel.add_theme_stylebox_override("panel", panel_style)

# ------------------------------------------------------------
# 버튼 스타일 적용
# ------------------------------------------------------------
func apply_button_style(button, font):
	# 버튼 크기와 정렬
	button.custom_minimum_size = Vector2(420, 52)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 버튼 폰트
	button.add_theme_font_size_override("font_size", 24)

	if font != null:
		button.add_theme_font_override("font", font)

	# 버튼 글자 색상
	button.add_theme_color_override("font_color", TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", TEXT_COLOR)
	button.add_theme_color_override("font_focus_color", TEXT_COLOR)
	button.add_theme_color_override("font_disabled_color", DISABLED_TEXT_COLOR)

	# 버튼 배경 스타일
	button.add_theme_stylebox_override("normal", make_button_style(BUTTON_NORMAL_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("hover", make_button_style(BUTTON_HOVER_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("pressed", make_button_style(BUTTON_PRESSED_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("disabled", make_button_style(BUTTON_DISABLED_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("focus", make_button_style(Color(0, 0, 0, 0), BUTTON_FOCUS_BORDER_COLOR))

# ------------------------------------------------------------
# 버튼 StyleBox 생성
# ------------------------------------------------------------
func make_button_style(bg_color, border_color):
	var style = StyleBoxFlat.new()

	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)

	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	return style

# ------------------------------------------------------------
# 모든 메뉴 버튼 배열 반환
# ------------------------------------------------------------
func get_all_menu_buttons():
	return [
		start_button,
		continue_button,
		setting_button,
		quit_button,
		normal_button,
		hard_button,
		nightmare_button,
		hardcore_button,
		back_button,
		settings_reset_button,
		settings_back_button
	]

# ------------------------------------------------------------
# 버튼 시그널 연결
# ------------------------------------------------------------
func connect_button_signals():
	# 메인 메뉴 버튼
	start_button.pressed.connect(_on_start_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	setting_button.pressed.connect(_on_setting_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	# 난이도 선택 버튼
	normal_button.pressed.connect(_on_normal_button_pressed)
	hard_button.pressed.connect(_on_hard_button_pressed)
	nightmare_button.pressed.connect(_on_nightmare_button_pressed)
	hardcore_button.pressed.connect(_on_hardcore_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	# 설정 패널
	settings_back_button.pressed.connect(_on_settings_back_button_pressed)
	settings_reset_button.pressed.connect(_on_settings_reset_button_pressed)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_slider_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_changed)

	# 모든 버튼에 공통 사운드 이벤트 연결
	for button in get_all_menu_buttons():
		button.mouse_entered.connect(_on_menu_button_focused_or_hovered.bind(button))
		button.focus_entered.connect(_on_menu_button_focused_or_hovered.bind(button))

# ------------------------------------------------------------
# 버튼 이동/마우스 올림 사운드
# ------------------------------------------------------------
func _on_menu_button_focused_or_hovered(button):
	if not can_play_focus_sound:
		return

	if button.disabled:
		return

	play_click_sound()

# ------------------------------------------------------------
# 클릭 사운드 재생
# ------------------------------------------------------------
func play_click_sound():
	if click_sound == null:
		return

	# 같은 사운드가 빠르게 반복될 때 처음부터 다시 재생되도록 처리
	click_sound.stop()
	click_sound.play()

# ------------------------------------------------------------
# 이어하기 버튼 상태 갱신
# ------------------------------------------------------------
func update_continue_button_state():
	# 현재는 1번 슬롯만 사용한다.
	var has_save = GameSession.has_save_file(1)

	# 세이브 파일이 없으면 버튼 비활성화
	continue_button.disabled = not has_save

	if has_save:
		continue_button.text = "이어하기"
	else:
		continue_button.text = "이어하기 - 세이브 없음"

# ------------------------------------------------------------
# 난이도 선택 패널 표시
# ------------------------------------------------------------
func show_difficulty_panel():
	# 메인 메뉴 버튼 숨김
	center_box.visible = false

	# 난이도 선택 패널 표시
	difficulty_panel.visible = true

	# 키보드 조작을 위해 일반 버튼에 포커스 부여
	normal_button.grab_focus()

# ------------------------------------------------------------
# 난이도 선택 패널 닫기
# ------------------------------------------------------------
func hide_difficulty_panel():
	# 난이도 선택 패널 숨김
	difficulty_panel.visible = false

	# 메인 메뉴 버튼 다시 표시
	center_box.visible = true

	# 키보드 조작을 위해 처음부터 버튼에 포커스 부여
	start_button.grab_focus()

# ------------------------------------------------------------
# 새 게임 시작 정보 설정
# ------------------------------------------------------------
func start_new_game_with_difficulty(selected_difficulty):
	if is_transitioning:
		return

	play_click_sound()

	GameSession.setup_new_game(selected_difficulty)

	print("선택된 난이도: " + GameSession.get_difficulty_name())
	print("새 게임 씬으로 이동")

	await transition_to_main_scene()

# ------------------------------------------------------------
# 메인 메뉴 버튼 이벤트
# ------------------------------------------------------------

func _on_start_button_pressed():
	# 클릭 사운드 재생
	play_click_sound()

	# 처음부터 클릭 시 난이도 선택 창 표시
	show_difficulty_panel()

func _on_continue_button_pressed():
	if is_transitioning:
		return

	play_click_sound()

	# 세이브 파일이 없으면 이어하기 불가
	if not GameSession.has_save_file(1):
		print("세이브 파일이 없어서 이어하기 불가")
		return

	# GameSession에 이어하기 정보 저장
	GameSession.setup_load_game(1)

	print("이어하기 선택됨")
	print("로드 게임 씬으로 이동")

	await transition_to_main_scene()

func _on_quit_button_pressed():
	# 클릭 사운드 재생
	play_click_sound()

	# 게임 종료
	get_tree().quit()

# ------------------------------------------------------------
# 난이도 버튼 이벤트
# ------------------------------------------------------------

func _on_normal_button_pressed():
	start_new_game_with_difficulty(GameSession.DIFFICULTY_NORMAL)

func _on_hard_button_pressed():
	start_new_game_with_difficulty(GameSession.DIFFICULTY_HARD)

func _on_nightmare_button_pressed():
	start_new_game_with_difficulty(GameSession.DIFFICULTY_NIGHTMARE)

func _on_hardcore_button_pressed():
	start_new_game_with_difficulty(GameSession.DIFFICULTY_HARDCORE)

func _on_back_button_pressed():
	# 클릭 사운드 재생
	play_click_sound()

	# 난이도 선택 창에서 뒤로가기
	hide_difficulty_panel()

# ------------------------------------------------------------
# 키보드 입력 처리
# ------------------------------------------------------------
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("esc"):
		if settings_panel.visible:
			play_click_sound()
			close_settings_panel()
			return

		if difficulty_panel.visible:
			play_click_sound()
			hide_difficulty_panel()
			return

# ------------------------------------------------------------
# 메인 메뉴 효과음 기본 볼륨 저장
# ------------------------------------------------------------
func register_main_menu_sfx_base_volumes():
	if click_sound == null:
		return

	if not click_sound.has_meta("base_volume_db"):
		click_sound.set_meta("base_volume_db", click_sound.volume_db)

# ------------------------------------------------------------
# 메인 메뉴 효과음 볼륨 적용
# ------------------------------------------------------------
func apply_main_menu_sfx_volume():
	if click_sound == null:
		return

	var base_volume_db = 0.0

	if click_sound.has_meta("base_volume_db"):
		base_volume_db = float(click_sound.get_meta("base_volume_db"))
	else:
		base_volume_db = click_sound.volume_db
		click_sound.set_meta("base_volume_db", base_volume_db)

	click_sound.volume_db = base_volume_db + GameSession.get_sfx_volume_db()

# ------------------------------------------------------------
# 설정 패널 초기화
# ------------------------------------------------------------
func setup_settings_panel():
	settings_panel.visible = false

	bgm_volume_slider.value = GameSession.bgm_volume_percent
	sfx_volume_slider.value = GameSession.sfx_volume_percent

	update_bgm_volume_label()
	update_sfx_volume_label()

# ------------------------------------------------------------
# 설정 패널 열기
# ------------------------------------------------------------
func open_settings_panel():
	center_box.visible = false
	difficulty_panel.visible = false
	settings_panel.visible = true

	bgm_volume_slider.grab_focus()

# ------------------------------------------------------------
# 설정 패널 닫기
# ------------------------------------------------------------
func close_settings_panel():
	settings_panel.visible = false
	center_box.visible = true

	setting_button.grab_focus()

# ------------------------------------------------------------
# BGM 볼륨 라벨 갱신
# ------------------------------------------------------------
func update_bgm_volume_label():
	bgm_volume_label.text = "BGM 볼륨 : " + str(int(bgm_volume_slider.value)) + "%"

# ------------------------------------------------------------
# SFX 볼륨 라벨 갱신
# ------------------------------------------------------------
func update_sfx_volume_label():
	sfx_volume_label.text = "SFX 볼륨 : " + str(int(sfx_volume_slider.value)) + "%"

# ------------------------------------------------------------
# 메인 메뉴 BGM 기본 볼륨 저장
# ------------------------------------------------------------
func register_main_menu_bgm_base_volume():
	if main_menu_bgm == null:
		return

	if not main_menu_bgm.has_meta("base_volume_db"):
		main_menu_bgm.set_meta("base_volume_db", main_menu_bgm.volume_db)

# ------------------------------------------------------------
# 메인 메뉴 BGM 볼륨 적용
# ------------------------------------------------------------
func apply_main_menu_bgm_volume():
	if main_menu_bgm == null:
		return

	var base_volume_db = 0.0

	if main_menu_bgm.has_meta("base_volume_db"):
		base_volume_db = float(main_menu_bgm.get_meta("base_volume_db"))
	else:
		base_volume_db = main_menu_bgm.volume_db
		main_menu_bgm.set_meta("base_volume_db", base_volume_db)

	main_menu_bgm.volume_db = base_volume_db + GameSession.get_bgm_volume_db()

# ------------------------------------------------------------
# 메인 메뉴 BGM 루프 설정
# ------------------------------------------------------------
func set_main_menu_bgm_loop(stream, loop = true):
	if stream == null:
		return

	if stream is AudioStreamMP3:
		stream.loop = loop
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop

# ------------------------------------------------------------
# 메인 메뉴 BGM 재생
# ------------------------------------------------------------
func play_main_menu_bgm():
	if main_menu_bgm == null:
		return

	if main_menu_bgm.stream == null:
		return

	# 메인 메뉴 BGM은 반복 재생되도록 설정
	set_main_menu_bgm_loop(main_menu_bgm.stream, true)

	main_menu_bgm.play()
	
func _on_setting_button_pressed():
	play_click_sound()
	open_settings_panel()

func _on_settings_back_button_pressed():
	play_click_sound()
	close_settings_panel()

func _on_bgm_volume_slider_changed(value):
	GameSession.set_bgm_volume_percent(value)
	update_bgm_volume_label()

	# 메인 메뉴 BGM이 있다면 즉시 볼륨 적용
	apply_main_menu_bgm_volume()

func _on_sfx_volume_slider_changed(value):
	GameSession.set_sfx_volume_percent(value)
	update_sfx_volume_label()

	# 메인 메뉴 클릭 효과음 즉시 볼륨 적용
	apply_main_menu_sfx_volume()	

func _on_settings_reset_button_pressed():
	play_click_sound()

	# GameSession의 오디오 설정을 기본값으로 초기화하고 settings.json에 저장한다.
	GameSession.reset_audio_settings()

	# 슬라이더 값을 초기화된 값으로 갱신한다.
	bgm_volume_slider.value = GameSession.bgm_volume_percent
	sfx_volume_slider.value = GameSession.sfx_volume_percent

	# 라벨 갱신
	update_bgm_volume_label()
	update_sfx_volume_label()

	# 현재 메인 메뉴 BGM/SFX에도 즉시 반영
	apply_main_menu_bgm_volume()
	apply_main_menu_sfx_volume()

	print("메인 메뉴 설정 초기화 완료")

# ------------------------------------------------------------
# 전환 연출 UI 초기화
# ------------------------------------------------------------
func setup_transition_ui():
	# 메인 메뉴 전환 암전은 모든 메뉴 UI보다 위에 보여야 한다.
	fade_rect.z_index = 100
	loading_label.z_index = 101

	# 처음에는 투명한 검은 화면
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)

	# 로딩 문구는 처음에는 숨김
	loading_label.visible = false
	loading_label.text = "게임 불러오는 중..."

	# 배경 클릭을 막을 필요는 없으므로 평소에는 입력 무시
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ------------------------------------------------------------
# 메인 메뉴 모든 버튼 활성/비활성 처리
# ------------------------------------------------------------
func set_all_menu_buttons_disabled(disabled):
	for button in get_all_menu_buttons():
		if button == null:
			continue

		button.disabled = disabled

# ------------------------------------------------------------
# 메인 게임 씬으로 전환하는 함수
# ------------------------------------------------------------
func transition_to_main_scene():
	if is_transitioning:
		return

	is_transitioning = true

	# 전환 중 버튼 중복 입력 방지
	set_all_menu_buttons_disabled(true)

	# 메인 메뉴 BGM 정지
	if main_menu_bgm != null and main_menu_bgm.playing:
		main_menu_bgm.stop()

	# 로딩 문구 표시
	loading_label.visible = true
	loading_label.modulate.a = 0.0

	# 암전 시작
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)

	var tween = create_tween()

	# 화면을 검게 덮음
	tween.tween_property(
		fade_rect,
		"color:a",
		1.0,
		0.45
	)

	# 로딩 문구를 살짝 늦게 표시
	tween.parallel().tween_property(
		loading_label,
		"modulate:a",
		1.0,
		0.25
	)

	await tween.finished

	# 아주 짧게 검은 화면 유지
	await get_tree().create_timer(0.25).timeout

	# 기존 게임 플레이 씬으로 이동
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
