using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicDetector<T> where T: MonoBehaviour
{
    [SerializeField] private Transform detectCenter;
    [SerializeField, ShowOnly] private List<T> pendingTargerts;

    private T currentTarget;

    private bool isDetecting;
    public void StopDetecting(){
        isDetecting = false;
        SwapTarget(null);
    }
    public void StartDetecting(){
        isDetecting = true;
        TryAssignNewTarget();
    }
    public void RegisterPendingTarget(T pendingTarget){
        if(!pendingTargerts.Contains(pendingTarget)){
            pendingTargerts.Add(pendingTarget);

            TryAssignNewTarget(pendingTarget);
        }
    }
    public void UnregisterPendingTarget(T pendingTarget){
        if(pendingTargerts.Contains(pendingTarget)){
            pendingTargerts.Remove(pendingTarget);

            TryAssignNewTarget();
        }
    }
    void TryAssignNewTarget(T testingTarget){
        if(!isDetecting) return;

        if(currentTarget==null) SwapTarget(testingTarget);
        else if(Vector3.Distance(testingTarget.transform.position, detectCenter.position) < Vector3.Distance(currentTarget.transform.position, detectCenter.position)){
            SwapTarget(testingTarget);
        }
    }
    void TryAssignNewTarget(){
        if(!isDetecting) return;

        float distance = Mathf.Infinity;
        T result = null;
        foreach(T interactable in pendingTargerts){
            if(Vector3.Distance(detectCenter.position, interactable.transform.position) < distance){
                distance = Vector3.Distance(detectCenter.position, interactable.transform.position);
                result = interactable;
            }
        }
        SwapTarget(result);
    }
    private void SwapTarget(T newTarget){
        currentTarget = newTarget;
    }
}
