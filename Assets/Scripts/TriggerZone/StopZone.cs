using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StopZone : MonoBehaviour
{
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
