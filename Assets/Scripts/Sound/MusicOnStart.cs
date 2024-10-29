using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class MusicOnStart : MonoBehaviour
{
    [SerializeField] private string musicName;
    [SerializeField] private float delay = 0;
    [SerializeField, Range(0, 1)] private float volume;
    [SerializeField] private float transitionTime;
    void Start()
    {
        StartCoroutine(CommonCoroutine.delayAction(()=> AudioManager.Instance.PlayMusic(musicName, true, transitionTime, volume), delay));
    }
}
