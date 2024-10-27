using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StopZone : MonoBehaviour
{
    [SerializeField] private bool useForwardAsStopDirection = true;
    [SerializeField] private float stopSmoothDistance = 100f;
    [SerializeField] private Vector3 StopDirection = Vector3.forward;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            EventHandler.Call_OnInteractingStopZone(true);
        }
    }
    void OnTriggerExit(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            EventHandler.Call_OnInteractingStopZone(false);
        }
    }
}
