using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(PlaneControl_Free))]
public class PlaneOnCollide : MonoBehaviour
{
    [SerializeField] private PlaneControl_Free planeControl_Free;
    void Awake(){
        planeControl_Free = GetComponent<PlaneControl_Free>();
    }
    void OnCollisionEnter(Collision collision){
        planeControl_Free.OnCollide(collision);
    }
}
