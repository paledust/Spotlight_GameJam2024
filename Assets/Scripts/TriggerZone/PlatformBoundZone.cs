using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformBoundZone : MonoBehaviour
{
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            
        }
    }
}
