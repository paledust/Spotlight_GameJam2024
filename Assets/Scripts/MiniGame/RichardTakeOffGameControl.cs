using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;

public class RichardTakeOffGameControl : MonoBehaviour
{
[Header("Text Control")]
    [SerializeField] private FloatingMotionGroup leftMotionGroup;
    [SerializeField] private Animation leftAnime;
    [SerializeField] private Animation leftLightAnime;
    [SerializeField] private ParticleSystem p_leftBurst;
    [SerializeField] private FloatingMotionGroup rightMotionGroup;
    [SerializeField] private Animation rightAnime;
    [SerializeField] private Animation rightLightAnime;
    [SerializeField] private ParticleSystem p_rightBurst;
[Header("Forward Interaction")]
    [SerializeField, Range(0, 1)] private float powerValue;
    [SerializeField] private float powerUpSpeed = 0.5f;
    [SerializeField] private LoopGroup loopGroup;
[Header("Finish Animation")]
    [SerializeField] private PlayableDirector TL_TakeOff;
    [SerializeField] private Animation dissolveControlAnimation;
    [SerializeField] private Animation forwardLightAnimation;
    [SerializeField] private PerRendererSpriteDissolve forwardDissolve;
    [SerializeField] private Rotator rotator;
    [SerializeField] private Transform powerTransform;
    [SerializeField] private float pushDistance;
[Header("Audio")]
    [SerializeField] private AudioSource m_loopAudio;
    [SerializeField] private AudioSource m_audio;
    [SerializeField] private string magicWooshClip;
    [SerializeField] private string magicChimeClip;
    [SerializeField] private string engineClip;
    [SerializeField] private string takeOffRecordClip;

    private bool leftIsDone = false;
    private bool rightIsDone = false;

    private CoroutineExcuter leftProgresser;
    private CoroutineExcuter rightProgresser;
    private CoroutineExcuter arrowDissolver;
    private Vector3 initPowerPos;
    private bool powerUp = false;

    private const string DissolveMapName = "DissolveInMap";
    private const string DissolveControlName = "DissolveInControl";

