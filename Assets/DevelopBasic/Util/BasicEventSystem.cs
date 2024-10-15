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

#region  Interaction Event
    public static event Action<int> E_OnRiseHand;
    public static void Call_OnRiseHand(int direction)=>E_OnRiseHand?.Invoke(direction);
    public static event Action E_OnPlaneCrashed;
    public static void Call_OnPlaneCrashed()=>E_OnPlaneCrashed?.Invoke();
#endregion
}