using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class RichardFlyingManager : Singleton<RichardFlyingManager>
{
    [SerializeField] private GameObject FlyingPrefab;
    [SerializeField] private GameObject SafeZoneProbePrefab;
    [SerializeField] private Transform defaultSpawn;
    private Vector3 lastSafePos;
    private Quaternion lastSafeRot;
    private PlaneControl_Free planeOnAir;
    private SafeZoneProbe safeZoneProbe;
    protected override void Awake(){
        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos += OnReportPosHandler;
    }
    protected override void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos -= OnReportPosHandler;
    }
    void Start(){
        lastSafePos = defaultSpawn.position;
        lastSafeRot = defaultSpawn.rotation;
        planeOnAir = FindObjectOfType<PlaneControl_Free>();

        safeZoneProbe = Instantiate(SafeZoneProbePrefab).GetComponent<SafeZoneProbe>();
        safeZoneProbe.transform.parent = planeOnAir.transform;
        safeZoneProbe.transform.localPosition = Vector3.zero;
        safeZoneProbe.transform.localRotation = Quaternion.identity;
    }
    void OnPlaneCrashedHandler(){
        StartCoroutine(CommonCoroutine.delayAction(()=>{
            Destroy(planeOnAir.gameObject);
            planeOnAir = Instantiate(FlyingPrefab).GetComponent<PlaneControl_Free>();
            Vector3 safeDir = lastSafeRot * Vector3.forward;
            safeDir = Vector3.ProjectOnPlane(safeDir, Vector3.up);

            planeOnAir.transform.position = lastSafePos;
            planeOnAir.transform.rotation = Quaternion.LookRotation(safeDir);
        }, 3f));
    }
    void OnReportPosHandler(Vector3 position, Quaternion rotation, Vector3[] threatDirections){
        Vector3 goingDir = transform.forward;
        if(threatDirections==null || threatDirections.Length == 0) {
            lastSafePos = position;
            lastSafeRot = rotation;
        }
        else{
            
        }
    }
}