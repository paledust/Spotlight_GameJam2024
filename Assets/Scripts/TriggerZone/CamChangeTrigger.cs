using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class CamChangeTrigger : MonoBehaviour
{
    [SerializeField] private CinemachineMixingCamera vc_mixing;
    private float totalHeight;
    private Transform planeTrans;

    void Start(){
        totalHeight = transform.lossyScale.y;
    }
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG) planeTrans = other.transform;
    }
    void OnTriggerExit(Collider other){
        if(other.tag == Service.PLAYER_TAG) planeTrans = null;
    }
    void Update(){
        if(planeTrans){
            float height = planeTrans.position.y - transform.position.y;
            vc_mixing.m_Weight0 = height/totalHeight;
            vc_mixing.m_Weight1 = 1-height/totalHeight;
        }
    }
}
