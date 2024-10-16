using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloatingMotionGroup : MonoBehaviour
{
    [SerializeField] private FloatingMotion[] floatMotions;
    [SerializeField] private float strongFreq = 7;
    [SerializeField] private float weakFreq = 0.5f;
    [SerializeField] private float floatFreq;
    [SerializeField] private float floatOffset;
    CoroutineExcuter freqChanger;
    void Start()=>freqChanger = new CoroutineExcuter(this);
    void Update()
    {
        foreach(var floatMotion in floatMotions){
            floatMotion.floatFreq = floatFreq;
            floatMotion.floatOffset = floatOffset;
        }
    }
    public void StrongMotion()=>freqChanger.Excute(coroutineChangeFreq(strongFreq, 0.002f));
    public void weakMotion()=>freqChanger.Excute(coroutineChangeFreq(weakFreq, 0.001f));
    IEnumerator coroutineChangeFreq(float targetFreq, float targetOffset, float duration = 0.5f){
        float initFreq = floatFreq;
        float initOffset = floatOffset;
        yield return new WaitForLoop(duration, (t)=>{
            floatFreq = Mathf.Lerp(initFreq, targetFreq, EasingFunc.Easing.SmoothInOut(t));
            floatOffset = Mathf.Lerp(initOffset, targetOffset, EasingFunc.Easing.SmoothInOut(t));
        });
    }
}
