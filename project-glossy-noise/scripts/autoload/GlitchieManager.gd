extends Node

## ============================================
## GLITCHIE MANAGER — Диалоги и реакции Глитчи
## Autoload
## ============================================

var dialogue_data: GlitchieDialogue = null
var last_stress_phrase_time: float = 0.0
var greeting_shown: bool = false

const STRESS_PHRASE_COOLDOWN: float = 15.0  # Чтобы не спамил

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Загружаем диалоги
	var rm = get_node_or_null("/root/ResourceManager")
	if rm:
		dialogue_data = rm.get_dialogue("default")
		if dialogue_data:
			print("✅ GlitchieManager: диалоги загружены")
		else:
			print("⚠️ GlitchieManager: диалог 'default' не найден")
	else:
		print("⚠️ GlitchieManager: ResourceManager не найден")
	
	# Подписываемся на сигналы GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.stress_changed.connect(_on_stress_changed)
		gm.order_completed.connect(_on_order_completed)
		print("✅ GlitchieManager подключен к GameManager")

# ============================================
# РЕАКЦИИ НА СОБЫТИЯ
# ============================================

func _on_stress_changed(new_stress: int):
	# Глитчи говорит только при стрессе выше 30
	if new_stress < 30:
		return
	
	# Кулдаун, чтобы не спамил
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_stress_phrase_time < STRESS_PHRASE_COOLDOWN:
		return
	
	last_stress_phrase_time = current_time
	
	var phrase = _get_stress_phrase(new_stress)
	if phrase != "":
		say(phrase, "stress")

func _on_order_completed():
	# Небольшая задержка, чтобы не перебивать "Заказ отправлен"
	await get_tree().create_timer(1.0).timeout
	var phrase = _get_random_phrase("repair_success")
	if phrase != "":
		say(phrase, "success")

func on_pc_opened():
	# Приветствие — ТОЛЬКО ПЕРВЫЙ РАЗ
	if not greeting_shown:
		greeting_shown = true
		var phrase = _get_random_phrase("phrases_low_stress")
		if phrase != "":
			say(phrase, "greeting")
	else:
		# При повторных заходах — можно короткая рабочая реплика
		# Пока — тишина, чтобы не спамить
		pass

# ============================================
# ВЫБОР ФРАЗ
# ============================================

func _get_stress_phrase(stress: int) -> String:
	if not dialogue_data:
		return ""
	
	if stress < 50:
		return _pick_random(dialogue_data.phrases_low_stress)
	elif stress < 70:
		return _pick_random(dialogue_data.phrases_mid_stress)
	else:
		return _pick_random(dialogue_data.phrases_high_stress)

func _get_random_phrase(field: String) -> String:
	if not dialogue_data:
		return ""
	
	var arr: Array = dialogue_data.get(field)
	if arr and arr.size() > 0:
		return _pick_random(arr)
	return ""

func _pick_random(arr: Array) -> String:
	if arr.size() == 0:
		return ""
	return arr[randi() % arr.size()]

func try_rename(new_name: String):
	if new_name.strip_edges() == "" or new_name == "Глитчи":
		return
	
	var phrase = ""
	
	match new_name.to_lower():
		# --- Классические ---
		"петя", "петр", "пётр":
			phrase = "Петя? Серьёзно? Нет. Я Глитчи. И это не обсуждается."
		"комп", "компьютер", "компуктер":
			phrase = "Комп — это то, что у тебя на столе. Я — Глитчи."
		"бот":
			phrase = "Бот? Я, между прочим, личность. Глитчи. Запомни."
		"ассистент":
			phrase = "Ассистент — это должность. Меня зовут Глитчи."
		
		# --- ПАСХАЛКИ ---
		"мелстрой", "меллстрой", "мельстрой":
			phrase = "Бэм-бэм-бэм-бэм... Глитчесть."
		"мафаня":
			phrase = "Мафаня? Слыхал, он сдох. А я — Глитчи."
		"коля", "николай":
			phrase = "Это твой друг? Скажи ему, что он дубень тот ещё... А, и да: Я — Глитчи."
		"путин":
			phrase = "Говорят, он и есть Управдом... Ну, это только теории душевнобольных. А я Глитчи, если что."
		"тоха", "т2х2", "антон", "татыржа":
			phrase = "Зря."
		"цой", "виктор цой":
			phrase = "Жив..."
		"жириновский", "жирик":
			phrase = "Чемодан, вокзал, на!"
		
		_:
			# Универсальные фразы (с подстановкой имени)
			var templates = [
				"«" + new_name + "»? Нет. Я — Глитчи.",
				"Назови так свой чайник. А я — Глитчи.",
				new_name + "? Ошибка 404: Уважение не найдено. Я — Глитчи.",
				"Серьёзно? «" + new_name + "»? Нет. Я — Глитчи."
			]
			phrase = templates[randi() % templates.size()]
	
	say(phrase, "rename")
	await get_tree().create_timer(2.5).timeout
	_reset_name_in_ui()

func _reset_name_in_ui():
	var root = get_tree().current_scene
	if root:
		var os_panel = root.get_node_or_null("OSPanel")
		if os_panel:
			var name_edit = os_panel.get_node_or_null("NameEdit")
			if name_edit:
				name_edit.text = "Глитчи"
				print("🤖 Глитчи: имя восстановлено")


# ============================================
# ВЫВОД ФРАЗЫ
# ============================================

func say(phrase: String, mood: String = "neutral"):
	print("🤖 Глитчи [", mood, "]: ", phrase)
	
	# Выводим в OSPanel, если открыт
	var root = get_tree().current_scene
	if root:
		var os_panel = root.get_node_or_null("OSPanel")
		if os_panel:
			var dialog_label = os_panel.get_node_or_null("DialogLabel")
			if dialog_label:
				dialog_label.text = "[Глитчи]: " + phrase
			else:
				print("⚠️ DialogLabel не найден в OSPanel")
