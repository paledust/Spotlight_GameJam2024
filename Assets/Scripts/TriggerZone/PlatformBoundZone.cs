using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformBoundZone : MonoBehaviour
{
    public float TurnAngle;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            var commandManager = other.GetComponent<PlatformPlaneCommandManager>();
            var cmd = new PPC_SwitchInput(false);
            cmd.QueueCommand(new PPC_ChangeExternalAngle(){targetAngle = TurnAngle, duration = 0.5f})
            .QueueCommand(new C_Wait<PlaneControl_Platform>(1f))
            .QueueCommand(new PPC_ChangeExternalAngle(){targetAngle = 0, duration = 2.5f})
            .QueueCommand(new PPC_SwitchInput(true));

            commandManager.AddCommand(cmd);
        }
    }
}
