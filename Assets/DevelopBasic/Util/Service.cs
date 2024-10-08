using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Service{
#region HelperFunction
    /// <summary>
    /// Return a list of all active and inactive objects of T type in loaded scenes.
    /// </summary>
    /// <typeparam name="T">Object Type</typeparam>
    /// <returns></returns>
    public static T[] FindComponentsOfTypeIncludingDisable<T>(){
        int sceneCount = UnityEngine.SceneManagement.SceneManager.sceneCount;
        var MatchObjects = new List<T> ();

        for(int i=0; i<sceneCount; i++){
            var scene = UnityEngine.SceneManagement.SceneManager.GetSceneAt (i);
            
            var RootObjects = scene.GetRootGameObjects ();

            foreach (var obj in RootObjects) {
                var Matches = obj.GetComponentsInChildren<T> (true);
                MatchObjects.AddRange (Matches);
            }
        }

        return MatchObjects.ToArray ();
    }
    public static void Shuffle<T>(ref T[] elements){
        var rnd = new System.Random();
        for(int i=0; i<elements.Length; i++){
            int index = rnd.Next(i+1);
            T tmp = elements[i];
            elements[i] = elements[index];
            elements[index] = tmp;
        }
    }
    public static float LerpValue(float input, float target, float step, float tolerence = 0.001f){
        float value = Mathf.Lerp(input, target, step);
        if(Mathf.Abs(input-target)<=tolerence) return target;
        return value;
    }
    public static Vector3 LerpVector(Vector3 input, Vector3 target, float step, float tolerence = 0.001f){
        Vector3 value = Vector3.Lerp(input, target, step);
        if(Vector3.SqrMagnitude(input-target)<=tolerence) return target;
        return value;
    }
#endregion
}