using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ConductControl : MonoBehaviour
{
    [SerializeField] private Animator conductorAnime;
    
    private const string bool_leftHand = "leftHand";
    private const string bool_rightHand = "rightHand";
    private const string bool_upHand = "upHand";
    private const string trigger_hold = "Hold";

    public void Finish(){
        GetComponent<PlayerInput>().DeactivateInput();
        conductorAnime.SetBool(bool_rightHand, false);
        conductorAnime.SetBool(bool_leftHand, false);

        conductorAnime.SetTrigger(trigger_hold);
    }
#region Input Event
    void OnLeft(InputValue inputValue){
        bool leftHand = inputValue.isPressed;
        conductorAnime.SetBool(bool_leftHand, leftHand);

        EventHandler.Call_OnConductDirection(leftHand?1:-1);
    }
    void OnRight(InputValue inputValue){
        bool rightHand = inputValue.isPressed;
        conductorAnime.SetBool(bool_rightHand, rightHand);

        EventHandler.Call_OnConductDirection(rightHand?-1:1);
    }
    void OnUp(InputValue inputValue){
        bool upHand = inputValue.isPressed;
        conductorAnime.SetBool(bool_upHand,upHand);

        EventHandler.Call_OnConductForward(upHand);
    }
#endregion
}
