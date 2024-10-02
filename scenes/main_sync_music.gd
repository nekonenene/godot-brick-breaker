extends AudioStreamPlayer

const BPM: float = 128
const BeatPerSec: float = 60.0 / BPM
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

var sync_stream: AudioStreamSynchronized
var playback: AudioStreamPlaybackSynchronized

var synth_vol = MaxVolDb
var hihat_vol = ZeroVolDb
var loop_vol = ZeroVolDb
var bd_snare_vol = ZeroVolDb
var etc_vol = ZeroVolDb

var music_bar: int = 0 # 小節
var music_beat: int = 0 # 拍（0-3）

var is_waiting_failed_music = false # 失敗音楽の再生待ちか
var is_waiting_end_music = false # ゲームクリア音楽の再生待ちか

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_stream = self.stream

	init_music_level()
	play()

	playback = get_stream_playback()

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
	if playback and is_playing():
		# Ref: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
		var time = get_playback_position() + AudioServer.get_time_since_last_mix()
		# Compensate for output latency
		time -= AudioServer.get_output_latency()
		var beat_count = int(time / BeatPerSec)
		@warning_ignore("INTEGER_DIVISION")
		music_bar = int(beat_count / 4)
		music_beat = beat_count % 4
		#print("bar:", music_bar, ", beat:", music_beat)

		if is_waiting_failed_music and music_beat == 0:
			stop()
			$MainFailedMusic.play()
		elif is_waiting_end_music and music_beat == 0:
			stop()
			$MainEndMusic.play()

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
