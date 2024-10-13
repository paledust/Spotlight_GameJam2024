using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class ConductingGameControl : MonoBehaviour
{
    public enum ConductingState{Pending, Detecting, Result}
[Header("Day Night")]
    [SerializeField] private PlayableDirector timeOfDayDirector;
[Header("Ref Position")]
    [SerializeField] private Transform entrencePos;
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
    [SerializeField] private int stateCounter = 0;
    private CoroutineExcuter spriteBeater;

    void OnEnable(){
        EventHandler.E_OnRiseHand += RiseHandHandler;
    }
    void OnDisable(){
        EventHandler.E_OnRiseHand -= RiseHandHandler;
    }
    void Start(){
        spriteBeater = new CoroutineExcuter(this);
        signRenderer.sprite = stopSign;
        conductingState = ConductingState.Pending;
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

                        if(receivedDirection == requireDir)
                            signRenderer.sprite = goodSign;
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

    void RiseHandHandler(int direction){
        receivedDirection += direction;
    }
    IEnumerator coroutineBeatSprite(float beatScale = 0.5f){
        float duration = 60f/beatRate;

        yield return new WaitForLoop(duration, (t)=>{
            signRenderer.transform.localScale = Vector3.one *(1+beatScale*EasingFunc.Easing.pcurve(t, 0.5f, 5f));
        });
    }
}
