using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneCommands : Command<PlaneControl_Free>{}

#region Plane Shake
public class PC_ShakePlane : PlaneCommands{
    public float shakeStrength = 20;
    public float shakeFreq = 10;
    public float easeInTime;
}
public class PC_ShakePlaneImpluse : PlaneCommands{
    public float shakeStrength = 20;
    public float shakeFreq = 10;
    public float duration;
}
public class PC_StopPlaneShake : PlaneCommands{
    public float duration;
}
#endregion

public class PC_TurnPlane : PlaneCommands{
    public float duration;
    public Vector3 targetDirection;

    private Quaternion targetRot;
    private Quaternion startRot;
    private float timer = 0;
    private bool isExcuted = false;
    protected override void Init()
    {
        targetRot = Quaternion.LookRotation(targetDirection);
    }
    internal override void CommandUpdate(PlaneControl_Free context){
        if(!isExcuted){
            isExcuted = true;
            startRot = context.transform.rotation;
        }
        if(timer >= duration){
            SetStatus(CommandStatus.Success);
            return;
        }
        timer += Time.deltaTime;
        Quaternion rot = Quaternion.Lerp(startRot, targetRot, EasingFunc.Easing.SmoothInOut(timer/duration));
        context.ForcePlaneRot(rot);
    }
}
public class PC_SwitchPlaneInput : PlaneCommands{
    public bool isActivated;
    internal override void CommandUpdate(PlaneControl_Free context)
    {
        context.TrySwitchInput(isActivated);
        SetStatus(CommandStatus.Success);
    }
}