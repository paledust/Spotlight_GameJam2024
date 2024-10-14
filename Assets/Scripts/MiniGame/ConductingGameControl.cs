using System.Collections;
using System.Collections.Generic;
using Unity.Burst.Intrinsics;
using UnityEngine;
using UnityEngine.Playables;

public class ConductingGameControl : MonoBehaviour
{
    public enum ConductingState{Pending, Detecting, Result}
[Header("Day Night")]
    [SerializeField] private PlayableDirector timeOfDayDirector;
    [SerializeField] private float switchTimeAmount = 2;
[Header("Conducting Object")]
    [SerializeField] private GameObject waitingObject;
[Header("Ref Position")]
    [SerializeField] private float waitingDistance;
    [SerializeField] private float lineUpdateTime;
    [SerializeField] private float objectEnterTime;
    [SerializeField] private Transform entrencePos;
    [SerializeField] private Transform waitingPos;
    [SerializeField] private Transform stopPos;
    [SerializeField] private Transform leftExit;
    [SerializeField] private Transform rightExit;
[Header("Direction Sign")]
    [SerializeField] private SpriteRenderer signRenderer;
    [SerializeField] private Sprite stopSign;
    [SerializeField] private Sprite directionSign;
    [SerializeField] private Sprite FailSign;
    [SerializeField] private Sprite goodSign;
[Header("Tempo")]
    [SerializeField] private float beatRate = 90;
    [SerializeField] private int detectionWindow = 4;
    [SerializeField] private int pendingWindow = 4;
    [SerializeField] private int resultWindow = 2;
[Header("States")]
    [SerializeField] ConductingState conductingState;

    private float timer = 0;
    private int requireDir = 0;
    private int receivedDirection = 0;
    private int totalBeats = 0;
    private int finishedAmount = 0;
    private int stateCounter = 0;
    private bool isDay = true;
    private CoroutineExcuter spriteBeater;
    private CoroutineExcuter timeChanger;
    [SerializeField] private List<GameObject> objectsInLine;

