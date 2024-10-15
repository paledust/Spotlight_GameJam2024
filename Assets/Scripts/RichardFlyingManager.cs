using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class RichardFlyingManager : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera flyingCam;
    void Awake(){
        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
    }
    void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
    }
    void OnPlaneCrashedHandler(){
        flyingCam.m_Follow = null;
        flyingCam.m_LookAt = null;
    }
}
