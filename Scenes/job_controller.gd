class_name JobController
extends Node

@export var all_jobs:ResourceGroup
@export var player:PlayerVehicle

@onready var job_timer:Timer = get_node("JobTimer")

var _all_jobs:Array[TaxiJob] = []

func _ready() -> void:
	all_jobs.load_all_into(_all_jobs)
	job_timer.start()
	

func _on_job_timer_timeout() -> void:
	job_timer.stop()
	if player != null:
		if player.current_job == null:
			player.current_job = _all_jobs.pick_random()
	job_timer.start()
