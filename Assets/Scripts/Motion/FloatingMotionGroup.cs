using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloatingMotionGroup : MonoBehaviour
{
    [SerializeField] private FloatingMotion[] floatMotions;
    [SerializeField] private float floatFreq;
    [SerializeField] private float floatHeight;
    CoroutineExcuter freqChanger;
    void Start()=>freqChanger = new CoroutineExcuter(this);
    void Update()
    {
        foreach(var floatMotion in floatMotions){
            floatMotion.floatFreq = floatFreq;
        }
    }
    public void StrongMotion()=>freqChanger.Excute(coroutineChangeFreq(7));
    public void weakMotion()=>freqChanger.Excute(coroutineChangeFreq(0.5f));
    IEnumerator coroutineChangeFreq(float targetFreq, float duration = 0.2f){
        float initFreq = floatFreq;
        yield return new WaitForLoop(duration, (t)=>{
            floatFreq = Mathf.Lerp(initFreq, targetFreq, EasingFunc.Easing.SmoothInOut(t));
        });
    }
}