    private bool canTakeOff = false;
    private bool isDone = false;
    void Awake(){
        leftProgresser = new CoroutineExcuter(this);
        rightProgresser = new CoroutineExcuter(this);
        arrowDissolver = new CoroutineExcuter(this);
        initPowerPos = powerTransform.localPosition;
    }
    void Update(){
        if(canTakeOff){
            powerValue += Time.deltaTime*(powerUp?powerUpSpeed:0);
            powerTransform.localPosition = Vector3.Lerp(initPowerPos, initPowerPos + powerTransform.forward*pushDistance, powerValue);
            rotator.rotateSpeed = Mathf.Lerp(0, 1500, powerValue);
            loopGroup.targetSpeedMulti = Mathf.Lerp(0, 1, powerValue);

            if(powerValue>=1 && !isDone){
                isDone = true;
                this.enabled = false;
                forwardLightAnimation.Play();
                GetComponent<PlayerInput>().DeactivateInput();
                TL_TakeOff.Play();
            }
        //控制音效
            m_loopAudio.pitch = Mathf.Lerp(0.6f,1,powerValue);
            m_loopAudio.volume = powerValue;
        }
    }
    void OnLeft(InputValue inputValue){
        if(leftIsDone) return;
        if(inputValue.isPressed){
            AudioManager.Instance.PlaySoundEffect(m_audio, magicChimeClip, 1f);
            leftProgresser.Excute(coroutineDissolveText(leftAnime, 2f, 0.5f, ()=>{
                leftIsDone=true;
                leftProgresser.Excute(coroutineDissolveText(leftAnime, 0.2f, 1, null));
                leftLightAnime.Play();

                AudioManager.Instance.PlaySoundEffect(m_audio, magicWooshClip, 1f);

                dissolveControlAnimation.Play(DissolveMapName);
                p_leftBurst.Play(true);

                if(leftIsDone && rightIsDone){
                    AudioManager.Instance.FadeAudio(m_loopAudio, 0f, 0.1f);
                    StartCoroutine(CommonCoroutine.delayAction(()=>AudioManager.Instance.PlaySoundEffectLoop(m_loopAudio, engineClip, 0f, 0.1f), 0.15f));
                    arrowDissolver.Excute(coroutineDissolveForward(1, 1f, 1f, ()=>canTakeOff=true));
                }
            }));
            leftMotionGroup.StrongMotion();
        }
        else{
            leftProgresser.Excute(coroutineDissolveText(leftAnime, 0.5f, 0, null));
            leftMotionGroup.weakMotion();
        }
    }
    void OnRight(InputValue inputValue){
        if(rightIsDone) return;
        if(inputValue.isPressed){
            AudioManager.Instance.PlaySoundEffect(m_audio, magicChimeClip, 1f);
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 2f, 0.5f, ()=>{
                rightIsDone=true;
                rightProgresser.Excute(coroutineDissolveText(rightAnime, 0.2f, 1, null));
                rightLightAnime.Play();

                AudioManager.Instance.PlaySoundEffect(m_audio, magicWooshClip, 1f);

                dissolveControlAnimation.Play(DissolveControlName);
                p_rightBurst.Play(true);

                if(leftIsDone && rightIsDone){
                    AudioManager.Instance.FadeAudio(m_loopAudio, 0f, 0.1f);
                    StartCoroutine(CommonCoroutine.delayAction(()=>AudioManager.Instance.PlaySoundEffectLoop(m_loopAudio, engineClip, 0f, 0.1f), 0.15f));
                    arrowDissolver.Excute(coroutineDissolveForward(1, 1f, 1f, ()=>canTakeOff=true));
                }
            }));
            rightMotionGroup.StrongMotion();
        }
        else{
            rightProgresser.Excute(coroutineDissolveText(rightAnime, 0.5f, 0, null));
            rightMotionGroup.weakMotion();
        }
    }
    void OnUp(InputValue inputValue){
        if(canTakeOff && !isDone){
            powerUp = inputValue.isPressed;
            if(powerUp)
                arrowDissolver.Excute(coroutineDissolveForward(0, 0.25f, 0, null));
            else
                arrowDissolver.Excute(coroutineDissolveForward(0, 1f, 1, null));
        }
    }
#region Timeline Event
    public void TL_PlayRecording()=>RecordingManager.Instance.PlayRecording(takeOffRecordClip);
    public void TL_Event_GoToFlightScene(){
        GameManager.Instance.SwitchingScene(Service.FLYING_ONE, 1);
    }
    public void TL_Event_ChangeEngineSound(){
        AudioManager.Instance.FadeAudio(m_loopAudio, 0, 0.5f, true);
        AudioManager.Instance.PlayMusic("bgm_fly_01", true, 0.5f, 1f);
    }
    public void TL_Event_StartGame(){
        GetComponent<PlayerInput>().enabled = true;
    }
    public void TL_Event_StartWhispering(){
        AudioManager.Instance.PlaySoundEffectLoop(m_loopAudio, "sfx_whispering", 1, 0.5f);
    }
#endregion
    IEnumerator coroutineDissolveText(Animation textAnime, float duration, float target, System.Action OnComplete){
        if(!textAnime.isPlaying) textAnime.Play();
        string clipName = textAnime.clip.name;
        textAnime[clipName].speed = 0;

        float initTime = textAnime[clipName].normalizedTime;
        yield return new WaitForLoop(duration, (t)=>{
            textAnime[clipName].normalizedTime = Mathf.Lerp(initTime, target, EasingFunc.Easing.QuadEaseIn(t));
        });
        OnComplete?.Invoke();
    }
    IEnumerator coroutineDissolveForward(float delay, float duration, float target, System.Action OnComplete){
        yield return new WaitForSeconds(delay);
        float initValue = forwardDissolve.dissolveValue;
        yield return new WaitForLoop(duration, (t)=>{
            forwardDissolve.dissolveValue = Mathf.Lerp(initValue, target, EasingFunc.Easing.SmoothInOut(t));
        });

        OnComplete?.Invoke();
    }
}
