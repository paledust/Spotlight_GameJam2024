using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransitionManager : MonoBehaviour
{
    [SerializeField] private Color transitionColor;
    public void TL_Event_LoadNextLevel(){
        GameManager.Instance.SwitchingScene("OceanTunnle", 1.5f,transitionColor);
    }
}
