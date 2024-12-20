using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IceLayerTrigger : MonoBehaviour
{
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GetComponent<Collider>().enabled = false;
            EventHandler.Call_OnEnterIceLayer();
            RecordingManager.Instance.StopCurrentRecording();
        }
    }
}
