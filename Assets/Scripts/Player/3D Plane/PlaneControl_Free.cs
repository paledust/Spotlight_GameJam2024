using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using SimpleAudioSystem;
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
    public float maxSpeed;
    public float angularSpeedMulti = 1;
    [SerializeField] private Transform planeRoot;
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
[Header("VFX")]
    [SerializeField] private ParticleSystem p_explodePuff;
    [SerializeField] private TrailRenderer[] flightTrail;
[Header("Plane Shake")]
    [SerializeField] private Animator planeAnimator;
[Header("Audio")]
    [SerializeField] private AudioSource m_audioLoop;
    [SerializeField] private string engineClip;
    [SerializeField] private float maxVolume = 0.6f;
    
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
    private float targetPoseRollSpeed;
    private float currentPoseRollSpeed;
    private float targetPoseRollAngle;
    private float currentPoseRollAngle;
    private float externalPoseFinAngle;
    private CoroutineExcuter trailFader;

    private const float MAX_POSE_ANGLE = 40;
    private const float MAX_SPEED_AFTERCONTROL = 40;
    private const string trigger_shake = "Shake";
    private const string bool_bumpy = "Bumpy";

    private bool canActivateInput{get{return !crashed;}}
    private bool crashed = false;
    private bool takenControl = false;

    public Rigidbody m_rigid{get; private set;}

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
    void Start(){
        AudioManager.Instance.PlaySoundEffectLoop(m_audioLoop, engineClip, 1, 0.5f);
        trailFader = new CoroutineExcuter(this);
    }
    void Update(){
    //平滑改变飞行姿态
        {
            float _s = Time.deltaTime*agility;
            currentPitchSpeed = Service.LerpValue(currentPitchSpeed, targetPitchSpeed*angularSpeedMulti, _s);
            currentRollSpeed = Service.LerpValue(currentRollSpeed, targetRollSpeed*angularSpeedMulti, _s);
            currentYawSpeed = Service.LerpValue(currentYawSpeed, targetYawSpeed*angularSpeedMulti, _s);

            targetPoseRollSpeed = targetPoseRollAngle - currentPoseRollAngle;
            targetPoseRollSpeed = 1.5f*targetPoseRollSpeed;
            currentPoseRollSpeed = Service.LerpValue(currentPoseRollSpeed, targetPoseRollSpeed, _s*4);

            currentPoseRollAngle += Time.deltaTime*currentPoseRollSpeed;
        }
    //改变舵的角度
        {
            float _s = Time.deltaTime*5;
            externalPoseFinAngle = Mathf.Abs(currentPoseRollAngle/MAX_POSE_ANGLE)*15;
            currentFinAngle = Service.LerpValue(currentFinAngle, -MaxFinAngle * targetPitchSpeed*angularSpeedMulti/maxPitchSpeed, _s);
            currentTailAngle = currentPoseRollAngle/MAX_POSE_ANGLE *MaxTailAngle;
            currentWingAngle = Service.LerpValue(currentWingAngle, MaxWingAngle * (targetRollSpeed+targetPoseRollSpeed)*angularSpeedMulti/maxRollSpeed, _s);

            FinTrans.localRotation = Quaternion.Euler((currentFinAngle+externalPoseFinAngle)*Vector3.right) * initFinRot;
            TailTrans.localRotation = Quaternion.Euler(currentTailAngle*Vector3.up) * initTailRot;
            LWingTrans.localRotation = Quaternion.Euler(currentWingAngle*Vector3.right) * initLWingRot;
            RWingTrans.localRotation = Quaternion.Euler(-currentWingAngle*Vector3.right) * initRWingRot;
        }
        float speedScale = (currentFlyingSpeed-flyingSpeed.x)/(flyingSpeed.y-flyingSpeed.x);
    //改变螺旋桨转速，航速，摄像机FOV
        {
            float _s = Time.deltaTime*2;
            currentFlyingSpeed = Service.LerpValue(currentFlyingSpeed, Mathf.Min(targetFlyingSpeed, maxSpeed), _s);
            rotator.rotateSpeed = Mathf.Lerp(spinningSpeedRange.x, spinningSpeedRange.y, Mathf.Clamp01((Mathf.Min(targetFlyingSpeed, maxSpeed)-flyingSpeed.x)/(flyingSpeed.y-flyingSpeed.x)));
            m_cam.m_Lens.FieldOfView = Mathf.Lerp(fovRange.x, fovRange.y, Mathf.Clamp01((currentFlyingSpeed-flyingSpeed.x)/(flyingSpeed.y-flyingSpeed.x)));
        }
    //改变飞机的音效
        {
            m_audioLoop.pitch = Mathf.Lerp(0.8f, 1.2f, speedScale);
            m_audioLoop.volume = Mathf.Lerp(0.6f, 1f, speedScale)*maxVolume;
        }
    }
    void FixedUpdate(){
        planeRoot.localRotation = Quaternion.Euler(0,0,currentPoseRollAngle);
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

        //播放爆炸例子效果
            p_explodePuff.Play(true);
        //消除声音
            AudioManager.Instance.FadeAudio(m_audioLoop, 0, 0.01f, true);
        }
    }
    public void ForcePlaneRot(Quaternion rotation){
        m_rigid.rotation = rotation;
    }
    public void TrySwitchInput(bool isActivate){
        if(isActivate && canActivateInput) playerInput.ActivateInput();
        else playerInput.DeactivateInput();
    }

#region Animation
    public void ShakePlaneForItem(){
        planeAnimator.SetTrigger(trigger_shake);
    }
    public void SwitchBumpyFly(bool isBumpy){
        planeAnimator.SetBool(bool_bumpy, isBumpy);
    }
#endregion

#region VFX
    public void FadeTrailColor(Color targetColor, float duration = 1){
        trailFader.Excute(coroutineFadeTrail(targetColor, duration));
    }
    public void FadeTrailColorDefault(float duration=1){
        FadeTrailColor(Color.white, duration);
    }
    IEnumerator coroutineFadeTrail(Color targetColor, float duration){
        Gradient gradient = flightTrail[0].colorGradient;
        GradientColorKey[] colorKeys = gradient.colorKeys;
        Color initColor = colorKeys[0].color;

        yield return new WaitForLoop(duration,(t)=>{
            colorKeys[0].color = Color.Lerp(initColor, targetColor, EasingFunc.Easing.SmoothInOut(t));
            colorKeys[1].color = colorKeys[0].color;
            gradient.SetKeys(colorKeys, gradient.alphaKeys);
            foreach(var trail in flightTrail){
                trail.colorGradient = gradient;
            }
        });
    }
#endregion

#region Input
    void OnMove(InputValue inputValue){
        Vector2 input = inputValue.Get<Vector2>();
        targetPitchSpeed = input.y * maxPitchSpeed;
        targetYawSpeed = input.x * maxYawSpeed;
        targetPoseRollAngle = -MAX_POSE_ANGLE*input.x;
        
        if(!takenControl){
            takenControl = true;
            maxSpeed = MAX_SPEED_AFTERCONTROL;
        }
    }
    void OnSide(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetRollSpeed = -input * maxRollSpeed;

        if(!takenControl){
            takenControl = true;
            maxSpeed = MAX_SPEED_AFTERCONTROL;
        }
    }
    void OnAcc(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetFlyingSpeed = Mathf.Lerp(flyingSpeed.x, flyingSpeed.y, input*0.5f+0.5f);

        if(!takenControl){
            takenControl = true;
            maxSpeed = MAX_SPEED_AFTERCONTROL;
        }
    }
#endregion
}