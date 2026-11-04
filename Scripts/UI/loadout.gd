extends Control

@onready var proceed_button: TextureButton = $ProceedButton
@onready var skill_name: Label = $LoadoutBG/VBoxContainer2/SkillName
@onready var skill_cd_num: Label = $LoadoutBG/VBoxContainer2/HBoxContainer/SkillCDNum
@onready var skill_range_type: Label = $LoadoutBG/VBoxContainer2/HBoxContainer2/SkillRangeType
@onready var skill_description_2: Label = $LoadoutBG/VBoxContainer2/SkillDescription2
@onready var skill_cast_time: Label = $LoadoutBG/VBoxContainer2/HBoxContainer3/SkillCastTime
@onready var skill_bar: HBoxContainer = $SkillBar

@onready var skill_info: VBoxContainer = $LoadoutBG/VBoxContainer2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")
	skill_info.hide()
	proceed_button.hide()
	skill_bar.hide()
	
	proceed_button.disabled = true
	SignalHub.selected_skill.connect(update_button)
	SignalHub.hovered_skill.connect(update_info)

func update_button(_skill_resource: SkillResource = null) -> void:
	if GameState.skills.size() < 4:
		proceed_button.disabled = true
		pass
	else:
		proceed_button.disabled = false

func update_info(skill_resource: SkillResource) -> void:
	skill_info.show()
	skill_name.text = skill_resource.skill_name
	skill_cd_num.text = str(skill_resource.skill_cooldown) + "s"
	
	var skill_range: String
	match skill_resource.skill_range:
		GameDictionary.AtkRange.SELF:
			skill_range = "Self"
		GameDictionary.AtkRange.MELEE:
			skill_range = "Melee"
		GameDictionary.AtkRange.RANGED:
			skill_range = "Ranged"
	
	skill_cast_time.text = str(skill_resource.cast_time) + "s"
	
	skill_range_type.text = skill_range
	
	skill_description_2.text = skill_resource.skill_description

func unfurl_loadout() -> void:
	animation_player.play("unroll")
	await animation_player.animation_finished
	proceed_button.show()
	skill_bar.show()

func close_loadout() -> void:
	animation_player.play_backwards("unroll")
