using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RichardPlayGameControl : MonoBehaviour
{
[Header("Space Shuttle")]
    [SerializeField] private Transform spaceShuttleTrans;
    [SerializeField] private float moveSpeed;
    [SerializeField] private float maxMoveDist;
[Header("Richard")]
    [SerializeField] private Transform richardFaceDir;
    [SerializeField] private Transform richardBody;
    [SerializeField] private float maxRoll;
    [SerializeField] private float maxPitch;
[Header("End Time")]
    [SerializeField] private float endTime = 0;
    
    private Vector3 shuttleVel;
    private float targetPitch;
    private float targetRoll;
    private float pitch = 0;
    private float roll = 0;

    void Start(){
    }
    void Update(){
    //控制理查的身体晃动
        pitch = Service.LerpValue(pitch, targetPitch, Time.deltaTime*5);
        roll = Service.LerpValue(roll, targetRoll, Time.deltaTime*5);

        richardBody.localRotation = Quaternion.AngleAxis(roll, richardFaceDir.forward)*Quaternion.AngleAxis(pitch, richardFaceDir.right);
    //控制飞机的飞行
        Vector3 position = spaceShuttleTrans.localPosition;
        position += shuttleVel*Time.deltaTime;
        position.x = Mathf.Clamp(position.x, -maxMoveDist, maxMoveDist);
        position.y = Mathf.Clamp(position.y, -maxMoveDist, maxMoveDist);
        spaceShuttleTrans.localPosition = position;

    }
    void OnMove(InputValue inputValue){
        Vector2 value = inputValue.Get<Vector2>();
        shuttleVel = value*moveSpeed;

        targetPitch = value.y * maxPitch;
        targetRoll = -value.x * maxRoll;
    }
}
