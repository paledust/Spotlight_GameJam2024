using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrashTrigger : MonoBehaviour
{
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GameManager.Instance.SwitchingScene(Service.FALL_TRANSITION, 0.05f, Color.white);
        }
    }
}
