using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using Cinemachine.Utility;
using SimpleAudioSystem;
using UnityEngine;
using UnityEngine.Rendering;

public class RichardFlyingManager : MonoBehaviour
{
    [SerializeField] private GameObject FlyingPrefab;
    [SerializeField] private GameObject SafeZoneProbePrefab;
    [SerializeField] private Transform spawnPoint;
[Header("VFX")]
    [SerializeField] private Volume stopZonePP;
[Header("Safe Condition")]
    [SerializeField] private float minimumDist = 5;
    [SerializeField] private float minimumWidthDist = 20;
    [SerializeField] private float minimumHeightDist = 30;
    [SerializeField] private float minimumForwardDist = 40;
[Header("Fly Path")]
    [SerializeField] private bool alignDirectionToPath = false;
    [SerializeField] private CinemachinePathBase m_flightPath;

    private PlaneControl_Free planeOnAir;
    private SafeZoneProbe safeZoneProbe;
    private Vector3[] safePoses = new Vector3[MAX_SAFE_POINTS];
    private Quaternion[] safeRots = new Quaternion[MAX_SAFE_POINTS];
    private int safePointIndex = 0;
    private int stopZoneCounter = 0;
    private CoroutineExcuter ppFader;

    private const int MAX_SAFE_POINTS = 3;

    public bool isInStopZone{get{return stopZoneCounter>0;}}

    protected void Awake(){
        ppFader = new CoroutineExcuter(this);

        EventHandler.E_OnPlaneCrashed += OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos += OnReportPosHandler;
        EventHandler.E_OnInteractingStopZone += OnInteractStopZoneHandler;
    }
    protected void OnDestroy(){
        EventHandler.E_OnPlaneCrashed -= OnPlaneCrashedHandler;
        EventHandler.E_OnReportPos -= OnReportPosHandler;
        EventHandler.E_OnInteractingStopZone -= OnInteractStopZoneHandler;
    }
    void Start(){
        planeOnAir = FindObjectOfType<PlaneControl_Free>();
        planeOnAir.transform.position = spawnPoint.position;
        planeOnAir.transform.rotation = spawnPoint.rotation;
        ResetSpwanPos(spawnPoint);

        safeZoneProbe = Instantiate(SafeZoneProbePrefab).GetComponent<SafeZoneProbe>();
        safeZoneProbe.transform.parent = planeOnAir.transform;
        safeZoneProbe.transform.localPosition = Vector3.zero;
        safeZoneProbe.transform.localRotation = Quaternion.identity;

        AudioManager.Instance.ChangeEngineHearing(true);
    }
#region Event Handlers
    void OnInteractStopZoneHandler(bool isInZone){
        stopZoneCounter += isInZone?1:-1;
        ppFader.Excute(coroutineFadePP(isInStopZone?1:0, 1f));
        planeOnAir.SwitchBumpyFly(isInStopZone);
    }
    void OnPlaneCrashedHandler(Vector3 crashPos){
        AudioManager.Instance.ChangeEngineHearing(false);
        AudioManager.Instance.PlaySoundEffect(null, "sfx_crash", 1f);
        StartCoroutine(CommonCoroutine.delayAction(()=>{
            Vector3 lastSafePos;
            Quaternion lastSafeRot;
            ReadSafePoint(crashPos, out lastSafePos, out lastSafeRot);

            safeZoneProbe.transform.parent = null;

            Destroy(planeOnAir.gameObject);
            
            planeOnAir = Instantiate(FlyingPrefab).GetComponent<PlaneControl_Free>();


            if(alignDirectionToPath){
                float point = m_flightPath.FindClosestPoint(crashPos, 0, -1, 10);
                lastSafePos = m_flightPath.EvaluatePosition(Mathf.Clamp01(point-0.3f));
                lastSafeRot = Quaternion.LookRotation(m_flightPath.EvaluateTangent(point));
            }
            else{
                Vector3 safeDir = lastSafeRot * Vector3.forward;
                safeDir = Vector3.ProjectOnPlane(safeDir, Vector3.up);
                lastSafeRot = Quaternion.LookRotation(safeDir);
            }

            planeOnAir.transform.position = lastSafePos;
            planeOnAir.transform.rotation = lastSafeRot;

            safeZoneProbe.transform.parent = planeOnAir.transform;
            safeZoneProbe.transform.localPosition = Vector3.zero;
            safeZoneProbe.transform.localRotation = Quaternion.identity;

            AudioManager.Instance.ChangeEngineHearing(true);
        }, 2f));
    }
    void OnReportPosHandler(Vector3 position, Quaternion rotation, Vector3[] threatDirections){
    //当飞机处于禁止区域时，不要更新飞行点
        if(isInStopZone) return;
    //更新飞行记录点
        Vector3 goingDir = transform.forward.ProjectOntoPlane(Vector3.up).normalized;

        if(threatDirections==null || threatDirections.Length == 0) {
            AddSafePoint(position, rotation);
            return;
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
                return;
            }
        }
    }
#endregion
    public void ResetSpwanPos(Transform spawnTrans){
        safePointIndex = 0;
        for(int i=0; i<safePoses.Length; i++){
            safePoses[i] = spawnTrans.position;
            safeRots[i] = spawnTrans.rotation;
        }
    }
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