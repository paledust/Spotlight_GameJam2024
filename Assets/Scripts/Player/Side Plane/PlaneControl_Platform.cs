using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(PlayerInput), typeof(Rigidbody))]
public class PlaneControl_Platform : MonoBehaviour
{
    [SerializeField, Tooltip("控制输入反应速度")] private float agility = 5;
[Header("Correction Help")]
    [SerializeField] private Transform planeRenderTrans;
    [SerializeField] private float maxCorrectionAngle = 30;
    [SerializeField] private float flyingSpeed = 5;
    [SerializeField] private float angularSpeed = 2;
    [SerializeField] private float rotateToForwardRatio = 1.5f;
    [SerializeField] private float externalRotateAngle;

    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private Vector3 forwardVel;
    private Vector3 currentRotateVel;
    private float targetRotateAngle;
    private float currentRotateAngle;
    private float targetLevelAngle;
    private float currentLevelAngle;
    private float currentAngularSpeed;
    private float rotationTimer = 0;
    private bool isRotating = false;

    private bool canActivateInput{get{return true;}}
    public float m_externalRotateAngle{get{return externalRotateAngle;}}

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();
        currentLevelAngle = targetLevelAngle + externalRotateAngle;
    }

    // Update is called once per frame
    void Update()
    {
        currentLevelAngle = Service.LerpValue(currentLevelAngle, targetLevelAngle+externalRotateAngle, Time.deltaTime*agility, 0.1f);
        
        planeRenderTrans.localRotation = Quaternion.Euler(0,0,-Vector2.SignedAngle(transform.forward, Vector2.right));
        forwardVel = Quaternion.Euler(0, 0, currentLevelAngle)*Vector3.right;

        if(isRotating){
            rotationTimer += Time.deltaTime;
            targetRotateAngle = rotationTimer*currentAngularSpeed*Mathf.Rad2Deg;
        }

        currentRotateAngle = Service.LerpValue(currentRotateAngle, targetRotateAngle, Time.deltaTime*agility);
        currentRotateVel = Quaternion.Euler(0,0,currentLevelAngle+currentRotateAngle)*Vector3.right;
    }
    void FixedUpdate(){
        Vector3 totalVel = (currentRotateVel*rotateToForwardRatio + forwardVel).normalized * flyingSpeed;
        m_rigid.rotation = Quaternion.Euler(Vector3.SignedAngle(totalVel, Vector3.right, Vector3.forward),90,0);
        m_rigid.velocity = totalVel;
    }
    public void SetExternalAngle(float angle)=>externalRotateAngle = angle;
#region Input
    public void SwitchInput(bool isActivated){
        if(isActivated && canActivateInput) playerInput.ActivateInput();
        else playerInput.DeactivateInput();
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
        }
        else{
            isRotating = true;
        }
    }
    void OnLevel(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetLevelAngle = input * maxCorrectionAngle;
    }
#endregion
}
