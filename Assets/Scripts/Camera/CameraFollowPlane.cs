using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollowPlane : MonoBehaviour
{
    [SerializeField] private float rotationAgility = 5f;
    [SerializeField] private float positionAgility = 5f;
    [SerializeField] private Transform trackingTarget;
    private Vector3 initOffset;
    private Quaternion initRotation;
    void Start()
    {
        initOffset = transform.position - trackingTarget.position;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 targetPos = trackingTarget.position + initOffset;
        if(transform.position != targetPos)
            transform.position = Service.LerpVector(transform.position, targetPos, positionAgility*Time.deltaTime);
    }
}
