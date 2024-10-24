using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class RichardFallingManager : MonoBehaviour
{
    [SerializeField] private PlaneControl_Platform planeControl_Platform;
    [SerializeField] private CinemachineVirtualCamera horizontalCam;
    [SerializeField] private CinemachineVirtualCameraBase completeTrackingCam;
    [SerializeField] private GameObject BottomTrigger;
    void Awake(){
        EventHandler.E_OnStartToFall += StartFallingHandler;
    }
    void OnDestroy(){
        EventHandler.E_OnStartToFall -= StartFallingHandler;
    }
    void StartFallingHandler(){
        BottomTrigger.SetActive(false);
        completeTrackingCam.Priority = 10;
        completeTrackingCam.enabled = true;
        horizontalCam.Priority = 9;
        horizontalCam.enabled = false;
    }
}
