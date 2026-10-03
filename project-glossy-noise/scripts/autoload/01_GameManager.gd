extends Node

## ============================================
## GAME MANAGER — Глобальное состояние игры
## ============================================

# ------ СИГНАЛЫ ------
signal stress_changed(new_value: int)
signal time_changed(new_time: String)
signal money_changed(new_amount: int)
signal order_changed(order_data: Dictionary)
signal tv_anomaly_triggered()
signal tv_anomaly_stopped()
signal order_completed()

# ------ ОСНОВНЫЕ ПЕРЕМЕННЫЕ ------
enum TimeOfDay { DAY, EVENING, NIGHT, DEEP_NIGHT }

var current_time: TimeOfDay = TimeOfDay.DAY
var stress: int = 20  # 0-100
var money: int = 100
var current_order: Dictionary = {}

# ------ ФЛАГИ СОСТОЯНИЯ ------
var is_tv_anomaly_active: bool = false
var is_radio_on: bool = false
var current_radio_wave: int = 0
var is_game_paused: bool = false

# ------ ТАЙМЕРЫ ------
var time_timer: Timer
var stress_timer: Timer
var tv_timer: Timer

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Таймер смены времени суток (перезапускается с новым временем)
	time_timer = Timer.new()
	time_timer.one_shot = true
	time_timer.timeout.connect(_on_time_update)
	add_child(time_timer)
	_start_time_timer()
	
	# Таймер роста стресса (каждые 30 секунд)
	stress_timer = Timer.new()
	stress_timer.wait_time = 30.0
	stress_timer.timeout.connect(_on_stress_update)
	add_child(stress_timer)
	stress_timer.start()
	
	# Таймер случайных событий (ТВ-аномалия)
	tv_timer = Timer.new()
	tv_timer.wait_time = randf_range(45.0, 120.0)
	tv_timer.timeout.connect(_try_trigger_tv_anomaly)
	add_child(tv_timer)
	tv_timer.start()
	
	# Начальные сигналы
	emit_signal("stress_changed", stress)
	emit_signal("money_changed", money)
	emit_signal("time_changed", _get_time_string())
	
	# Подключение к AudioManager (с задержкой)
	call_deferred("_connect_to_audio_manager")

func _connect_to_audio_manager():
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		print("✅ GameManager подключен к AudioManager")
	else:
		print("⚠️ AudioManager не найден, повтор через 1 секунду")
		get_tree().create_timer(1.0).timeout.connect(_connect_to_audio_manager)

# ============================================
# УПРАВЛЕНИЕ ВРЕМЕНЕМ
# ============================================

func _start_time_timer():
	var wait_time = 0.0
	match current_time:
		TimeOfDay.DAY:
			wait_time = 900.0    # 15 минут
		TimeOfDay.EVENING:
			wait_time = 600.0   # 10 минут
		TimeOfDay.NIGHT:
			wait_time = 900.0    # 15 минут
		TimeOfDay.DEEP_NIGHT:
			wait_time = 300.0   # 5 минут
	time_timer.wait_time = wait_time
	time_timer.start()
	print("⏳ Таймер: ", wait_time / 60, " мин для ", _get_time_string())

func _on_time_update():
	match current_time:
		TimeOfDay.DAY:
			current_time = TimeOfDay.EVENING
		TimeOfDay.EVENING:
			current_time = TimeOfDay.NIGHT
		TimeOfDay.NIGHT:
			current_time = TimeOfDay.DEEP_NIGHT
		TimeOfDay.DEEP_NIGHT:
			current_time = TimeOfDay.DAY
	
	emit_signal("time_changed", _get_time_string())
	print("🕐 Время суток изменилось: ", _get_time_string())
	
	_start_time_timer()  # Перезапуск с новым временем

func _get_time_string() -> String:
	match current_time:
		TimeOfDay.DAY:
			return "День ☀️"
		TimeOfDay.EVENING:
			return "Вечер 🌅"
		TimeOfDay.NIGHT:
			return "Ночь 🌙"
		TimeOfDay.DEEP_NIGHT:
			return "Глубокая ночь 🕯️"
	return ""

# ============================================
# УПРАВЛЕНИЕ СТРЕССОМ
# ============================================

