using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class RichardFlyingManager : Singleton<RichardFlyingManager>
{
    [SerializeField] private GameObject FlyingPrefab;
    protected override void Awake(){
        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
    }
    protected override void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
    }
    void OnPlaneCrashedHandler(){
    }
}
