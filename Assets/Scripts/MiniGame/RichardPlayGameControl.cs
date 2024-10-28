using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
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
[Header("Audio")]
    [SerializeField] private AudioSource m_audio;
    
    private float targetPitch;
    private float targetRoll;
    private float pitch = 0;
    private float roll = 0;
    private bool isGaming = false;

    void OnEnable(){
        EventHandler.E_OnPixelGameFinished += EndGame;
    }
    void OnDisable(){
        EventHandler.E_OnPixelGameFinished -= EndGame;
    }
    void Start(){
        AudioManager.Instance.PlaySoundEffectLoop(m_audio, "sfx_gaming", 0, 0.1f);
    }
    void Update(){
    //控制理查的身体晃动
        pitch = Service.LerpValue(pitch, targetPitch, Time.deltaTime*5);
        roll = Service.LerpValue(roll, targetRoll, Time.deltaTime*5);
        richardBody.localRotation = Quaternion.AngleAxis(roll, richardFaceDir.forward)*Quaternion.AngleAxis(pitch, richardFaceDir.right);
    //控制声效播放
        if(targetPitch!=0||targetRoll!=0){
            if(!isGaming){
                isGaming = true;
                AudioManager.Instance.FadeAudio(m_audio, 1, 0.1f);
            }
        }
        else{
            if(isGaming){
                isGaming = false;
                AudioManager.Instance.FadeAudio(m_audio, 0, 0.1f, false);
            }
        }
    }
    void EndGame(){
        StartCoroutine(coroutineReturnPos(1.5f, 1f));
        playerInput.DeactivateInput();
        endTimeline.Play();

        AudioManager.Instance.FadeAudio(m_audio, 0, 0.1f, true);
    }
    void OnMove(InputValue inputValue){
        Vector2 value = inputValue.Get<Vector2>();

        targetPitch = -value.y * maxPitch;
        targetRoll = -value.x * maxRoll;
    }

#region Timeline Event
    public void StartGame(){
        this.enabled = true;
        playerInput.ActivateInput();
    }
    public void GoToNextLevel(){
        GameManager.Instance.SwitchingScene(Service.TAKE_OFF, 1f);
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