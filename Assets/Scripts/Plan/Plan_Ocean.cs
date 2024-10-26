using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plan_Ocean : MonoBehaviour
{
    [SerializeField] private Color transitionColor;
    [SerializeField] private float transitionTime = 1;
    void OnEnable(){
        EventHandler.E_OnReachExit += OnReachExit;
    }
    void OnDisable(){
        EventHandler.E_OnReachExit -= OnReachExit;
    }
    void OnReachExit(){
        GameManager.Instance.SwitchingScene(Service.END, transitionTime, transitionColor);
    }
}
