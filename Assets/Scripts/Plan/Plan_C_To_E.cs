using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class Plan_C_To_E : MonoBehaviour
{
    [SerializeField] private PlayableDirector TL_AboveSky;
    void Start(){
        EventHandler.E_OnFlyAboveSky += OnFlyAboveSkyHandler;
    }
    void OnEnable(){
        EventHandler.E_OnFlyAboveSky -= OnFlyAboveSkyHandler;
    }
    void OnFlyAboveSkyHandler(){
        TL_AboveSky.Play();
    }
    public void TimelineEvent_GoToNextLevel(){
        GameManager.Instance.SwitchingScene(Service.FALL, 1f, Color.white);
    }
}
