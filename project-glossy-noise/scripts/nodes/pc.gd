extends Node3D

@onready var os_panel: CanvasLayer = null
var is_os_open: bool = false

func _ready():
	var root = get_tree().current_scene
	if root:
		os_panel = root.get_node_or_null("OSPanel")
	
	if os_panel:
		os_panel.visible = false
		print("✅ PC подключен к OSPanel")
		
		# NameEdit
		var name_edit = os_panel.get_node_or_null("NameEdit")
		if name_edit:
			name_edit.text_submitted.connect(_on_name_submitted)
			print("✅ NameEdit подключен")
		
		# MailButton
		var mail_button = os_panel.get_node_or_null("MailButton")
		if mail_button:
			mail_button.pressed.connect(_on_mail_button_pressed)
			print("✅ MailButton подключен")
		
		# MailPanel — скрыть
		var mail_panel = os_panel.get_node_or_null("MailPanel")
		if mail_panel:
			mail_panel.visible = false
			print("✅ MailPanel скрыт по умолчанию")
		
		# MarketButton  ← ЭТО ПРОВЕРЬ
		var market_button = os_panel.get_node_or_null("MarketButton")
		if market_button:
			market_button.pressed.connect(_on_market_button_pressed)
			print("✅ MarketButton подключен")
		else:
			print("⚠️ MarketButton не найден")
		
		# MarketPanel — скрыть  ← ЭТО ПРОВЕРЬ
		var market_panel = os_panel.get_node_or_null("MarketPanel")
		if market_panel:
			market_panel.visible = false
			print("✅ MarketPanel скрыт по умолчанию")
		else:
			print("⚠️ MarketPanel не найден")
	else:
		print("⚠️ OSPanel не найден")
# ============================================
# ОТКРЫТИЕ ОС
# ============================================

func open_os():
	if not os_panel:
		print("⚠️ OSPanel не найден!")
		return
	
	is_os_open = not is_os_open
	os_panel.visible = is_os_open
	
	if is_os_open:
		print("🖥️ ОС Глитчи открыта")
		var glitchie = get_node_or_null("/root/GlitchieManager")
		if glitchie and glitchie.has_method("on_pc_opened"):
			glitchie.on_pc_opened()
	else:
		print("🖥️ ОС Глитчи закрыта")

# ============================================
# ВВОД ИМЕНИ
# ============================================

func _on_name_submitted(new_text: String):
	print("🖥️ Игрок ввёл имя: ", new_text)
	var glitchie = get_node_or_null("/root/GlitchieManager")
	if glitchie and glitchie.has_method("try_rename"):
		glitchie.try_rename(new_text)

# ============================================
# КНОПКА ПОЧТЫ
# ============================================

func _on_mail_button_pressed():
	var mail_panel = os_panel.get_node_or_null("MailPanel")
	if mail_panel:
		mail_panel.visible = not mail_panel.visible
		print("📬 MailPanel: ", "открыт" if mail_panel.visible else "закрыт")

func _on_market_button_pressed():
	var market_panel = os_panel.get_node_or_null("MarketPanel")
	if market_panel:
		market_panel.visible = not market_panel.visible
		print("🛒 MarketPanel: ", "открыт" if market_panel.visible else "закрыт")
