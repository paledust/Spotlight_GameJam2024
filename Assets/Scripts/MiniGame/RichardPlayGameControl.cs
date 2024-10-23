#define Demo

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;

public class RichardPlayGameControl : MonoBehaviour
{
    [SerializeField] private PlayerInput playerInput;
[Header("Richard")]
    [SerializeField] private Transform richardFaceDir;
    [SerializeField] private Transform richardBody;
    [SerializeField] private float maxRoll;
    [SerializeField] private float maxPitch;
[Header("Ending")]
    [SerializeField] private PlayableDirector endTimeline;
    [SerializeField] private float DemoMiniGameTime = 20;
    
    private float targetPitch;
    private float targetRoll;
    private float pitch = 0;
    private float roll = 0;
    private float timer = 0;
    private bool isDone = false;
    void OnEnable(){
        EventHandler.E_OnPixelGameFinished += EndGame;
    }
    void OnDisable(){
        EventHandler.E_OnPixelGameFinished -= EndGame;
    }
    void Update(){
    //控制理查的身体晃动
        pitch = Service.LerpValue(pitch, targetPitch, Time.deltaTime*5);
        roll = Service.LerpValue(roll, targetRoll, Time.deltaTime*5);
        richardBody.localRotation = Quaternion.AngleAxis(roll, richardFaceDir.forward)*Quaternion.AngleAxis(pitch, richardFaceDir.right);

        if(!isDone) timer+=Time.deltaTime;
        if(timer > DemoMiniGameTime && !isDone){
            isDone = true;
            targetPitch = 0;
            targetRoll = 0;
            EndGame();
        }
    }
    void EndGame(){
        StartCoroutine(coroutineReturnPos(1.5f, 1f));
        playerInput.DeactivateInput();
        endTimeline.Play();
    }
    void OnMove(InputValue inputValue){
        Vector2 value = inputValue.Get<Vector2>();

        targetPitch = value.y * maxPitch;
        targetRoll = -value.x * maxRoll;
    }

#region Timeline Event
    public void StartGame(){
        this.enabled = true;
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