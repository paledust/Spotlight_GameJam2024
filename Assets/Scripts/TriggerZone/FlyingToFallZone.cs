using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyingToFallZone : MonoBehaviour
{
    [SerializeField] private float TurnDuration = 4;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            var cmdManager = other.GetComponent<PlaneCommandManager>();
            var cmd = new PC_SwitchPlaneInput(){isActivated = false};
            cmd.QueueCommand(new PC_TurnPlane(){duration = 4f, targetDirection = -transform.up})
                .QueueCommand(new C_Wait<PlaneControl_Free>(2f)).OnCommandComplete(()=>{
                    EventHandler.Call_OnFlyAboveSky();
                });
            cmdManager.AddCommand(cmd);
        }
    }
}