    void OnEnable(){
        EventHandler.E_OnRiseHand += RiseHandHandler;
    }
    void OnDisable(){
        EventHandler.E_OnRiseHand -= RiseHandHandler;
    }
    void Start(){
        spriteBeater = new CoroutineExcuter(this);
        timeChanger  = new CoroutineExcuter(this);
        signRenderer.sprite = stopSign;
        conductingState = ConductingState.Pending;

        timeOfDayDirector.Play();
    }
    void Update()
    {
        timer += Time.deltaTime;
        if(timer >= 60f/beatRate){
            timer = 0;
            totalBeats ++;
            stateCounter ++;

            switch(conductingState){
                case ConductingState.Pending:
                    if(stateCounter >= pendingWindow){
                        stateCounter = 0;

                        conductingState = ConductingState.Detecting;
                        requireDir = (Random.Range(0f, 1f)-0.5f>0)?1:-1;
                        signRenderer.color = Color.gray;
                        signRenderer.sprite = directionSign;
                        signRenderer.flipX = requireDir<0;
                        spriteBeater.Excute(coroutineBeatSprite(0.05f));
                    }
                    else{
                        spriteBeater.Excute(coroutineBeatSprite(0.4f));
                    }
                    break;
                case ConductingState.Detecting:
                    if(stateCounter >= detectionWindow){
                        stateCounter = 0;

                        if(receivedDirection == requireDir){
                            finishedAmount ++;
                            UpdateLines();
                            if(finishedAmount >= switchTimeAmount){
                                finishedAmount = 0;
                                timeChanger.Excute(coroutineDayNightCycle(3f));
                            }

                            signRenderer.sprite = goodSign;
                        }
                        else
                            signRenderer.sprite = FailSign;
                        signRenderer.color = Color.white;
                        conductingState = ConductingState.Result;
                        signRenderer.flipX = false;
                        spriteBeater.Excute(coroutineBeatSprite(0.1f));
                    }
                    else{
                        if(receivedDirection==requireDir){
                            spriteBeater.Excute(coroutineBeatSprite(0.2f));
                        }
                        else{
                            spriteBeater.Excute(coroutineBeatSprite(0.05f));
                        }
                    }
                    break;
                case ConductingState.Result:
                    if(stateCounter >= resultWindow){
                        stateCounter = 1;

                        signRenderer.sprite = stopSign;
                        conductingState = ConductingState.Pending;
                        spriteBeater.Excute(coroutineBeatSprite(0.4f));
                    }
                    break;
            }
        }

        if(conductingState==ConductingState.Detecting){
            if(receivedDirection==requireDir){
                signRenderer.color = Color.green;
            }
            else{
                signRenderer.color = Color.gray;
            }
        }
    }
//更新整个待指挥队列
    void UpdateLines(){
        StartCoroutine(coroutineSendObjectToExit(waitingObject, receivedDirection));
        waitingObject = null;

        var enteredObject = objectsInLine[0];
        StartCoroutine(coroutineSendObjectToConducting(enteredObject));
        objectsInLine.RemoveAt(0);
        if(objectsInLine.Count>0){
            for(int i=0; i<objectsInLine.Count; i++){
                if(i==0)
                    StartCoroutine(coroutineSendObjectToEntrence(objectsInLine[0]));
                else
                    StartCoroutine(coroutineSendObjectToPosition(objectsInLine[i], waitingPos.position+Vector3.left*i*waitingDistance, lineUpdateTime));
            }
        }
    }
    void RiseHandHandler(int direction){
        receivedDirection += direction;
    }
    IEnumerator coroutineSendObjectToExit(GameObject waitingObject, int direction){
        Transform exitTrans = direction>0?rightExit:leftExit;

        Quaternion initRot = waitingObject.transform.rotation;
        Quaternion targetRot = Quaternion.Euler(0, -direction*90, 0)*initRot;
        yield return new WaitForLoop(0.25f, (t)=>{
            waitingObject.transform.rotation = Quaternion.Lerp(initRot, targetRot, EasingFunc.Easing.SmoothInOut(t));
        });
        
        yield return coroutineSendObjectToPosition(waitingObject, exitTrans.position, 1.5f);
    }
    IEnumerator coroutineSendObjectToConducting(GameObject enteredObject){
        yield return coroutineSendObjectToPosition(enteredObject, stopPos.position, objectEnterTime);
        waitingObject = enteredObject;
    }
    IEnumerator coroutineSendObjectToEntrence(GameObject pendingObject){
        yield return coroutineSendObjectToPosition(pendingObject, entrencePos.position, lineUpdateTime);
        Quaternion initRot = pendingObject.transform.rotation;
        Quaternion targetRot = Quaternion.Euler(0, 90, 0)*initRot;
        yield return new WaitForLoop(lineUpdateTime*0.25f, (t)=>{
            pendingObject.transform.rotation = Quaternion.Lerp(initRot, targetRot, EasingFunc.Easing.SmoothInOut(t));
        });
    }
    IEnumerator coroutineSendObjectToPosition(GameObject target, Vector3 targetPos, float duration){
        Vector3 initPos = target.transform.position;
        yield return new WaitForLoop(duration, (t)=>{
            target.transform.position = Vector3.Lerp(initPos, targetPos, EasingFunc.Easing.SmoothInOut(t));
        });
    }
    IEnumerator coroutineDayNightCycle(float cycleDuration){
        isDay = !isDay;
        float currentTime = (float)timeOfDayDirector.time;
        yield return new WaitForLoop(cycleDuration, (t)=>{
            timeOfDayDirector.time = Mathf.Lerp(currentTime, (isDay?1f:0.5f) * (float)timeOfDayDirector.duration, t);
            timeOfDayDirector.Evaluate();
        });
        if(isDay) timeOfDayDirector.time = 0;
    }
    IEnumerator coroutineBeatSprite(float beatScale = 0.5f){
        float duration = 60f/beatRate;

        yield return new WaitForLoop(duration, (t)=>{
            signRenderer.transform.localScale = Vector3.one *(1+beatScale*EasingFunc.Easing.pcurve(t, 0.5f, 5f));
        });
    }
}
