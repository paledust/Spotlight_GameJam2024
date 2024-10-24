using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


public class PlaceObjectsOnSelected : EditorWindow
{
    protected Vector3 localPos;
    protected Vector3 localEuler;
    protected GameObject placeObject;
    protected int StartIndex = 0;
    [MenuItem("Tools/Others/Place Objects On Selected")]
    public static void ShowWindow(){
        GetWindow<PlaceObjectsOnSelected>("Place Objects Tool");
    }
    void OnGUI()
    {
        GUILayout.Label("targetObject");
        placeObject = EditorGUILayout.ObjectField(placeObject, typeof(GameObject), false) as GameObject;
        localPos = EditorGUILayout.Vector3Field("Position Offset", localPos);
        localEuler = EditorGUILayout.Vector3Field("Rotation Offset", localEuler);
        if(GUILayout.Button("Place")){
            GameObject[] objects = Selection.gameObjects;
            if(objects==null || objects.Length==0){
                Debug.Log("No Objects Selected");
                return;
            }
            for(int i=0; i<objects.Length; i++){
                var obj = PrefabUtility.InstantiatePrefab(placeObject) as GameObject;
                obj.transform.parent = objects[i].transform;
                obj.transform.localPosition = localPos;
                obj.transform.localEulerAngles = localEuler;
                obj.transform.localScale = Vector3.one;
                obj.transform.parent = null;
            }
        }
    }
}
