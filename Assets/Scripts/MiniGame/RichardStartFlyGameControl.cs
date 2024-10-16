using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RichardStartFlyGameControl : MonoBehaviour
{
    [SerializeField] private FloatingMotionGroup leftMotionGroup;
    [SerializeField] private FloatingMotionGroup rightMotionGroup;
    void OnLeft(InputValue inputValue){
        if(inputValue.isPressed)
            leftMotionGroup.StrongMotion();
        else
            leftMotionGroup.weakMotion();
    }
    void OnRight(InputValue inputValue){
        if(inputValue.isPressed)
            rightMotionGroup.StrongMotion();
        else
            rightMotionGroup.weakMotion();
    }
    void OnUp(InputValue inputValue){

    }
}
