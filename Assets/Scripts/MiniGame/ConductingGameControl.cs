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
    [SerializeField] private float maxYawOffset = 10;
[Header("Driver")]
    [SerializeField] private float maxDriverInput = 1;
    [SerializeField] private float driverInputAcc = 1;

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
    private float driverInputDirection = 0;
    private float driverInput = 0;
    private int receivedDirection = 0;
    private bool isMoving = false;
    private bool isDone = false;
    private string float_offsetName = "Offset";

    void OnEnable(){
        EventHandler.E_OnConductDirection += ConductDirectionHandler;
        EventHandler.E_OnConductForward += ConductForwardHandler;
    }
    void OnDisable(){
        EventHandler.E_OnConductDirection -= ConductDirectionHandler;
        EventHandler.E_OnConductForward -= ConductForwardHandler;
    }
    void Start(){
        targetYaw = currentYaw = Random.Range(-maxYawOffset,maxYawOffset);
    }
    void Update(){
        currentSpeed = Service.LerpValue(currentSpeed, targetSpeed, moveAgility*Time.deltaTime);
        float speedFactor = currentSpeed/maxMoveSpeed;
        currentYaw = Service.LerpValue(currentYaw, targetYaw, rotAgility*Time.deltaTime*Mathf.Abs(speedFactor));

        float offset = Mathf.Abs(airplaneObj.transform.localPosition.x - center.localPosition.x);
        lineAnimator.SetFloat(float_offsetName, offset/alertOffset);


    //结束条件判断
        if(airplaneObj.transform.localPosition.z>stopPos.localPosition.z && !isDone){
            isDone = true;

            conductControl.Finish();
            planeAnime.Play();
            isMoving = false;
            isDone = true;
            targetSpeed = 0;

            StartCoroutine(CommonCoroutine.delayAction(()=>GameManager.Instance.SwitchingScene("WorkingRichard", 2f), 3));
        }
    }
    void FixedUpdate()
    {
        targetYaw += (isMoving?yawSpeed:0) * Time.fixedDeltaTime;

        if(yawSpeed==0){
            targetYaw += (isMoving?driverInput:0) * Time.fixedDeltaTime;

            driverInput += driverInputDirection * driverInputAcc * Time.fixedDeltaTime;
            driverInput = Mathf.Clamp(driverInput, -maxDriverInput, maxDriverInput);
        }

        targetYaw = Mathf.Clamp(targetYaw, -maxYawOffset, maxYawOffset);

        airplaneObj.transform.localPosition += airplaneObj.transform.localRotation * Vector3.forward * currentSpeed * Time.fixedDeltaTime;
        airplaneObj.transform.localRotation = Quaternion.Euler(0, currentYaw, 0);
    }

    void ConductDirectionHandler(int direction){
        receivedDirection += direction;
        yawSpeed = receivedDirection*maxAngularSpeed*Random.Range(0.5f, 2f);

        if(receivedDirection != 0) driverInputDirection = receivedDirection;
        driverInput = 0;
    }
    void ConductForwardHandler(bool isForward){
        isMoving = true;
        targetSpeed = isForward?maxMoveSpeed:0;
        driverInputDirection = Mathf.Sign(Random.Range(0, 1) - 0.5f);
        driverInput = 0;
    }
}
