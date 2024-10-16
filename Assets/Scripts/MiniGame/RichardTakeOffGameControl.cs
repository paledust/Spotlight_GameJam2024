using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RichardTakeOffGameControl : MonoBehaviour
{
[Header("Text Control")]
    [SerializeField] private FloatingMotionGroup leftMotionGroup;
    [SerializeField] private Animation leftAnime;
    [SerializeField] private FloatingMotionGroup rightMotionGroup;
    [SerializeField] private Animation rightAnime;
[Header("Finish Animation")]
    [SerializeField, Range(0, 1)] private Animation dissolveControlAnimation;

    private bool leftIsDone = false;
    private bool rightIsDone = false;

    private CoroutineExcuter leftProgresser;
    private CoroutineExcuter rightProgresser;
    private bool canTakeOff{get{return leftIsDone && rightIsDone;}}
    void Awake(){
        leftProgresser = new CoroutineExcuter(this);
        rightProgresser = new CoroutineExcuter(this);
    }
    void OnLeft(InputValue inputValue){
        if(leftIsDone) return;
        if(inputValue.isPressed){
            leftProgresser.Excute(coroutineDissolveText(leftAnime, 3, 1, ()=>leftIsDone=true));
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
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 3f, 1, ()=>rightIsDone=true));
            rightMotionGroup.StrongMotion();
        }
        else{
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 0.5f, 0, null));
            rightMotionGroup.weakMotion();
        }
    }
    void OnUp(InputValue inputValue){
        if(canTakeOff){
            
        }
    }
    IEnumerator coroutineDissolveText(Animation textAnime, float duration, float target, Action OnComplete){
        if(!textAnime.isPlaying) textAnime.Play();
        string clipName = textAnime.clip.name;
        textAnime[clipName].speed = 0;

        float initTime = textAnime[clipName].normalizedTime;
        yield return new WaitForLoop(duration, (t)=>{
            textAnime[clipName].normalizedTime = Mathf.Lerp(initTime, target, EasingFunc.Easing.SmoothInOut(t));
        });
        OnComplete?.Invoke();
    }
}
