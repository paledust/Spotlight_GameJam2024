using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RichardFallingManager : MonoBehaviour
{
    [SerializeField] private float fallingTravelDistance;
    [SerializeField] private PlaneControl_Platform planeControl_Platform;
    [SerializeField, ShowOnly] private float totalLength;

    private bool isFalling;
    private float start_x;

    void Start(){
        start_x = planeControl_Platform.transform.position.x;
    }
    void Update()
    {
        totalLength = planeControl_Platform.transform.position.x - start_x;
        if(totalLength > fallingTravelDistance && !isFalling){
            isFalling = true;
        }
    }
}
