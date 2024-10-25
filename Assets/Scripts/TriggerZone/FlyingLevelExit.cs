using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyingLevelExit : MonoBehaviour
{
    [SerializeField] private float TurnDuration = 4;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            var cmdManager = other.GetComponent<PlaneCommandManager>();
            var cmd = new PC_SwitchPlaneInput(){isActivated = false};
            cmd.QueueCommand(new PC_TurnPlane(){duration = TurnDuration, targetDirection = -transform.up})
                .QueueCommand(new C_Wait<PlaneControl_Free>(2f)).OnCommandComplete(()=>{
                    EventHandler.Call_OnReachExit();
                });
            cmdManager.AddCommand(cmd);
        }
    }
}
