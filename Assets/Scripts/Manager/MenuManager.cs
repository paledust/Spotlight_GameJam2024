using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MenuManager : MonoBehaviour
{
    public void ButtonEvent_StartGame(){
        GameManager.Instance.SwitchingScene("WorkingRichard");
    }
    public void ButtonEvent_EndGame(){
        GameManager.Instance.EndGame();
    }
}
