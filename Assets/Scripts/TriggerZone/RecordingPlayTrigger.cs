using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordingPlayTrigger : MonoBehaviour
{
    [SerializeField] private string recordingClip;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GetComponent<Collider>().enabled = false;
            RecordingManager.Instance.PlayRecording(recordingClip);
        }
    }
}
