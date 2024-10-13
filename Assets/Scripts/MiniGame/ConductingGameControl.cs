using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class ConductingGameControl : MonoBehaviour
{
[Header("Day Night")]
    [SerializeField] private PlayableDirector timeOfDayDirector;
[Header("Ref Position")]
    [SerializeField] private Transform entrencePos;
    [SerializeField] private Transform stopPos;
    [SerializeField] private Transform leftExit;
    [SerializeField] private Transform rightExit;
[Header("Tempo")]
    [SerializeField] private float beatRate;
    [SerializeField] private int detectionWindow = 4;
    [SerializeField] private 

    void Update()
    {
        
    }
}
