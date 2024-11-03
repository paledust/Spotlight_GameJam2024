using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PullUpWarnTrigger : MonoBehaviour
{
    [SerializeField] private RichardFallingManager richardFallingManager;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GetComponent<Collider>().enabled = false;
            richardFallingManager.PlayPullUpWarning();
        }
    }
}
