using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneCommands : Command<PlaneControl_Free>{}
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

