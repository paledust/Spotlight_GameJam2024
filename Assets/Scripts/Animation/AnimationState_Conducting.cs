using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationState_Conducting : StateMachineBehaviour
{
    [SerializeField] private string float_conductOffset = "ConductOffset";
    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateEnter(animator, stateInfo, layerIndex);
        animator.SetFloat(float_conductOffset, Time.time/stateInfo.length-Mathf.FloorToInt(Time.time/stateInfo.length));
    }
    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateExit(animator, stateInfo, layerIndex);
        animator.SetFloat(float_conductOffset, 0);
    }
}
