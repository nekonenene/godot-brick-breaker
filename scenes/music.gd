extends AudioStreamPlayer

const ZeroVolDb = -60.0
const MidVolDb = -12.0
const MaxVolDb = 0.0

enum {
	MAIN_SYNTH,
	HI_HAT,
	BD_SNARE,
	MAIN_LOOP,
	PAD_BASS_SE,
}

var interactive_stream: AudioStreamInteractive
var sync_stream: AudioStreamSynchronized

var synth_vol = MaxVolDb
var hihat_vol = ZeroVolDb
var loop_vol = ZeroVolDb
var bd_snare_vol = ZeroVolDb
var etc_vol = ZeroVolDb


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactive_stream = self.stream as AudioStreamInteractive
	sync_stream = interactive_stream.get_clip_stream(0)
	init_music_level()

	var change_sec = 18

	set_music_by_level(1)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(2)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(3)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(4)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(5)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(7)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(6)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(1)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(4)
	await get_tree().create_timer(change_sec).timeout
	set_music_by_level(7)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _change_vol_linear(idx, current_vol, target_vol, sec = 2.0):
	var times = 10
	var volume_diff = target_vol - current_vol
	if volume_diff == 0:
		return

	for i in times:
		var new_volume = current_vol + (volume_diff / times) * (i + 1)
		sync_stream.set_sync_stream_volume(idx, new_volume)

		if i != times:
			await get_tree().create_timer(sec / 10).timeout

func _set_all_vol(
	synth = ZeroVolDb,
	hihat = ZeroVolDb,
	loop = ZeroVolDb,
	bd_snare = ZeroVolDb,
	etc = ZeroVolDb,
):
	sync_stream.set_sync_stream_volume(MAIN_SYNTH, synth)
	sync_stream.set_sync_stream_volume(HI_HAT, hihat)
	sync_stream.set_sync_stream_volume(BD_SNARE, loop)
	sync_stream.set_sync_stream_volume(MAIN_LOOP, bd_snare)
	sync_stream.set_sync_stream_volume(PAD_BASS_SE, etc)
	synth_vol = synth
	hihat_vol = hihat
	loop_vol = loop
	bd_snare_vol = bd_snare
	etc_vol = etc

func _change_all_vol_linear(
	sec = 2.0,
	synth = ZeroVolDb,
	hihat = ZeroVolDb,
	loop = ZeroVolDb,
	bd_snare = ZeroVolDb,
	etc = ZeroVolDb,
):
	_change_vol_linear(MAIN_SYNTH, synth_vol, synth, sec)
	_change_vol_linear(HI_HAT, hihat_vol, hihat, sec)
	_change_vol_linear(BD_SNARE, loop_vol, loop, sec)
	_change_vol_linear(MAIN_LOOP, bd_snare_vol, bd_snare, sec)
	_change_vol_linear(PAD_BASS_SE, etc_vol, etc, sec)
	synth_vol = synth
	hihat_vol = hihat
	loop_vol = loop
	bd_snare_vol = bd_snare
	etc_vol = etc

func init_music_level():
	_set_all_vol(MaxVolDb)

func set_music_by_level(level: int, sec = 2.0):
	match level:
		1:
			_change_all_vol_linear(sec, MaxVolDb)
		2:
			_change_all_vol_linear(sec, MaxVolDb, MidVolDb)
		3:
			_change_all_vol_linear(sec, MaxVolDb, MidVolDb, MidVolDb)
		4:
			_change_all_vol_linear(sec, MaxVolDb, MaxVolDb, MaxVolDb)
		5:
			_change_all_vol_linear(sec, MaxVolDb, MaxVolDb, MaxVolDb, MaxVolDb)
		6:
			_change_all_vol_linear(sec, MaxVolDb, MaxVolDb, MaxVolDb, ZeroVolDb, MaxVolDb)
		7:
			_change_all_vol_linear(sec, MaxVolDb, MaxVolDb, MaxVolDb, MaxVolDb, MaxVolDb)
