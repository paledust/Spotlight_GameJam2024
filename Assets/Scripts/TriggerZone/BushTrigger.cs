using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BushTrigger : MonoBehaviour
{
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            var plane = other.GetComponent<PlaneControl_Free>();
            plane.ShakePlaneForItem();
        }
    }
}