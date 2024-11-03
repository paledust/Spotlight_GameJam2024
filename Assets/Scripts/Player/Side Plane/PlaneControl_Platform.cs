using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(PlayerInput), typeof(Rigidbody))]
public class PlaneControl_Platform : MonoBehaviour
{
    [SerializeField, Tooltip("控制输入反应速度")] private float agility = 5;
[Header("Correction Help")]
    [SerializeField] private Transform planeRenderTrans;
    [SerializeField] private float maxCorrectionAngle = 30;
    [SerializeField] private float maxAngleStep = 5;
    [SerializeField] private float inputMulti = 1;
    [SerializeField] private float flyingSpeed = 5;
    [SerializeField] private float angularSpeed = 2;
    [SerializeField] private float rotateToForwardRatio = 1.5f;
    [SerializeField] private float externalRotateAngle;
[Header("Shake Animation")]
    [SerializeField] private Animator planeAnimator;
[Header("Audio")]
    [SerializeField] private AudioSource warnAudio;
    [SerializeField] private string warnClip;
    [SerializeField] private float warnAhead = 8;
    [SerializeField] private float warnStep = 4;
    
    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private Vector3 forwardVel;
    private Vector3 fallingVel;
    private Vector3 currentRotateVel;
    private float targetRotateAngle;
    private float currentRotateAngle;
    private float targetLevelAngle;
    private float currentLevelAngle;
    private float currentAngularSpeed;
    private float rotationTimer = 0;
    private float warnTimer = 0;
    private bool isRotating = false;
    private bool flipSuccess = false;
    private CoroutineExcuter warnStopper;

    private const string trigger_shake = "Shake";

    private bool canActivateInput{get{return true;}}
    public float m_externalRotateAngle{get{return externalRotateAngle;}}

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();
        fallingVel = Vector3.zero;
        warnStopper = new CoroutineExcuter(this);
        currentLevelAngle = targetLevelAngle*inputMulti + externalRotateAngle;

        warnTimer = warnAhead;
    }

    void Update()
    {
        float targetAngle = Service.LerpValue(currentLevelAngle, targetLevelAngle*inputMulti+externalRotateAngle, Time.deltaTime*agility, 0.1f);
        currentLevelAngle = currentLevelAngle + Mathf.Clamp(targetAngle-currentLevelAngle, -maxAngleStep, maxAngleStep);
        
        planeRenderTrans.localRotation = Quaternion.Euler(0,0,-Vector2.SignedAngle(transform.forward, Vector2.right));
        forwardVel = Quaternion.Euler(0, 0, currentLevelAngle)*Vector3.right;

        if(isRotating){
            rotationTimer += Time.deltaTime;
            warnTimer += Time.deltaTime;
            targetRotateAngle = rotationTimer*currentAngularSpeed*Mathf.Rad2Deg;

            if(warnTimer >= warnStep){
                warnTimer = 0;
                AudioManager.Instance.PlaySoundEffect(warnAudio, warnClip, 1);
            }
        }

        targetAngle = Service.LerpValue(currentRotateAngle, targetRotateAngle, Time.deltaTime*agility);
        currentRotateAngle = currentRotateAngle + Mathf.Clamp(targetAngle-currentRotateAngle, -maxAngleStep, maxAngleStep);
        if(!flipSuccess && Mathf.Abs(currentRotateAngle)>=360){
            flipSuccess = true;
            EventHandler.Call_OnFlipComplete();
        }
        currentRotateVel = Quaternion.Euler(0,0,currentLevelAngle+currentRotateAngle)*Vector3.right;
    }
    void FixedUpdate(){
        Vector3 totalVel = (currentRotateVel*rotateToForwardRatio + forwardVel).normalized * flyingSpeed;
        m_rigid.rotation = Quaternion.Euler(Vector3.SignedAngle(totalVel, Vector3.right, Vector3.forward),90,0);
        m_rigid.velocity = totalVel + fallingVel;
    }
    public void SetExternalAngle(float angle)=>externalRotateAngle = angle;

#region Animation
    public void ShakePlane(){
        planeAnimator.SetTrigger(trigger_shake);
    }
#endregion
    public void StartFalling(float fallingSpeed){
        StartCoroutine(coroutineIncreaseFallingSpeed(fallingSpeed, 4f));
        StartCoroutine(coroutineDecreaseRotateFactor(0.5f, 15f));
    }
    IEnumerator coroutineIncreaseFallingSpeed(float targetSpeed, float duration){
        yield return new WaitForLoop(duration, (t)=>{
            inputMulti = Mathf.Lerp(1, 0.2f, t);
            fallingVel = Vector3.down * Mathf.Lerp(0, targetSpeed, t);
        });
    }
    IEnumerator coroutineDecreaseRotateFactor(float targetFactor, float duration){
        float initFactor = rotateToForwardRatio;
        yield return new WaitForLoop(duration, (t)=>{
            rotateToForwardRatio = Mathf.Lerp(initFactor, targetFactor, t);
        });
    }
#region Input
    public void SwitchInput(bool isActivated){
        if(isActivated && canActivateInput) playerInput.ActivateInput();
        else {
            playerInput.DeactivateInput();
            warnStopper.Excute(CommonCoroutine.delayAction(()=>warnAudio.Stop(),1f));
        }
    }
    void OnRotation(InputValue inputValue){
        float input = inputValue.Get<float>();
        currentAngularSpeed = -input * angularSpeed;

        if(input == 0) {
            isRotating = false;
            rotationTimer = 0;
            targetRotateAngle = 0;
            currentRotateAngle = currentRotateAngle-Mathf.FloorToInt(currentRotateAngle/360)*360;
            if(currentRotateAngle>180) currentRotateAngle = currentRotateAngle-360;

            warnStopper.Excute(CommonCoroutine.delayAction(()=>{
                warnAudio.Stop();
                warnTimer = warnAhead;},1f));
        }
        else{
            isRotating = true;
            warnStopper.Abort();
        }
    }
    void OnLevel(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetLevelAngle = input * maxCorrectionAngle;
    }
#endregion
}
