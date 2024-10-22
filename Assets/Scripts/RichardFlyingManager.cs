using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class RichardFlyingManager : Singleton<RichardFlyingManager>
{
    [SerializeField] private GameObject FlyingPrefab;
    [SerializeField] private Transform defaultSpawn;
    [SerializeField] private GameObject safeZoneProbe;
    private Vector3 lastSafePos;
    private Quaternion lastSafeDir;
    private PlaneControl_Free planeOnAir;
    protected override void Awake(){
        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
    }
    protected override void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
    }
    void Start(){
        lastSafePos = defaultSpawn.position;
        planeOnAir = FindObjectOfType<PlaneControl_Free>();
    }
    void Update(){
    }
    void OnPlaneCrashedHandler(){
        StartCoroutine(CommonCoroutine.delayAction(()=>{
            
        }, 3f));
    }
    void OnReportPosHandler(Vector3 position, Quaternion rotation, Vector3[] threatDirections){
        if(threatDirections.Length == 0) {
            lastSafePos = position;
            lastSafeDir = rotation;
        }
    }
}
