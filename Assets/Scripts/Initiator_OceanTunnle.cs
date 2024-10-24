using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class Initiator_OceanTunnle : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera cm_start;
    void Start()
    {
        StartCoroutine(CommonCoroutine.delayAction(()=>cm_start.enabled = false, 0.1f));
    }
}
