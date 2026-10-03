extends Resource
class_name GlitchieDialogue

## ============================================
## GLITCHIE DIALOGUE — Ресурс для диалогов Глитчи
## ============================================

@export var dialogue_id: String = ""            # Уникальный ключ, напр. "default"

# Фразы по уровням стресса
@export var phrases_low_stress: Array[String] = []     # 0-30%
@export var phrases_mid_stress: Array[String] = []     # 31-70%
@export var phrases_high_stress: Array[String] = []    # 71-100%

# Реакции на аномалии
@export var anomalous_reactions: Array[String] = []

# Фразы-отказы при попытке переименования
@export var rename_refusals: Array[String] = []

# Реакции на успешный/неудачный ремонт
@export var repair_success: Array[String] = []
@export var repair_fail: Array[String] = []
