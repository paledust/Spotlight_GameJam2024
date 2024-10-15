using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RichardPlayGameControl : MonoBehaviour
{
[Header("Space Shuttle")]
    [SerializeField] private Transform spaceShuttleTrans;
    [SerializeField] private float moveSpeed;
    [SerializeField] private float maxMoveDist;
[Header("Richard")]
    [SerializeField] private Transform richardBody;
    void OnMove(InputValue inputValue){
        Vector2 value = inputValue.Get<Vector2>();
        
    }
}
