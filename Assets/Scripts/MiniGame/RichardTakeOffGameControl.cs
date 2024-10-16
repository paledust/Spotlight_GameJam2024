using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RichardTakeOffGameControl : MonoBehaviour
{
[Header("Text Control")]
    [SerializeField] private FloatingMotionGroup leftMotionGroup;
    [SerializeField] private Animation leftAnime;
    [SerializeField] private ParticleSystem p_leftBurst;
    [SerializeField] private FloatingMotionGroup rightMotionGroup;
    [SerializeField] private Animation rightAnime;
    [SerializeField] private ParticleSystem p_rightBurst;
[Header("Forward Interaction")]
    [SerializeField, Range(0, 1)] private float powerValue;
    [SerializeField] private float powerUpSpeed = 0.5f;
[Header("Finish Animation")]
    [SerializeField] private Animation dissolveControlAnimation;
    [SerializeField] private Transform powerTransform;
    [SerializeField] private float pushDistance;

    private bool leftIsDone = false;
    private bool rightIsDone = false;

    private CoroutineExcuter leftProgresser;
    private CoroutineExcuter rightProgresser;
    private Vector3 initPowerPos;
    private const string DissolveMapName = "DissolveInMap";
    private const string DissolveControlName = "DissolveInControl";

    private bool canTakeOff{get{return leftIsDone && rightIsDone;}}
    void Awake(){
        leftProgresser = new CoroutineExcuter(this);
        rightProgresser = new CoroutineExcuter(this);
        initPowerPos = powerTransform.localPosition;
    }
    void Update(){
        if(canTakeOff){
            powerValue += Time.deltaTime*powerUpSpeed;

            powerTransform.localPosition = Vector3.Lerp(initPowerPos, initPowerPos + powerTransform.forward*pushDistance, powerValue);

        }
    }
    void OnLeft(InputValue inputValue){
        if(leftIsDone) return;
        if(inputValue.isPressed){
            leftProgresser.Excute(coroutineDissolveText(leftAnime, 2f, 0.5f, ()=>{
                leftIsDone=true;
                leftProgresser.Excute(coroutineDissolveText(leftAnime, 0.2f, 1, null));
                dissolveControlAnimation.Play(DissolveMapName);
                p_leftBurst.Play(true);
            }));
            leftMotionGroup.StrongMotion();
        }
        else{
            leftProgresser.Excute(coroutineDissolveText(leftAnime, 0.5f, 0, null));
            leftMotionGroup.weakMotion();
        }
    }
    void OnRight(InputValue inputValue){
        if(rightIsDone) return;
        if(inputValue.isPressed){
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 2f, 0.5f, ()=>{
                rightIsDone=true;
                rightProgresser.Excute(coroutineDissolveText(rightAnime, 0.2f, 1, null));
                dissolveControlAnimation.Play(DissolveControlName);
                p_rightBurst.Play(true);
            }));
            rightMotionGroup.StrongMotion();
        }
        else{
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 0.5f, 0, null));
            rightMotionGroup.weakMotion();
        }
    }
    void OnUp(InputValue inputValue){
        if(canTakeOff){
            if(inputValue.isPressed){
                powerUpSpeed = 1;
            }
            else{
                powerUpSpeed = 0;
            }
        }
    }
    IEnumerator coroutineDissolveText(Animation textAnime, float duration, float target, System.Action OnComplete){
        if(!textAnime.isPlaying) textAnime.Play();
        string clipName = textAnime.clip.name;
        textAnime[clipName].speed = 0;

        float initTime = textAnime[clipName].normalizedTime;
        yield return new WaitForLoop(duration, (t)=>{
            textAnime[clipName].normalizedTime = Mathf.Lerp(initTime, target, EasingFunc.Easing.QuadEaseIn(t));
        });
        OnComplete?.Invoke();
    }
}
