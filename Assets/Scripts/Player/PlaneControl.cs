using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(PlayerInput))]
public class PlaneControl : MonoBehaviour
{
    [SerializeField] private float maxPitchSpeed;
    [SerializeField] private float maxRollSpeed;
    [SerializeField] private float agility = 5;
    [SerializeField] private float flyingSpeed;

    private Rigidbody m_rigid;
    private PlayerInput playerInput;
    private float targetPitchSpeed;
    private float targetRollSpeed;
    private float currentPitchSpeed;
    private float currentRollSpeed;

    void Awake(){
        playerInput = GetComponent<PlayerInput>();
        m_rigid = GetComponent<Rigidbody>();
    }
    void Start()
    {
        currentPitchSpeed = targetPitchSpeed = currentRollSpeed = targetRollSpeed = 0;
    }
    void Update(){
    //平滑改变飞行姿态
        {
            float _s = Time.deltaTime*agility;
            if(currentPitchSpeed!=targetPitchSpeed)
                currentPitchSpeed = Service.LerpValue(currentPitchSpeed, targetPitchSpeed, _s);
            if(currentRollSpeed!=targetRollSpeed)
                currentRollSpeed = Service.LerpValue(currentRollSpeed, targetRollSpeed, _s);
        }
        
        
    }
    void FixedUpdate(){
        m_rigid.MoveRotation(m_rigid.rotation*Quaternion.Euler(currentPitchSpeed*Time.fixedDeltaTime, 0, currentRollSpeed*Time.fixedDeltaTime));
        m_rigid.velocity = m_rigid.transform.forward*flyingSpeed;
    }
#region Input
    void OnMove(InputValue inputValue){
        Vector2 input = inputValue.Get<Vector2>();
        targetPitchSpeed = input.y * maxPitchSpeed;
        targetRollSpeed = -input.x * maxRollSpeed;
    }
#endregion
}
