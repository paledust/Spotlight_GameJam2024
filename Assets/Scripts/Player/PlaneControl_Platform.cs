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

    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private Vector3 forwardVel;
    private Vector3 targetRotateVel;
    private Vector3 currentRotateVel;
    private float targetCorrectionAngle;
    private float currentCorretionAngle;
    private float currentAngularSpeed;
    private float rotationTimer = 0;
    private bool isRotating = false;
    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        currentCorretionAngle = Service.LerpValue(currentCorretionAngle, targetCorrectionAngle, Time.deltaTime*agility, 0.1f);
        
        planeRenderTrans.localRotation = Quaternion.Euler(0,0,Vector2.SignedAngle(transform.forward, Vector2.right));
        forwardVel = Quaternion.Euler(0, 0, currentCorretionAngle)*Vector3.right;

        if(isRotating){
            rotationTimer += Time.deltaTime;
            targetRotateVel = Mathf.Cos(rotationTimer*currentAngularSpeed)*(Quaternion.Euler(0,0,targetCorrectionAngle)*Vector3.right) + Mathf.Sin(rotationTimer*currentAngularSpeed)*(Quaternion.Euler(0,0,targetCorrectionAngle)*Vector3.up);
        }
        else{
            targetRotateVel = Vector3.zero;
        }

        currentRotateVel = Service.LerpVector(currentRotateVel, targetRotateVel, Time.deltaTime*agility);
    }
    void FixedUpdate(){
        Vector3 totalVel = (currentRotateVel*rotateToForwardRatio + forwardVel).normalized * flyingSpeed;
        m_rigid.rotation = Quaternion.LookRotation(totalVel, Vector3.up);
        m_rigid.velocity = totalVel;
    }
#region Input
    void OnRotation(InputValue inputValue){
        float input = inputValue.Get<float>();
        currentAngularSpeed = -input * angularSpeed;

        if(input == 0) {
            isRotating = false;
            rotationTimer = 0;
        }
        else
            isRotating = true;
    }
    void OnLevel(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetCorrectionAngle = input * maxCorrectionAngle;
    }
#endregion
}
