extends Node

# ---------------------------------------------------------------------------
# Truth types
# ---------------------------------------------------------------------------
enum TruthType {
	NECROMANCER      = 0,
	DEMON_PACT       = 1,
	ANCIENT_CURSE    = 2,
	HAUNTING         = 3,
	DIMENSIONAL_RIFT = 4,
	BLOOD_RITUAL     = 5,
}

# ---------------------------------------------------------------------------
# Truth data container
# ---------------------------------------------------------------------------
class TruthData:
	var type:         int
	var truth_name:   String
	var description:  String
	## 0.0 = all demons, 1.0 = all undead
	var undead_weight: float

	func _init(t: int, n: String, d: String, uw: float) -> void:
		type          = t
		truth_name    = n
		description   = d
		undead_weight = uw

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var current_truth:  TruthData = null
var winstreak:      int       = 0
var current_floor:  int       = 1

var _truths: Array = []

# ---------------------------------------------------------------------------
# Noise — rises with winstreak, blurs enemy ratios toward 50/50
# At streak 0:  pure signals
# At streak 6+: up to 60% noise — need to go deeper for clear evidence
# ---------------------------------------------------------------------------
func get_noise_level() -> float:
	return clampf(winstreak * 0.1, 0.0, 0.6)

## Returns the undead spawn probability adjusted for current noise level.
func effective_undead_weight() -> float:
	if current_truth == null:
		return 0.5
	return lerpf(current_truth.undead_weight, 0.5, get_noise_level())

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	_build_truths()


func _build_truths() -> void:
	_truths = [
		TruthData.new(TruthType.NECROMANCER,
			"Necromancer",
			"A practitioner of dark arts raising the dead. Expect organized undead patrols, ritual circles, and fallen enemies rising again.",
			0.85),
		TruthData.new(TruthType.DEMON_PACT,
			"Demon Pact",
			"Someone bargained with demons. Expect mostly demonic entities, altars with offerings, and portals.",
			0.10),
		TruthData.new(TruthType.ANCIENT_CURSE,
			"Ancient Curse",
			"Old magic gone wrong. Both undead and demons wander aimlessly. Look for ancient runes and corrupted architecture.",
			0.50),
		TruthData.new(TruthType.HAUNTING,
			"Haunting",
			"A vengeful spirit holds this place. Expect passive undead that only attack when disturbed. Watch for cold mist and writings.",
			1.00),
		TruthData.new(TruthType.DIMENSIONAL_RIFT,
			"Dimensional Rift",
			"A tear in reality leaking demons. Enemies spawn chaotically with no clear organisation. Look for rift tears in walls.",
			0.00),
		TruthData.new(TruthType.BLOOD_RITUAL,
			"Blood Ritual",
			"Something is being fed. Waves of both demon and undead servants guard sacrifice sites marked by altars and chains.",
			0.50),
	]

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Call at the start of each dungeon run to randomly assign a truth.
func pick_truth() -> void:
	current_truth = _truths[randi() % _truths.size()]


## Call when the player submits a theory at the hub.
## Returns true if the guess was correct.
func submit_theory(guess: int) -> bool:
	if current_truth == null:
		return false
	var correct := guess == current_truth.type
	if correct:
		winstreak += 1
	else:
		winstreak = 0
	return correct


## Returns all truths — used by the hub case file UI.
func get_all_truths() -> Array:
	return _truths


# ---------------------------------------------------------------------------
# Scene transitions
# ---------------------------------------------------------------------------

## Enter the dungeon from the hub (always starts at floor 1).
func enter_dungeon() -> void:
	current_floor = 1
	get_tree().change_scene_to_file("res://Main/World/world.tscn")


## Descend one floor and reload the dungeon scene.
func go_deeper() -> void:
	current_floor += 1
	get_tree().change_scene_to_file("res://Main/World/world.tscn")


## Return to hub and reset floor counter.
func return_to_hub() -> void:
	current_floor = 1
	get_tree().change_scene_to_file("res://Main/Hub/hub.tscn")
