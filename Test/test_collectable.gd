extends GutTest

var CollectableScript = preload("res://Scenes/Interactables/collectable.gd")
var collectable
var anim_player


func before_each():
	collectable = CollectableScript.new()

	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	collectable.add_child(anim_player)
	collectable.anim_player = anim_player

	add_child(collectable)
	await get_tree().process_frame


func after_each():
	collectable.queue_free()

func test_initial_state():
	assert_false(collectable.collected)
	assert_true(collectable.is_visible())

func test_set_collected_true_hides_node():
	collectable.collected = true

	assert_true(collectable.collected)
	assert_false(collectable.is_visible())
	assert_eq(collectable.process_mode, Node.PROCESS_MODE_DISABLED)

func test_set_collected_false_shows_node():
	collectable.collected = true
	collectable.collected = false

	assert_false(collectable.collected)
	assert_true(collectable.is_visible())
	assert_eq(collectable.process_mode, Node.PROCESS_MODE_INHERIT)

func _test_collect_sets_collected_true_after_animation():
	var state = await collectable.collect()

	# simulate animation finished
	anim_player.animation_finished.emit("Collected")

	#await state

	assert_true(collectable.collected)
	assert_false(collectable.is_visible())
	assert_eq(collectable.process_mode, Node.PROCESS_MODE_DISABLED)
