extends GutTest

var PlayerScene = preload("res://Scenes/Player/player.tscn")
var player

func before_each():
	player = PlayerScene.instantiate()
	add_child(player)
	await get_tree().process_frame

func after_each():
	player.queue_free()

func test_initial_health():
	assert_eq(player.health, 3)

func test_initial_jumping_state():
	assert_true(player.jumping)

func test_coyote_initially_false():
	assert_false(player.coyote)

func test_take_hit_reduces_health():
	var dummy = Node2D.new()
	dummy.global_position = player.global_position + Vector2.RIGHT

	player.take_hit(dummy)

	assert_eq(player.health, 2)

func test_take_hit_emits_signal():
	var dummy = Node2D.new()
	dummy.global_position = player.global_position + Vector2.RIGHT

	watch_signals(player)
	player.take_hit(dummy)

	assert_signal_emitted(player, "player_lost_health")

func test_take_hit_emits_death_signal_when_zero():
	player.health = 1

	var dummy = Node2D.new()
	dummy.global_position = player.global_position + Vector2.RIGHT

	watch_signals(player)
	player.take_hit(dummy)

	assert_signal_emitted(player, "player_lost_all_health")

func test_set_up_camera_limit():
	var rect = Rect2i(10, 20, 100, 200)

	player.set_up_camera_limit(rect)

	assert_eq(player.camera.limit_left, 10)
	assert_eq(player.camera.limit_top, 20)
	assert_eq(player.camera.limit_right, 110)
	assert_eq(player.camera.limit_bottom, 220)

func test_coyote_timer_timeout_resets_flag():
	player.coyote = true
	player._on_coyote_timer_timeout()
	assert_false(player.coyote)

func test_react_to_hitting_sets_jump():
	player.velocity.y = 0
	player.react_to_hitting(null)

	assert_almost_eq(player.velocity.y, player.jump_vel, 1.0)
	assert_true(player.jumping)

func test_jump_buffer_triggers_jump_when_conditions_met():
	player.velocity.y = 0
	player.jumping = false
	player.coyote = true

	var jump_timer = player.get_node("%JumpBufferTimer")
	jump_timer.start()

	player.handle_jump()

	assert_almost_eq(player.velocity.y, player.jump_vel, 1.0)

func test_handle_gravity_increases_fall_speed():
	player.velocity.y = 100

	var before = player.velocity.y
	player.handle_gravity(1.0)

	assert_gt(player.velocity.y, before)

func test_handle_cols_starts_coyote_when_leaving_floor():
	player.last_floor = true
	player.jumping = false
	player.coyote = false

	player.handle_cols()

	assert_not_null(player.get_node("%CoyoteTimer"))
