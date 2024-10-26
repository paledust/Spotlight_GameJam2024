using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpeedLimitTrigger : MonoBehaviour
{
    [SerializeField] private float maxSpeed = 50;
    [SerializeField] private float transitionTime = 5;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GetComponent<Collider>().enabled = false;
            var planeControl = other.GetComponent<PlaneControl_Free>();
            StartCoroutine(coroutineLerpMaxSpeed(planeControl));
        }
    }
    IEnumerator coroutineLerpMaxSpeed(PlaneControl_Free planeControl){
        float initMaxSpeed = planeControl.maxSpeed;
        yield return new WaitForLoop(transitionTime, (t)=>{
            planeControl.maxSpeed = Mathf.Lerp(initMaxSpeed, maxSpeed, EasingFunc.Easing.SmoothInOut(t));
        });
    }
}