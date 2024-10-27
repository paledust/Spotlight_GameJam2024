using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneFallingControl : MonoBehaviour
{
    [SerializeField] private PlaneControl_Platform planeControl_Platform;
    [SerializeField] private float fallingTravelDistance;
    [SerializeField] private float maxFallingSpeed = 1;
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
            planeControl_Platform.StartFalling(maxFallingSpeed);
            planeControl_Platform.ShakePlane();
            p_smoke.Play();

            var commandManager = GetComponent<PlatformPlaneCommandManager>();
            var cmd = new PPC_ChangeExternalAngle(){duration = 20f, targetAngle = -20f};
            commandManager.AddCommand(cmd);

            EventHandler.Call_OnStartToFall();
        }
    }
}
