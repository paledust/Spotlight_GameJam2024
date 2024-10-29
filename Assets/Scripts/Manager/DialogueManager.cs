using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class DialogueManager : Singleton<DialogueManager>
{
    [SerializeField] private string micClip;
    [SerializeField] private DialogueData_SO dialogueDataSO;

    public void PlayDialogue(string key){
        var data = dialogueDataSO.GetDataFromDialogueKey(key);
        if(data.isCom){
            AudioManager.Instance.PlayRecording(micClip, 1);
            AudioManager.Instance.PlayRecording(data.recordClip, 1);
        }
    }
}
