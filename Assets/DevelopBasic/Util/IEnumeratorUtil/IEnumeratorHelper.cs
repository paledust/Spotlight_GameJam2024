using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EasingFunc;
using TMPro;

public static class CommonCoroutine{
    public static IEnumerator coroutineFadeSprite(SpriteRenderer m_sprite, float targetAlpha, float duration, float delay = 0){
        yield return new WaitForSeconds(delay);
        if(targetAlpha == 1) m_sprite.enabled = true;

        Color initColor = m_sprite.color;
        Color targetColor = initColor;
        targetColor.a = targetAlpha;

        yield return new WaitForLoop(duration, (t)=>{
            m_sprite.color = Color.Lerp(initColor, targetColor, Easing.SmoothInOut(t));
        });

        if(targetAlpha == 0) m_sprite.enabled = false;
    }
    public static IEnumerator coroutineFadeSprite(SpriteRenderer m_sprite, float targetAlpha, float duration, Easing.FunctionType functionType, float delay = 0){
        yield return new WaitForSeconds(delay);
        if(targetAlpha == 1) m_sprite.enabled = true;

        Color initColor = m_sprite.color;
        Color targetColor = initColor;
        targetColor.a = targetAlpha;

        var func = Easing.GetFunctionWithTypeEnum(functionType);
        yield return new WaitForLoop(duration, (t)=>{
            m_sprite.color = Color.Lerp(initColor, targetColor, Easing.SmoothInOut(t));
        });

        if(targetAlpha == 0) m_sprite.enabled = false;
    }
    public static IEnumerator coroutineFadeSpriteColor(SpriteRenderer m_sprite, Color targetColor, float duration){
        Color initColor = m_sprite.color;

        yield return new WaitForLoop(duration, (t)=>{
            m_sprite.color = Color.Lerp(initColor, targetColor, Easing.SmoothInOut(t));
        });
    }
    public static IEnumerator CoroutineSpriteGlow(SpriteRenderer m_sprite, float targetGlow, float duration){
        string spriteOutlineName = "_Outline";
        float initGlow = m_sprite.material.GetFloat(spriteOutlineName);
        yield return new WaitForLoop(duration, (t)=>{
            m_sprite.material.SetFloat(spriteOutlineName, Mathf.Lerp(initGlow, targetGlow, Easing.SmoothInOut(t)));
        });
    }
    public static IEnumerator CoroutineFadeCharacter(TMP_CharacterInfo c, float targetAlpha, float duration, Easing.FunctionType easeType=Easing.FunctionType.QuadEaseOut){
        Color initColor = c.color;
        Color targetColor = initColor;
        targetColor.a = targetAlpha;

        string outlineSoftnessName = "_OutlineSoftness";
        c.material = Material.Instantiate(c.material);
        float initSoftness = c.material.GetFloat(outlineSoftnessName);
        float targetSoftness = 1-targetAlpha;

        var easeFunc = Easing.GetFunctionWithTypeEnum(easeType);
        yield return new WaitForLoop(duration, (t)=>{
            c.material.SetFloat(outlineSoftnessName, Mathf.Lerp(initSoftness, targetSoftness, easeFunc(Mathf.Clamp01(t*5))));
            c.color = Color.Lerp(initColor, targetColor, easeFunc(t));
        });
    }
    public static IEnumerator CoroutineDestroyDelay(float delay, GameObject gameObject){
        yield return new WaitForSeconds(delay);
        GameObject.Destroy(gameObject);
    }
}

public class CoroutineExcuter
{
    MonoBehaviour initiator;
    IEnumerator coroutine;
    public CoroutineExcuter(MonoBehaviour _context)=>initiator = _context;
    public void Excute(IEnumerator go){
        if(coroutine!=null) initiator.StopCoroutine(coroutine);
        coroutine = go;
        initiator.StartCoroutine(go);
    }
    public void Abort(){
        if(coroutine!=null) initiator.StopCoroutine(coroutine);
    }
}

public class WaitForLoop: IEnumerator
{
    private IEnumerator m_coroutine;

    public WaitForLoop(float _duration, Action<float> _go){
        m_coroutine = ForLoopCoroutine(_duration, _go);
    }

    public object Current{get{return m_coroutine.Current;}}
    public bool MoveNext(){return m_coroutine.MoveNext();}
    public void Reset()=>m_coroutine.Reset();
    
    public static IEnumerator ForLoopCoroutine(float duration, Action<float> go){
        float speed = 1f/duration;
        for(float t=0; t<1; t+=Time.deltaTime*speed){
            go(t);
            yield return null;
        }
        go(1);
    }
}