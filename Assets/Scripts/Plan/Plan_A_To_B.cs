using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plan_A_To_B : MonoBehaviour
{
    [SerializeField] private Color transitionColor;
    [SerializeField] private GameObject mountainAreaObj;
    [SerializeField] private GameObject iceAreaObj;
    void Start(){
        iceAreaObj.SetActive(false);
    }
    void OnEnable(){
        EventHandler.E_OnReachExit += OnReachExit;
    }
    void OnDisable(){
        EventHandler.E_OnReachExit -= OnReachExit;
    }
    void OnReachExit(){
        GameManager.Instance.SwitchingScene(Service.FLYING_TWO, 1f, transitionColor);
    }
    void OnReachIceLayer(){
        mountainAreaObj.SetActive(false);
        iceAreaObj.SetActive(true);
    }
}
