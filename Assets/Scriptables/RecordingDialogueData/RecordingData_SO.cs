using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "CustomScriptable/RecordingData_SO")]
public class RecordingData_SO : ScriptableObject
{
    [SerializeField] private List<RecordingData> dialogueDatas;
    public RecordingData GetDataFromDialogueKey(string key){
        return dialogueDatas.Find(x=>x.clipKey == key);
    }
}
[System.Serializable]
public class RecordingData{
    public string clipKey;
    public bool isCom;
}
