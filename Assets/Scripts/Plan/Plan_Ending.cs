using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class Plan_Ending : MonoBehaviour
{
    [SerializeField] private PlayableDirector tl_ending;
    void Start()
    {
        tl_ending.Play();
    }
}
