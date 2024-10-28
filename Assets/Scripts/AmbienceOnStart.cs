using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class AmbienceOnStart : MonoBehaviour
{
    [SerializeField] private string ambienceName;
    [SerializeField] private float delay = 0;
    [SerializeField, Range(0, 1)] private float volume;
    [SerializeField] private float transitionTime;
    void Start()
    {
        StartCoroutine(CommonCoroutine.delayAction(()=> AudioManager.Instance.PlayAmbience(ambienceName, true, transitionTime, volume), delay));
    }
}
