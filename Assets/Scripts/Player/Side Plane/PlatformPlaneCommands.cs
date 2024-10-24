using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformPlaneCommand : Command<PlaneControl_Platform>{}

public class PPC_SwitchInput: PlatformPlaneCommand{
    public bool isActivated;
    public PPC_SwitchInput(bool activated){
        isActivated = activated;
    }
    internal override void CommandUpdate(PlaneControl_Platform context)
    {
        context.SwitchInput(isActivated);
        SetStatus(CommandStatus.Success);
    }
}
public class PPC_ChangeExternalAngle : PlatformPlaneCommand{
    public float duration;
    public float targetAngle;

    private float timer = 0;
    private float startAngle;
    private bool isExcuted = false;
    internal override void CommandUpdate(PlaneControl_Platform context)
    {
        if(!isExcuted){
            isExcuted = true;
            startAngle = context.m_externalRotateAngle;
        }
        if(timer > duration){
            SetStatus(CommandStatus.Success);
            return;
        }
        timer += Time.deltaTime;
        context.SetExternalAngle(Mathf.Lerp(startAngle, targetAngle, EasingFunc.Easing.SmoothInOut(timer/duration)));
    }
}