func _on_stress_update():
	var base_increase = 0.0
	match current_time:
		TimeOfDay.DAY:
			base_increase = 0.1       # Медленно (уют)
		TimeOfDay.EVENING:
			base_increase = 0.5       # Вечер — первое давление
		TimeOfDay.NIGHT:
			base_increase = 1.5       # Ночь — борьба
		TimeOfDay.DEEP_NIGHT:
			base_increase = 3.0       # Глубокая ночь — экстрим
	
	# ТВ-аномалия ускоряет рост
	if is_tv_anomaly_active:
		base_increase += 3.0
	
	add_stress(base_increase)

func add_stress(amount: float):
	stress = clamp(stress + int(amount), 0, 100)
	emit_signal("stress_changed", stress)
	
	if stress >= 100:
		_game_over()
	
	print("😰 Стресс: ", stress)

func reduce_stress(amount: int):
	stress = clamp(stress - amount, 0, 100)
	emit_signal("stress_changed", stress)
	print("😌 Стресс снижен до: ", stress)

# ============================================
# УПРАВЛЕНИЕ ДЕНЬГАМИ
# ============================================

func add_money(amount: int):
	money += amount
	emit_signal("money_changed", money)
	print("💰 +", amount, " монет. Всего: ", money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		emit_signal("money_changed", money)
		print("💰 -", amount, " монет. Осталось: ", money)
		return true
	else:
		print("❌ Недостаточно денег!")
		return false

# ============================================
# УПРАВЛЕНИЕ ЗАКАЗАМИ
# ============================================

func start_new_order(order_data: Dictionary):
	current_order = order_data
	emit_signal("order_changed", current_order)
	print("📦 Новый заказ: ", order_data.get("name", "Без названия"))

func finish_order():
	if current_order.is_empty():
		return
	
	var reward = current_order.get("reward", 50)
	add_money(reward)
	reduce_stress(10)  # Сброс стресса за выполненный заказ
	
	var order_name = current_order.get("name", "Заказ")
	print("✅ Заказ выполнен: ", order_name)
	current_order = {}
	emit_signal("order_changed", current_order)
	
	emit_signal("order_completed")
	print("📢 Сигнал order_completed отправлен!")

# ============================================
# ТВ-АНОМАЛИЯ
# ============================================

func _try_trigger_tv_anomaly():
	var chance = 0.0
	
	match current_time:
		TimeOfDay.DAY:
			chance = 0.05
		TimeOfDay.EVENING:
			chance = 0.15
		TimeOfDay.NIGHT:
			chance = 0.30
		TimeOfDay.DEEP_NIGHT:
			chance = 0.45
	
	if stress > 60:
		chance += 0.15
	
	if is_tv_anomaly_active:
		return
	
	if randf() < chance:
		trigger_tv_anomaly()

func trigger_tv_anomaly():
	is_tv_anomaly_active = true
	emit_signal("tv_anomaly_triggered")
	print("📺 АНОМАЛИЯ! Телевизор включился сам!")
	
	tv_timer.start(randf_range(60.0, 180.0))

func stop_tv_anomaly():
	if is_tv_anomaly_active:
		is_tv_anomaly_active = false
		emit_signal("tv_anomaly_stopped")
		reduce_stress(10)
		print("📺 Телевизор выключен! Стресс снижен.")

# ============================================
# РАДИО
# ============================================

func toggle_radio():
	is_radio_on = !is_radio_on
	print("📻 Радио: ", "Вкл" if is_radio_on else "Выкл")
	
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.toggle_radio()
	else:
		print("⚠️ AudioManager не найден")

func switch_radio_wave():
	var max_waves = 4
	current_radio_wave = (current_radio_wave + 1) % max_waves
	print("📻 Волна переключена на: ", current_radio_wave)
	
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.switch_wave(current_radio_wave)
	else:
		print("⚠️ AudioManager не найден")

# ============================================
# GAME OVER
# ============================================

func _game_over():
	print("💀 GAME OVER! Стресс достиг предела.")
	get_tree().paused = true
	# TODO: Вывести экран геймовера

# ============================================
# СОХРАНЕНИЕ (ЗАГОТОВКА)
# ============================================

func save_game():
	pass

func load_game():
	pass

# ============================================
# ТЕСТОВЫЙ РЕЖИМ (F1)
# ============================================

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		print("=== ТЕСТ: GameManager работает! ===")
		add_stress(10)
		toggle_radio()
		switch_radio_wave()
