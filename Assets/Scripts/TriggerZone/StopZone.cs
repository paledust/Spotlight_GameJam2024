using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StopZone : MonoBehaviour
{
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            
        }
    }
    void OnTriggerExit(Collider other){
        if(other.tag == Service.PLAYER_TAG){

        }
    }
}
