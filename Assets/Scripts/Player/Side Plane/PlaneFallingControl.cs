using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneFallingControl : MonoBehaviour
{
    [SerializeField] private PlaneControl_Platform planeControl_Platform;
    [SerializeField] private float fallingTravelDistance;
    [SerializeField, ShowOnly] private float totalLength;
[Header("Particles")]
    [SerializeField] private ParticleSystem p_smoke;
    private bool isFalling;
    private float start_x;

    void Start(){
        start_x = transform.position.x;
    }
    void Update()
    {
        totalLength = transform.position.x - start_x;
        if(totalLength > fallingTravelDistance && !isFalling){
            isFalling = true;
            planeControl_Platform.ShakePlane();
            p_smoke.Play();
        }
    }
}
