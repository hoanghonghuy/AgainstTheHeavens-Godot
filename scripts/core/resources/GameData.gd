# GameData.gd
class_name GameData
extends Resource

@export var realms: Array[RealmData]
@export var skills: Array[SkillData]
@export var items: Array[ItemData]
@export var npcs: Array[NPCData]
@export var recipes: Array[RecipeData]
@export var quests: Array[QuestData]
@export var buildings: Dictionary = {}
@export var cultivation_methods: Array[CultivationMethodData]
