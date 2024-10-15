using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConductingGameControl : MonoBehaviour
{
    public enum ConductingState{Pending, Detecting, Result}
    [SerializeField] private ConductControl conductControl;
[Header("Conducting Object")]
    [SerializeField] private GameObject airplaneObj;
    [SerializeField] private Animation planeAnime; 
    [SerializeField] private Animator lineAnimator;
[Header("Ref Pos")]
    [SerializeField] private Transform center;
    [SerializeField] private Transform stopPos;
[Header("Offset")]
    [SerializeField] private float stopOffset = 15; 
    [SerializeField] private float alertOffset = 10;
    [SerializeField] private float warnOffset = 5; 
    [SerializeField] private float maxYawOffset = 10;
[Header("Speed")]
    [SerializeField] private float maxAngularSpeed = 10;
    [SerializeField] private float maxMoveSpeed;
    [SerializeField] private float moveAgility=5;
    [SerializeField] private float rotAgility = 1;

    private float currentSpeed = 0;
    private float targetSpeed = 0;
    private float yawSpeed = 0;
    private float targetYaw = 0;
    private float currentYaw = 0;
    private int receivedDirection = 0;
    private bool isMoving = false;
    private string float_offsetName = "Offset";


    void OnEnable(){
        EventHandler.E_OnConductDirection += ConductDirectionHandler;
        EventHandler.E_OnConductForward += ConductForwardHandler;
    }
    void OnDisable(){
        EventHandler.E_OnConductDirection -= ConductDirectionHandler;
        EventHandler.E_OnConductForward -= ConductForwardHandler;
    }
    void Update(){
        currentSpeed = Service.LerpValue(currentSpeed, targetSpeed, moveAgility*Time.deltaTime);
        float speedFactor = currentSpeed/maxMoveSpeed;
        currentYaw = Service.LerpValue(currentYaw, targetYaw, rotAgility*Time.deltaTime*Mathf.Abs(speedFactor));

        float offset = Mathf.Abs(airplaneObj.transform.localPosition.x - center.localPosition.x);
        lineAnimator.SetFloat(float_offsetName, offset/alertOffset);

        if(airplaneObj.transform.localPosition.z>stopPos.localPosition.z){
            targetSpeed = 0;
        }
    }
    void FixedUpdate()
    {
        targetYaw += yawSpeed * Time.fixedDeltaTime;
        targetYaw = Math.Clamp(targetYaw, -maxYawOffset, maxYawOffset);

        airplaneObj.transform.localPosition += airplaneObj.transform.localRotation * Vector3.forward * currentSpeed * Time.fixedDeltaTime;
        airplaneObj.transform.localRotation = Quaternion.Euler(0, currentYaw, 0);
    }

    void ConductDirectionHandler(int direction){
        if(!isMoving) return;
        receivedDirection += direction;
        yawSpeed = receivedDirection*maxAngularSpeed;
    }
    void ConductForwardHandler(bool isForward){
        isMoving = true;
        targetSpeed = isForward?maxMoveSpeed:0;
    }
}
