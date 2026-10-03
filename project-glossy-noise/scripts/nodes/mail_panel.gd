extends Panel

## ============================================
## MAIL PANEL — UI почтового клиента
## ============================================

@onready var mail_list: VBoxContainer = $MailList
@onready var mail_content: RichTextLabel = $MailContent
@onready var accept_button: Button = $AcceptButton
@onready var close_button: Button = $MailCloseButton

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Подключаем кнопки
	close_button.pressed.connect(_on_close_pressed)
	accept_button.pressed.connect(_on_accept_pressed)
	accept_button.disabled = true
	
	# Заполняем список писем
	_populate_mail_list()
	
	# Скрываем панель по умолчанию
	visible = false
	
	print("✅ MailPanel готов")

# ============================================
# СПИСОК ПИСЕМ
# ============================================

func _populate_mail_list():
	# Очищаем список
	for child in mail_list.get_children():
		child.queue_free()
	
	var mm = get_node_or_null("/root/MailManager")
	if not mm:
		print("⚠️ MailManager не найден")
		return
	
	# Добавляем кнопки для каждого письма
	for mail in mm.get_all_mails():
		var btn = Button.new()
		btn.text = mail.subject + " (" + mail.sender + ")"
		btn.custom_minimum_size = Vector2(380, 40)
		btn.pressed.connect(_on_mail_selected.bind(mail.mail_id))
		mail_list.add_child(btn)

# ============================================
# ВЫБОР ПИСЬМА
# ============================================

func _on_mail_selected(mail_id: String):
	var mm = get_node_or_null("/root/MailManager")
	if not mm:
		return
	
	mm.select_mail(mail_id)
	
	# Показываем содержимое
	mail_content.text = "[b]" + mm.selected_mail.subject + "[/b]\n\n" + mm.selected_mail.body
	
	# Активируем кнопку «Принять заказ» только для настоящих заказов
	if mm.selected_mail.reward > 0 and mm.selected_mail.device_id != "":
		accept_button.disabled = false
	else:
		accept_button.disabled = true
	
	# Реакция Глитчи на пасхальные письма
	var glitchie = get_node_or_null("/root/GlitchieManager")
	if glitchie:
		match mail_id:
			"mail_glitchie_joke":
				glitchie.say("Даже не спрашивай.", "joke")
			"mail_dvar":
				glitchie.say("Мой транслятор пытался перевести это... База данных выдала ошибку 404.", "glitch")
			"mail_meme":
				glitchie.say("...Я не знаю, что это. И знать не хочу.", "confused")

# ============================================
# КНОПКИ
# ============================================

func _on_accept_pressed():
	var mm = get_node_or_null("/root/MailManager")
	if mm:
		mm.accept_order()
	
	# Закрываем панель
	visible = false

func _on_close_pressed():
	visible = false
	print("📬 MailPanel закрыт")
