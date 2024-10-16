using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;

public class RichardPlayGameControl : MonoBehaviour
{
    [SerializeField] private PlayerInput playerInput;
[Header("Space Shuttle")]
    [SerializeField] private Transform spaceShuttleTrans;
    [SerializeField] private float moveSpeed;
    [SerializeField] private float maxMoveDist;
[Header("Richard")]
    [SerializeField] private Transform richardFaceDir;
    [SerializeField] private Transform richardBody;
    [SerializeField] private float maxRoll;
    [SerializeField] private float maxPitch;
[Header("End Condition")]
    [SerializeField] private float GameDuration = 10;
    [SerializeField] private PlayableDirector endTimeline;
    
    private Vector3 shuttleVel;
    private float targetPitch;
    private float targetRoll;
    private float pitch = 0;
    private float roll = 0;
    private float gameTimer = 0;

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

    //检查结束条件
    //To Do:等正式pixel game出现再替换
        if(Time.time - gameTimer>GameDuration){
            StartCoroutine(coroutineReturnPos(1.5f, 1f));
            playerInput.DeactivateInput();
            endTimeline.Play();
        }
    }
    void OnMove(InputValue inputValue){
        Vector2 value = inputValue.Get<Vector2>();
        shuttleVel = value*moveSpeed;

        targetPitch = value.y * maxPitch;
        targetRoll = -value.x * maxRoll;
    }

#region Timeline Event
    public void StartGame(){
        this.enabled = true;
        gameTimer = Time.time;
        playerInput.ActivateInput();
    }
    public void GoToNextLevel(string level){
        GameManager.Instance.SwitchingScene(level, 1f);
    }
#endregion

    IEnumerator coroutineReturnPos(float wait, float duration){
        yield return new WaitForSeconds(wait);

        float initPitch = pitch;
        float initRoll = roll;
        yield return new WaitForLoop(duration, (t)=>{
            pitch = Mathf.Lerp(initPitch, 0, EasingFunc.Easing.SmoothInOut(t));
            roll = Mathf.Lerp(initRoll, 0, EasingFunc.Easing.SmoothInOut(t));
            richardBody.localRotation = Quaternion.AngleAxis(roll, richardFaceDir.forward)*Quaternion.AngleAxis(pitch, richardFaceDir.right);
        });
    }
}
