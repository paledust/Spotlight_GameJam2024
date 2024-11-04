using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TEST_TrailColorTrigger : MonoBehaviour
{
    [SerializeField, ColorUsage(false)] private Color targetColor;
    void OnTriggerEnter(Collider other){
        if(other.tag == Service.PLAYER_TAG){
            GetComponent<Collider>().enabled = false;

            var planeControl = other.GetComponent<PlaneControl_Free>();
            planeControl.FadeTrailColor(targetColor, 1);
        }
    }
}
