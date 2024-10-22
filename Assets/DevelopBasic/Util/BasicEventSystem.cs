using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//A basic C# Event System
public static class EventHandler
{
#region Game Basic Event
    public static event Action E_BeforeUnloadScene;
    public static void Call_BeforeUnloadScene(){E_BeforeUnloadScene?.Invoke();}
    public static event Action E_AfterLoadScene;
    public static void Call_AfterLoadScene(){E_AfterLoadScene?.Invoke();}
    public static event Action E_OnBeginSave;
    public static void Call_OnBeginSave()=>E_OnBeginSave?.Invoke();
    public static event Action E_OnCompleteSave;
    public static void Call_OnCompleteSave()=>E_OnCompleteSave?.Invoke();
#endregion

#region Fly Event
    public static event Action<bool> E_OnInteractingStopZone;
    public static void Call_OnInteractingStopZone(bool isInZone)=>E_OnInteractingStopZone?.Invoke(isInZone);
    public static event Action<Vector3, Quaternion, Vector3[]> E_OnReportPos;
    public static void Call_OnReportPos(Vector3 lastPos, Quaternion lastRotation, Vector3[] threatDirection)=>E_OnReportPos?.Invoke(lastPos, lastRotation, threatDirection);
#endregion

#region  Interaction Event
    public static event Action E_OnPixelGameFinished;
    public static void Call_OnPixelGameFinished()=>E_OnPixelGameFinished?.Invoke();
    public static event Action<int> E_OnConductDirection;
    public static void Call_OnConductDirection(int direction)=>E_OnConductDirection?.Invoke(direction);
    public static event Action<bool> E_OnConductForward;
    public static void Call_OnConductForward(bool isForward)=>E_OnConductForward?.Invoke(isForward);
    public static event Action<Vector3> E_OnPlaneCrashed;
    public static void Call_OnPlaneCrashed(Vector3 crashPos)=>E_OnPlaneCrashed?.Invoke(crashPos);
#endregion
}