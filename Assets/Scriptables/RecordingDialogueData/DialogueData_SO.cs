using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "CustomScriptable/DialgoueData_SO")]
public class DialogueData_SO : ScriptableObject
{
    [SerializeField] private List<DialogueData> dialogueDatas;
    public DialogueData GetDataFromDialogueKey(string key){
        return dialogueDatas.Find(x=>x.dialogueKey == key);
    }
}
[System.Serializable]
public class DialogueData{
    public string dialogueKey;
    public string recordClip;
    public bool isCom;
}
