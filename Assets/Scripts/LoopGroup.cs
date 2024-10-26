using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoopGroup : MonoBehaviour
{
    [SerializeField] private Transform[] loopTranses;
    [SerializeField] private Vector3 moveVelocity;
    public float targetSpeedMulti = 0;
    [SerializeField] private float intersection = 350f;
    [SerializeField] private float recycleLength = 460;
    private float speedMulti = 0;
    private int lastIndex;
    // Start is called before the first frame update
    void Start()
    {
        for(int i=0; i<loopTranses.Length; i++){
            loopTranses[i].localPosition = -moveVelocity.normalized*i*intersection;
        }
        lastIndex = loopTranses.Length-1;
    }

    // Update is called once per frame
    void Update()
    {
        speedMulti = Service.LerpValue(speedMulti, speedMulti, Time.deltaTime*0.1f);
        for(int i=0; i<loopTranses.Length; i++){
            loopTranses[i].localPosition += moveVelocity*speedMulti*Time.deltaTime;

            if(Vector3.Dot(moveVelocity.normalized, loopTranses[i].localPosition)>=recycleLength){
                Debug.Log(Vector3.Dot(moveVelocity, loopTranses[i].localPosition));
                loopTranses[i].localPosition = loopTranses[lastIndex].localPosition - moveVelocity.normalized*intersection;
                lastIndex = i;
            }
        }        
    }
}
