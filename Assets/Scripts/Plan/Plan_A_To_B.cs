using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plan_A_To_B : MonoBehaviour
{
    [SerializeField] private Color transitionColor;
    [SerializeField] private GameObject mountainAreaObj;
    [SerializeField] private GameObject iceAreaObj;
    [SerializeField] private RichardFlyingManager flyingManager;
    [SerializeField] private Transform spawnPosIce;
[Header("Recording")]
    [SerializeField] private string firstComClip;
    void Start(){
        iceAreaObj.SetActive(false);
    }
    void OnEnable(){
        EventHandler.E_OnReachExit += OnReachExit;
        EventHandler.E_OnEnterIceLayer += OnReachIceLayer;
    }
    void OnDisable(){
        EventHandler.E_OnReachExit -= OnReachExit;
        EventHandler.E_OnEnterIceLayer -= OnReachIceLayer;
    }
    void OnReachExit(){
        GameManager.Instance.SwitchingScene(Service.FLYING_TWO, 1f, transitionColor);
    }
    void OnReachIceLayer(){
        mountainAreaObj.SetActive(false);
        iceAreaObj.SetActive(true);

        if(spawnPosIce!=null) flyingManager.ResetSpwanPos(spawnPosIce);
    }
    public void TL_PlayRecording(){
        StartCoroutine(CommonCoroutine.delayAction(()=>RecordingManager.Instance.PlayRecording(firstComClip), 5f));
    }
}
