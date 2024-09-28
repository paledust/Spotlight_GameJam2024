using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#region Extension
public static class ExtensionMethods{
    /// <summary>
    /// Play a random audio clip from a series of audio clips
    /// </summary>
    /// <param name="audio">Target audio source</param>
    /// <param name="clips">Clips to be played</param>
    /// <param name="volume">How loud the clip should be played</param>
    /// <param name="pitchShiftRange">How much can the pitch be shifted</param>
    public static float GetRndValueInVector2Range(this Vector2 range){return Random.Range(range.x, range.y);}
    public static int GetRndValueInVector2Range(this Vector2Int range){return Random.Range(range.x, range.y);}
}
#endregion
