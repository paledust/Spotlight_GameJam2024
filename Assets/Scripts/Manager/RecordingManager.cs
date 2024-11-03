using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class RecordingManager : Singleton<RecordingManager>
{
    [SerializeField] private string micClip;
    [SerializeField] private RecordingData_SO dialogueDataSO;
    private const float MIC_LENGTH = 0.01f;
    public void PlayRecording(string key, float volume = 1){
        var data = dialogueDataSO.GetDataFromDialogueKey(key);
        if(data.isCom){
            AudioManager.Instance.PlayRecording(micClip, volume);
            AudioManager.Instance.PlayRecording(data.clipKey, volume);
        }
    }
    public void StopCurrentRecording(bool stopImmediately){
        if(stopImmediately) {
            AudioManager.Instance.StopRecording();
            return;
        }
        AudioManager.Instance.PlayRecording(micClip, 1);
        StartCoroutine(CommonCoroutine.delayAction(()=>AudioManager.Instance.StopRecording(), MIC_LENGTH));
    }
}