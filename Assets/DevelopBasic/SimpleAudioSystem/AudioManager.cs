using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

namespace SimpleAudioSystem{
    public class AudioManager : Singleton<AudioManager>
    {
        [SerializeField] private AudioInfo_SO audioInfo;
    [Header("Audio source")]
        [SerializeField] private AudioSource ambience_loop;
        [SerializeField] private AudioSource music_loop;
        [SerializeField] private AudioSource default_sfx;
    [Header("Audio mixer")]
        [SerializeField] private AudioMixer mainMixer;
        [SerializeField] private AudioMixerSnapshot[] mixerSnapShots;
        private bool ambience_crossfading = false;
        private bool music_crossfading = false;

        private string current_music_name = string.Empty;
        public string current_ambience_name{get; private set;} = string.Empty;

        private const string masterVolumeName = "MasterVolume";
        private CoroutineExcuter ambFader;
        private CoroutineExcuter musFader;

    #region Sound Play
        public void PlayMusic(string audio_name, float volume = 1){
            current_music_name = audio_name;
            if(audio_name == string.Empty) music_loop.Stop();

            music_loop.clip = audioInfo.GetBGMClipByName(audio_name);
            if(music_loop.clip!=null){
                music_loop.volume = volume;
                music_loop.Play();
            }
        }
        public void PlayMusic(string audio_name, bool startOver, float transitionTime, float volume = 1, bool overWriteIfCrossfade = false){
        //If no audio name, fade out the ambience
            if(audio_name == string.Empty){
                FadeAudio(music_loop, 0, transitionTime, true);
                current_music_name = string.Empty;
            }
        //If the audio name is the same, only fade the volume to the target value
            if(current_music_name==audio_name){
                FadeAudio(music_loop, volume, transitionTime);
            }
            else{
                if(current_music_name == string.Empty || !music_loop.isPlaying){
                    music_loop.clip = audioInfo.GetBGMClipByName(audio_name);
                    if(music_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    music_loop.volume = volume;
                    music_loop.Play();
                }
                else{
                    if(music_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    CrossFadeMusic(audio_name, volume, startOver, transitionTime, overWriteIfCrossfade);
                }
                current_music_name = audio_name;
            }            
        }
        public void PlayAmbience(string audio_name, bool startOver, float transitionTime, float volume = 1, bool overWriteIfCrossfade = false){
        //If no audio name, fade out the ambience
            if(audio_name == string.Empty){
                FadeAudio(ambience_loop, 0, transitionTime, true);
                current_ambience_name = string.Empty;
            }
        //If the audio name is the same, only fade the volume to the target value
            if(current_ambience_name==audio_name){
                FadeAudio(ambience_loop, volume, transitionTime);
            }
            else{
                if(current_ambience_name == string.Empty || !ambience_loop.isPlaying){
                    ambience_loop.clip = audioInfo.GetAMBClipByName(audio_name);
                    if(ambience_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    ambience_loop.volume = volume;
                    ambience_loop.Play();
                }
                else{
                    if(ambience_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    CrossFadeAmbience(audio_name, volume, startOver, transitionTime, overWriteIfCrossfade);
                }
                current_ambience_name = audio_name;
            }            
        }
        public void PlayAmbience(string audio_name, bool startOver, float volume=1, bool overWriteIfCrossfade = false){
        //If no audio name, fade out the ambience
            if(audio_name == string.Empty){
                FadeAudio(ambience_loop, 0, 0.5f, true);
                current_ambience_name = string.Empty;
            }
        //If the audio name is the same, only fade the volume to the target value
            if(current_ambience_name==audio_name){
                FadeAudio(ambience_loop, volume, 0.5f);
            }
            else{
                if(current_ambience_name == string.Empty || !ambience_loop.isPlaying){
                    ambience_loop.clip = audioInfo.GetAMBClipByName(audio_name);
                    if(ambience_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    ambience_loop.volume = volume;
                    ambience_loop.Play();
                }
                else{
                    if(ambience_loop.clip==null){
                        Debug.LogWarning("No clip found, nothing will be done for ambient");
                        return;
                    }
                    CrossFadeAmbience(audio_name, volume, startOver, 0.5f, overWriteIfCrossfade);
                }
                current_ambience_name = audio_name;
            }
        }
        public AudioClip PlaySoundEffect(AudioSource targetSource, string clip_name, float volumeScale){
            AudioClip clip = GetSFXClip(clip_name);
            targetSource = (targetSource==null?default_sfx:targetSource);
            if(clip!=null)
                targetSource.PlayOneShot(clip, volumeScale);
            else
                Debug.LogAssertion($"No Clip found:{clip_name}");
            return clip;
        }
        public AudioClip PlaySoundEffectLoop(AudioSource targetSource, string clip_name, float volumeScale, float transition = 1f){
            AudioClip clip = GetSFXClip(clip_name);
            targetSource = targetSource==null?default_sfx:targetSource;
            targetSource.clip = clip;
            targetSource.loop = true;
            targetSource.Play();
            FadeAudio(targetSource, volumeScale, transition);

            return clip;
        }
        public void PlaySoundEffect(AudioSource targetSource, string clip, float volumeScale, float delay, Action completeCallback=null)=>
            StartCoroutine(coroutineDelaySFX(targetSource, clip, volumeScale, delay, completeCallback));
        public void PlaySoundEffect_WithFinishCallback(AudioSource targetSource, string clip, float volumScale, Action finishCallback=null)=>
            StartCoroutine(coroutineSFX_WithFinishAction(targetSource, clip, volumScale, finishCallback));
        public void FadeInAndOutSoundEffect(AudioSource targetSource, string clip, float maxVolume, float duration, float fadeIn, float fadeOut)=>
            StartCoroutine(coroutineFadeInAndOutSFX(targetSource, clip, maxVolume, duration, fadeIn, fadeOut));
        public void FadeRoomTone(AudioSource roomtoneAudio, string clip, float volume, float transition){
            if(clip == string.Empty){
                StartCoroutine(coroutineFadeAudio(roomtoneAudio, 0, transition));
            }
            else{
                AudioClip roomTone = audioInfo.GetAMBClipByName(clip);
                if(roomtoneAudio.clip!=roomTone) roomtoneAudio.clip = roomTone;
                if(!roomtoneAudio.isPlaying){
                    roomtoneAudio.volume = 0;
                    if(volume>0) roomtoneAudio.Play();
                } 
                
                StartCoroutine(coroutineFadeAudio(roomtoneAudio, volume, transition, true));
            }
        }
        AudioClip GetSFXClip(string clipName){
            AudioClip clip;
            if(clipName.Contains("group"))
                clip = audioInfo.GetSFXClipFromGroupByName(clipName);
            else
                clip = audioInfo.GetSFXClipByName(clipName);

            return clip;
        }
    #endregion

    #region Helper function
        public static void SwitchAudioListener(AudioListener from, AudioListener to){
            from.enabled = false;
            to.enabled = true;
        }
        public void FadeAmbience(float targetVolume, float transitionTime, bool StopOnFadeOut = false){
            FadeAudio(ambience_loop, targetVolume, transitionTime, StopOnFadeOut);
        }
        public void FadeMusic(float targetVolume, float transitionTime, bool StopOnFadeOut = false){
            FadeAudio(music_loop, targetVolume, transitionTime, StopOnFadeOut);
        }
        public void FadeAudio(AudioSource m_audio, float targetVolume, float transitionTime, bool StopOnFadeOut = false){
            StartCoroutine(coroutineFadeAudio(m_audio, targetVolume, transitionTime, StopOnFadeOut));
        }
        public void ChangeMasterVolume(float targetVolume){
            mainMixer.SetFloat(masterVolumeName, targetVolume);
        }
        void CrossFadeAmbience(string audio_name, float targetVolume, bool startOver, float transitionTime, bool overwriteAmbience = false){
            if(!overwriteAmbience && ambience_crossfading) return;
            if(ambFader==null) ambFader = new CoroutineExcuter(this);
            ambFader.Excute(coroutineCrossFadeAmbience(current_ambience_name, audio_name, targetVolume, startOver, transitionTime));
        }
        void CrossFadeMusic(string audio_name, float targetVolume, bool startOver, float transitionTime, bool overwriteMusic = false){
            if(!overwriteMusic && music_crossfading) return;
            if(musFader==null) musFader = new CoroutineExcuter(this);
            musFader.Excute(coroutineCrossFadeMusic(current_music_name, audio_name, targetVolume, startOver, transitionTime));
        }
    #endregion
        IEnumerator coroutineFadeInAndOutSFX(AudioSource m_audio, string clip, float maxVolume, float duration, float fadeIn, float fadeOut){
            AudioSource tempAudio = Instantiate(m_audio);
            tempAudio.name = "_TempSFX";
            tempAudio.volume = 0;
            tempAudio.loop   = true;
            tempAudio.clip   = GetSFXClip(clip);
            tempAudio.Play();

            yield return new WaitForLoop(fadeIn, (t)=>tempAudio.volume = Mathf.Lerp(0, maxVolume, t));
            yield return new WaitForSeconds(duration);
            yield return new WaitForLoop(fadeOut, (t)=>tempAudio.volume = Mathf.Lerp(maxVolume, 0, t));

            Destroy(tempAudio.gameObject);
        }
        IEnumerator coroutineDelaySFX(AudioSource m_audio, string clip, float volumeScale, float delay, Action completeCallback){
            yield return new WaitForSeconds(delay);
            PlaySoundEffect(m_audio, clip, volumeScale);
            completeCallback?.Invoke();
        }
        IEnumerator coroutineSFX_WithFinishAction(AudioSource m_audio, string clip, float volumeScale, Action finishCallback){
            var playedClip = PlaySoundEffect(m_audio, clip, volumeScale);
            yield return new WaitForSeconds(playedClip==null?0:playedClip.length);
            finishCallback?.Invoke();
        }
        IEnumerator coroutineFadeAudio(AudioSource m_audio, float targetVolume, float transitionTime, bool StopOnFadeOut){
            float initVolume = m_audio.volume;
            yield return new WaitForLoop(transitionTime, (t)=>{
                m_audio.volume = Mathf.Lerp(initVolume, targetVolume, t);
            });

            if(StopOnFadeOut && m_audio.volume == 0) m_audio.Stop();
        }
        IEnumerator coroutineCrossFadeAmbience(string from_clip, string to_clip, float targetVolume, bool startOver, float transitionTime){
            ambience_crossfading = true;
            if(from_clip!=string.Empty){
                StartCoroutine(coroutineFadeAudio(ambience_loop, 0, transitionTime));
            }

            AudioSource tempAudio = new GameObject("[_TempAmbience]").AddComponent<AudioSource>();
            tempAudio.volume = 0;
            tempAudio.loop   = true;
            tempAudio.clip   = audioInfo.GetAMBClipByName(to_clip);
            if(!startOver) tempAudio.time   = ambience_loop.time;
            tempAudio.outputAudioMixerGroup = ambience_loop.outputAudioMixerGroup;
            tempAudio.Play();
            yield return coroutineFadeAudio(tempAudio, targetVolume, transitionTime);

            ambience_loop.clip = tempAudio.clip;
            ambience_loop.time = tempAudio.time;
            ambience_loop.volume = tempAudio.volume;
            current_ambience_name = to_clip;
            ambience_loop.Play();
            
            Destroy(tempAudio.gameObject);

            ambience_crossfading = false;
        }
        IEnumerator coroutineCrossFadeMusic(string from_clip, string to_clip, float targetVolume, bool startOver, float transitionTime){
            music_crossfading = true;
            if(from_clip!=string.Empty){
                StartCoroutine(coroutineFadeAudio(music_loop, 0, transitionTime));
            }

            AudioSource tempAudio = new GameObject("[_TempMusic]").AddComponent<AudioSource>();
            tempAudio.volume = 0;
            tempAudio.loop   = true;
            tempAudio.clip   = audioInfo.GetBGMClipByName(to_clip);
            if(!startOver) tempAudio.time   = music_loop.time;
            tempAudio.outputAudioMixerGroup = music_loop.outputAudioMixerGroup;
            tempAudio.Play();
            yield return coroutineFadeAudio(tempAudio, targetVolume, transitionTime);

            music_loop.clip = tempAudio.clip;
            music_loop.time = tempAudio.time;
            music_loop.volume = tempAudio.volume;
            current_music_name = to_clip;
            music_loop.Play();
            
            Destroy(tempAudio.gameObject);

            music_crossfading = false;
        }
        IEnumerator coroutineFadeAudio(AudioSource source, float targetVolume, float transition){
            float initVolume = source.volume;
            yield return new WaitForLoop(transition, (t)=>{
                source.volume = Mathf.Lerp(initVolume, targetVolume, t);
            });
            yield return null;
        }
    }
}
