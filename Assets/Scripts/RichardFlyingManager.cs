using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using Cinemachine.Utility;
using UnityEngine;
using UnityEngine.Rendering;

public class RichardFlyingManager : Singleton<RichardFlyingManager>
{
    [SerializeField] private GameObject FlyingPrefab;
    [SerializeField] private GameObject SafeZoneProbePrefab;
    [SerializeField] private Transform defaultSpawn;
[Header("VFX")]
    [SerializeField] private Volume stopZonePP;
    [SerializeField] private ParticleSystem p_explode;
[Header("Safe Condition")]
    [SerializeField] private float minimumDist = 5;
    [SerializeField] private float minimumWidthDist = 20;
    [SerializeField] private float minimumHeightDist = 30;
    [SerializeField] private float minimumForwardDist = 40;

    private PlaneControl_Free planeOnAir;
    private SafeZoneProbe safeZoneProbe;
    private Vector3[] safePoses = new Vector3[MAX_SAFE_POINTS];
    private Quaternion[] safeRots = new Quaternion[MAX_SAFE_POINTS];
    private int safePointIndex = 0;
    private bool isInStopZone = false;
    private CoroutineExcuter ppFader;

    private const int MAX_SAFE_POINTS = 3;

    protected override void Awake(){
        ppFader = new CoroutineExcuter(this);

        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos += OnReportPosHandler;
        EventHandler.E_OnInteractingStopZone += OnInteractStopZoneHandler;
    }
    protected override void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos -= OnReportPosHandler;
        EventHandler.E_OnInteractingStopZone -= OnInteractStopZoneHandler;
    }
    void Start(){
        for(int i=0; i<safePoses.Length; i++){
            safePoses[i] = defaultSpawn.position;
            safeRots[i] = defaultSpawn.rotation;
        }

        planeOnAir = FindObjectOfType<PlaneControl_Free>();

        safeZoneProbe = Instantiate(SafeZoneProbePrefab).GetComponent<SafeZoneProbe>();
        safeZoneProbe.transform.parent = planeOnAir.transform;
        safeZoneProbe.transform.localPosition = Vector3.zero;
        safeZoneProbe.transform.localRotation = Quaternion.identity;
    }
#region Event Handlers
    void OnInteractStopZoneHandler(bool isInZone){
        isInStopZone = isInZone;
        ppFader.Excute(coroutineFadePP(isInZone?1:0, 1f));
    }
    void OnPlaneCrashedHandler(Vector3 crashPos){
            p_explode.transform.position = crashPos;
            p_explode.Play(true);
            
        StartCoroutine(CommonCoroutine.delayAction(()=>{
            Vector3 lastSafePos;
            Quaternion lastSafeRot;
            ReadSafePoint(crashPos, out lastSafePos, out lastSafeRot);

            safeZoneProbe.transform.parent = null;

            Destroy(planeOnAir.gameObject);
            
            planeOnAir = Instantiate(FlyingPrefab).GetComponent<PlaneControl_Free>();
            Vector3 safeDir = lastSafeRot * Vector3.forward;
            safeDir = Vector3.ProjectOnPlane(safeDir, Vector3.up);

            planeOnAir.transform.position = lastSafePos;
            planeOnAir.transform.rotation = Quaternion.LookRotation(safeDir);

            safeZoneProbe.transform.parent = planeOnAir.transform;
            safeZoneProbe.transform.localPosition = Vector3.zero;
            safeZoneProbe.transform.localRotation = Quaternion.identity;
        }, 2f));
    }
    void OnReportPosHandler(Vector3 position, Quaternion rotation, Vector3[] threatDirections){
    //当飞机处于禁止区域时，不要更新飞行点
        if(isInStopZone) return;
    //更新飞行记录点
        Vector3 goingDir = transform.forward.ProjectOntoPlane(Vector3.up).normalized;

        if(threatDirections==null || threatDirections.Length == 0) {
            AddSafePoint(position, rotation);
        }
        else{
            bool flag = true;
            for(int i=0; i<threatDirections.Length; i++){
                Vector3 highPlane = Vector3.ProjectOnPlane(threatDirections[i], goingDir);

                if(Mathf.Abs(highPlane.y)<=minimumHeightDist){
                    flag = false;
                    break;
                }
                if(Mathf.Abs(highPlane.x)<=minimumWidthDist){
                    flag = false;
                    break;
                }

                var goingProject = Vector3.Dot(goingDir, threatDirections[i]);
                if(goingProject>0 && goingProject<=minimumForwardDist){
                    flag = false;
                    break;
                }

                if(threatDirections[i].magnitude<=minimumDist) {
                    flag = false;
                    break;
                }
            }
            if(flag){
                AddSafePoint(position, rotation);
            }
        }
    }
#endregion
    void AddSafePoint(Vector3 pos, Quaternion rot){
        safePointIndex ++;
        safePointIndex %= MAX_SAFE_POINTS;

        safePoses[safePointIndex] = pos;
        safeRots[safePointIndex] = rot;
    }
    void ReadSafePoint(Vector3 refPos, out Vector3 safePos, out Quaternion safeRot){
        int targetIndex = safePointIndex;
        float distance = 0;
        for(int i=0; i<MAX_SAFE_POINTS; i++){
            float temp = Vector3.SqrMagnitude(refPos-safePoses[i]);
            if(temp>distance){
                distance = temp;
                targetIndex = i;
            }
        }
        safePos = safePoses[targetIndex];
        safeRot = safeRots[safePointIndex];
    }
    IEnumerator coroutineFadePP(float targetWeight, float duration){
        float initValue = stopZonePP.weight;
        yield return new WaitForLoop(duration, (t)=>{
            stopZonePP.weight = Mathf.Lerp(initValue, targetWeight, EasingFunc.Easing.SmoothInOut(t));
        });
    }
}