using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StopZone : MonoBehaviour
{
    [SerializeField] private bool useForwardAsStopDirection = true;
    [SerializeField] private float forceScale = 100;
    [SerializeField] private Vector3 StopDirection = Vector3.forward;
    private PlaneControl_Free plane;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            plane = other.GetComponent<PlaneControl_Free>();
            EventHandler.Call_OnInteractingStopZone(true);
        }
    }
    void Update(){
        if(plane != null){
            Vector3 force = forceScale * (useForwardAsStopDirection?transform.forward:StopDirection);
            plane.m_rigid.AddForceAtPosition(force, plane.transform.position+plane.transform.forward*2.5f, ForceMode.Acceleration);
        }
    }
    void OnTriggerExit(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            plane = null;
            EventHandler.Call_OnInteractingStopZone(false);
        }
    }
    void OnDrawGizmosSelected(){
        if(!useForwardAsStopDirection){
            DebugExtension.DrawArrow(transform.position, StopDirection, Color.blue);
        }
    }
}