using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationOffset : MonoBehaviour
{
    [SerializeField] private Animator m_animation;
    [SerializeField] private float offset;
    [SerializeField] private float speedMulti = 1;
    void Start()
    {
        m_animation.SetFloat("Offset", offset);
        m_animation.SetFloat("SpeedMulti", speedMulti);
    }
}
