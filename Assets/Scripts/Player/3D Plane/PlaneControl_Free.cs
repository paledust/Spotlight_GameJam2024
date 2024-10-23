using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(PlayerInput), typeof(Rigidbody))]
public class PlaneControl_Free : MonoBehaviour
{
[Header("Flight Pose Control")]
    [SerializeField] private float maxYawSpeed = 10;
    [SerializeField] private float maxPitchSpeed;
    [SerializeField] private float maxRollSpeed;
    [SerializeField, Tooltip("控制输入反应速度")] private float agility = 5;
    [SerializeField] private Vector2 flyingSpeed;
[Header("Fin Control")]
    [SerializeField, Tooltip("左副翼")] private Transform LWingTrans;
    [SerializeField, Tooltip("右副翼")] private Transform RWingTrans;
    [SerializeField, Tooltip("方向舵")] private Transform TailTrans;
    [SerializeField, Tooltip("升降舵")] private Transform FinTrans;
    [SerializeField] private float MaxWingAngle; //最大副翼角度
    [SerializeField] private float MaxTailAngle; //最大方向舵角度
    [SerializeField] private float MaxFinAngle; //最大升降舵角度
[Header("propeller Control")]
    [SerializeField] private Rotator rotator;
    [SerializeField] private Vector2 spinningSpeedRange;
[Header("Cam Control")]
    [SerializeField] private CinemachineVirtualCamera m_cam;
    [SerializeField] private Vector2 fovRange;

    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private Quaternion initLWingRot;
    private Quaternion initRWingRot;
    private Quaternion initFinRot;
    private Quaternion initTailRot;
    private float targetPitchSpeed;
    private float targetRollSpeed;
    private float targetYawSpeed;
    private float currentPitchSpeed;
    private float currentRollSpeed;
    private float currentYawSpeed;
    private float currentFinAngle;
    private float currentTailAngle;
    private float currentWingAngle;
    private float targetFlyingSpeed;
    private float currentFlyingSpeed;
    private float targetFOV;

    private bool canActivateInput{get{return !crashed;}}
    private bool crashed = false;

    void Awake(){
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();

        currentPitchSpeed = targetPitchSpeed = currentRollSpeed = targetRollSpeed = currentYawSpeed = targetYawSpeed = 0;
        currentFinAngle = currentTailAngle = currentWingAngle = 0;
        currentFlyingSpeed = targetFlyingSpeed = (flyingSpeed.x+flyingSpeed.y)/2f;

        initFinRot = FinTrans.localRotation;
        initTailRot = TailTrans.localRotation;
        initLWingRot = LWingTrans.localRotation;
        initRWingRot = RWingTrans.localRotation;
    }
    void Update(){
    //平滑改变飞行姿态
        {
            float _s = Time.deltaTime*agility;
            currentPitchSpeed = Service.LerpValue(currentPitchSpeed, targetPitchSpeed, _s);
            currentRollSpeed = Service.LerpValue(currentRollSpeed, targetRollSpeed, _s);
            currentYawSpeed = Service.LerpValue(currentYawSpeed, targetYawSpeed, _s);
        }
    //改变舵的角度
        {
            float _s = Time.deltaTime*5;
            currentFinAngle = Service.LerpValue(currentFinAngle, -MaxFinAngle * targetPitchSpeed/maxPitchSpeed, _s);
            currentTailAngle = Service.LerpValue(currentTailAngle, -MaxTailAngle * targetYawSpeed/maxYawSpeed, _s);
            currentWingAngle = Service.LerpValue(currentWingAngle, MaxWingAngle * targetRollSpeed/maxRollSpeed, _s);

            FinTrans.localRotation = Quaternion.Euler(currentFinAngle*Vector3.right) * initFinRot;
            TailTrans.localRotation = Quaternion.Euler(currentTailAngle*Vector3.up) * initTailRot;
            LWingTrans.localRotation = Quaternion.Euler(currentWingAngle*Vector3.right) * initLWingRot;
            RWingTrans.localRotation = Quaternion.Euler(-currentWingAngle*Vector3.right) * initRWingRot;
        }
    //改变螺旋桨转速，航速，摄像机FOV
        {
            float _s = Time.deltaTime*2;
            currentFlyingSpeed = Service.LerpValue(currentFlyingSpeed, targetFlyingSpeed, _s);
            rotator.rotateSpeed = Mathf.Lerp(spinningSpeedRange.x, spinningSpeedRange.y, (targetFlyingSpeed-flyingSpeed.x)/(flyingSpeed.y-flyingSpeed.x));
            m_cam.m_Lens.FieldOfView = Mathf.Lerp(fovRange.x, fovRange.y,(currentFlyingSpeed-flyingSpeed.x)/(flyingSpeed.y-flyingSpeed.x));
        }
    }
    void FixedUpdate(){
        m_rigid.rotation *= Quaternion.Euler(currentPitchSpeed*Time.fixedDeltaTime, currentYawSpeed*Time.fixedDeltaTime, currentRollSpeed*Time.fixedDeltaTime);
        m_rigid.velocity = m_rigid.rotation*Vector3.forward*currentFlyingSpeed;
    }
//处理飞机坠毁的方式
    public void OnCollide(Collision collision){
        if(!crashed){
            crashed = true;
        //取消摄像机的跟随，降低优先级，为下一架飞机让路
            m_cam.transform.parent = null;
            m_cam.m_Follow = null;
            m_cam.m_LookAt = null;
            m_cam.Priority--;
        
        //使飞机继续旋转
            Vector3 forward = m_rigid.velocity;
            forward.y = 0;
            m_rigid.angularVelocity = new Vector3(currentPitchSpeed*Time.fixedDeltaTime*2, 0, currentRollSpeed*Time.fixedDeltaTime*2);
            m_rigid.AddForceAtPosition(collision.impulse*0.5f, collision.contacts[0].point, ForceMode.Impulse);
            m_rigid.AddRelativeTorque(Vector3.right*10, ForceMode.VelocityChange);

            EventHandler.Call_OnPlaneCrashed(transform.position);
            playerInput.DeactivateInput();
            this.enabled = false;
        }
    }
    public void ForcePlaneRot(Quaternion rotation){
        m_rigid.rotation = rotation;
    }
    public void TrySwitchInput(bool isActivate){
        if(isActivate && canActivateInput) playerInput.ActivateInput();
        else playerInput.DeactivateInput();

    }
#region Input
    void OnMove(InputValue inputValue){
        Vector2 input = inputValue.Get<Vector2>();
        targetPitchSpeed = input.y * maxPitchSpeed;
        targetRollSpeed = -input.x * maxRollSpeed;
    }
    void OnSide(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetYawSpeed = input * maxYawSpeed;
    }
    void OnAcc(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetFlyingSpeed = Mathf.Lerp(flyingSpeed.x, flyingSpeed.y, input*0.5f+0.5f);
    }
#endregion
}