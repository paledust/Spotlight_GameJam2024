using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ConductControl : MonoBehaviour
{
    [SerializeField] private Animator conductorAnime;
    
    private const string bool_leftHand = "leftHand";
    private const string bool_rightHand = "rightHand";

    void OnLeft(InputValue inputValue){
        bool leftHand = inputValue.isPressed;
        conductorAnime.SetBool(bool_leftHand, leftHand);
    }
    void OnRight(InputValue inputValue){
        bool rightHand = inputValue.isPressed;
        conductorAnime.SetBool(bool_rightHand, rightHand);
    }
}
