using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class RecordingManager : Singleton<RecordingManager>
{
    [SerializeField] private string micClip;
    [SerializeField] private RecordingData_SO dialogueDataSO;

    public void PlayRecording(string key, float volume = 1){
        var data = dialogueDataSO.GetDataFromDialogueKey(key);
        if(data.isCom){
            AudioManager.Instance.PlayRecording(micClip, volume);
            AudioManager.Instance.PlayRecording(data.clipKey, volume);
        }
    }
}
