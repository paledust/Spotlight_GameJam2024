using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using SimpleAudioSystem;
using UnityEngine;

public class RichardFallingManager : MonoBehaviour
{
    [SerializeField] private PlaneControl_Platform planeControl_Platform;
    [SerializeField] private CinemachineVirtualCamera horizontalCam;
    [SerializeField] private CinemachineVirtualCameraBase completeTrackingCam;
    [SerializeField] private GameObject BottomTrigger;
[Header("Audio")]
    [SerializeField] private AudioSource m_warningAudio;
    [SerializeField] private string flipClip;
    [SerializeField] private string pullUpClip;
    [SerializeField] private string flipCompleteClip;

    void Awake(){
        EventHandler.E_OnStartToFall += StartFallingHandler;
        EventHandler.E_OnFlipComplete += FlipCompleteHandler;
    }
    void OnDestroy(){
        EventHandler.E_OnStartToFall -= StartFallingHandler;
        EventHandler.E_OnFlipComplete -= FlipCompleteHandler;
    }
    void Start(){
        RecordingManager.Instance.StopCurrentRecording();
    }
    public void TL_PlayFlipClip(){
        RecordingManager.Instance.PlayRecording(flipClip);
    }
    public void PlayPullUpWarning(){
        AudioManager.Instance.PlaySoundEffectLoop(m_warningAudio, pullUpClip, 1, 0.1f);
    }
    void FlipCompleteHandler(){
        RecordingManager.Instance.StopCurrentRecording(true);
        RecordingManager.Instance.PlayRecording(flipCompleteClip);
    }
    void StartFallingHandler(){
        BottomTrigger.SetActive(false);
        completeTrackingCam.Priority = 10;
        completeTrackingCam.enabled = true;
        horizontalCam.Priority = 9;
        horizontalCam.enabled = false;
    }
}
