using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(PlayerInput), typeof(Rigidbody))]
public class PlaneControl_Platform : MonoBehaviour
{
[Header("Rotation")]
    [SerializeField] private float maxRotateSpeed = 120;
    [SerializeField, Tooltip("控制输入反应速度")] private float agility = 5;
[Header("Correction Help")]
    [SerializeField] private float maxCorrectionAngle = 30;
    [SerializeField] private Transform planeRenderTrans;
    [SerializeField] private float flyingSpeed = 5;

    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private float corretionAngle;
    private float targetCorrectionAngle;
    private float targetRotateSpeed;
    private float currentRotateSpeed;
    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        currentRotateSpeed = Service.LerpValue(currentRotateSpeed, targetRotateSpeed, Time.deltaTime*agility);
        corretionAngle = Service.LerpValue(corretionAngle, targetCorrectionAngle, Time.deltaTime*agility);
        
        planeRenderTrans.localRotation = Quaternion.Euler(0,0,Vector2.SignedAngle(transform.forward, Vector2.right));
    }
    void FixedUpdate(){
        m_rigid.rotation *= Quaternion.Euler(currentRotateSpeed*Time.fixedDeltaTime,0,0);
        m_rigid.velocity = m_rigid.rotation*Vector3.forward*flyingSpeed;
    }
#region Input
    void OnRotation(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetRotateSpeed = input * maxRotateSpeed;
    }
    void OnLevel(InputValue inputValue){
        float input = inputValue.Get<float>();
        targetCorrectionAngle = input * maxCorrectionAngle;
    }
#endregion
}
