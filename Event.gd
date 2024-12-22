extends Node

func listen(event_name : String, listener, method_to_call : String):
	var error_code = connect(event_name,listener,method_to_call)
	if error_code != 0:
		print_debug ("EventSingleton: Connection error. Code: " + str(error_code))
		print_debug (listener.name + "'s method "+ method_to_call + " on event " + event_name)


signal player_set
signal cutscene_start
signal end_cutscene_start
signal cutscene_over
signal pause  
signal unpause  
signal pause_menu_opened  
signal pause_menu_closed  
signal update_options 
signal fadeout_startmenu 
signal input_dash
signal player_faced_right
signal player_faced_left
signal idle
signal walk
signal jump
signal dash
signal airdash
signal land
signal wallslide
signal walljump
signal charge
signal shot (weapon)
signal shot_lemon (emitter, shot)
signal changed_weapon(new_weapon)
signal damage
signal player_death
signal headbump

signal charged_shot_release(charged_time)
signal shot_layer_enabled
signal shot_layer_disabled

signal healable_amount(amount)
signal disabled_lifesteal

signal hit_enemy  
signal charge_hit_enemy  
signal enemy_kill(killed_enemy)  

signal respawned(enemy)

signal miniboss_kill  

signal weapon_select_left  
signal weapon_select_right  
signal weapon_select_buster  
signal select_weapon(weapon_resource)  
 
signal screenshake(amount)
signal fade_out

signal full_hermes
signal full_icarus
signal full_ultimate
signal mixed_set

signal noahspark_cutscene_start
signal noahspark_cutscene_end

signal stage_start
signal stage_clear
signal stage_rotate
 
signal rotate_stage_in_degrees(degrees, room)
signal stage_rotate_end
signal unrotate  
signal rotate_exception(object)  
signal rotate_inclusion(object)  
signal stage_teleport  
signal stage_teleport_end  

signal gateway_capsule_teleport

signal boss_door_open  
signal boss_door_closed  
signal boss_door_exploded  
signal boss_cutscene_start  
signal vile_door_open  
signal vile_door_closed  
signal vile_door_exploded  
signal vile_cutscene_start  
signal vile_defeated

signal play_stage_song 
signal play_boss_music 
signal play_angry_boss_music 
signal play_stage_clear_music  
signal play_miniboss_music  

signal boss_start(boss) 
signal boss_health_appear(boss) 
signal boss_health_hide
signal new_camera_focus(new_focus) 
signal camera_follow_target 
signal camera_move_y 
signal camera_move 
signal camera_movement_concluded 
signal camera_ahead 
signal camera_center 
signal new_camera_limits 
signal new_camera_bounds_set(current_bounds) 
signal camera_offset(offset) 

signal door_transition_start
signal door_transition_end
signal disable_exit  

 
signal intro_x
signal x_appear
signal gameplay_start
signal game_over

signal disable_victory_ending
signal kingcrab_crash

signal capsule_open 
signal capsule_entered
signal capsule_dialogue_end
signal character_talking(character_name)
signal stopped_talking(character_name)
signal dialog_started
signal dialog_concluded

signal collected(collectable)

signal add_to_subtank(amount, played_song)  
signal add_to_ammo_reserve(amount)   
signal use_any_subtank  
signal use_subtank(id)  
signal added_subtank  
signal subtank_health_restore

signal alarm
signal darkness
signal turn_off_alarm
signal alarm_done
signal turn_off_darkness
signal pitch_black_energized
signal jellyfish_start
signal crystal_wall_created(wall)

signal normal_music_volume
signal half_music_volume

signal translation_updated
signal got_rank_s(section_name)
signal got_rank_sss

signal teleport_to_secret1
signal end_teleport_to_secret1

signal teleport_to_secret2
signal end_teleport_to_secret2

signal teleport_to_red
signal end_teleport_to_red

signal first_secret2_death
signal cutman_throw
signal cutman_received

signal show_warning
signal warning_done
signal show_ready
signal ready_done

signal disable_unneeded_objects  

signal ridearmor_activate  
signal ridearmor_deactivate  

signal moved_player_to_checkpoint(checkpoint)  
signal reached_checkpoint(checkpoint)  

signal weapon_get(weapon,current_armor)  

signal xdrive

signal gigacrash
signal special_activated(special_ability)
signal special_deactivated(special_ability)

signal teleport_rooster
signal teleport_manowar
signal teleport_trilobyte
signal teleport_panda
signal teleport_antonion
signal teleport_mantis
signal teleport_sunflower
signal teleport_yeti

signal gateway_crystal_get(boss_name)
signal gateway_boss_spawned(boss_name)
signal gateway_boss_defeated(boss_name)
signal gateway_lock_capsules
signal gateway_unlock_capsules
signal gateway_final_section
signal copy_sigma_desperation  
signal copy_sigma_flash  
signal copy_sigma_end_desperation  

signal vile_eject(devilbear)
signal set_vile_respawn(value)
signal vile_intro

signal boss_death_screen_flash
signal set_boss_bar(new_bar)
signal sigma_walls
signal sigma_desperation(atk_direction)
signal trilobyte_desperation
signal trilobyte_desperation_end
signal lumine_death
signal lumine_went_seraph
signal lumine_desperation
signal beat_seraph_lumine
signal final_fade_out

