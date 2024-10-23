using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowTrans : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private bool initOffset;
    [SerializeField] private bool XAxis;
    [SerializeField] private bool YAxis;
    [SerializeField] private bool ZAxis;

    private Vector3 offset;

    void Start()
    {
        offset = transform.position - target.position;
    }
    void Update()
    {
        Vector3 tempPos = target.position + (initOffset?offset:Vector3.zero);
        if(!XAxis) tempPos.x = transform.position.x;
        if(!YAxis) tempPos.y = transform.position.y;
        if(!ZAxis) tempPos.z = transform.position.z;
        
        transform.position = tempPos;
    }
}
