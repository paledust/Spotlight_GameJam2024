using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnTrigger : MonoBehaviour
{
    [SerializeField] private bool triggerOnce = true;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            EventHandler.Call_OnEnterSpawnTrigger(transform);
            if(triggerOnce){
                GetComponent<Collider>().enabled = false;
            }
        }
    }
}
