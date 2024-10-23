using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PixelPlaneControl : MonoBehaviour
{
    public float speed;
    public float acceleration;

    public Transform leftBoundary;
    public Transform rightBoundary;
    public Transform topBoundary;
    public Transform bottomBoundary;

    private Vector3 targetDirection;
    private Vector3 curDirection;
    private Vector2 input;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (PixelGameManager.Instance.gameStart)
        {
            curDirection = Vector3.Lerp(curDirection, targetDirection, acceleration * Time.fixedDeltaTime);
            Vector3 newPos = transform.position + curDirection * speed * Time.fixedDeltaTime;
            newPos.x = Mathf.Clamp(newPos.x, leftBoundary.position.x, rightBoundary.position.x);
            newPos.y = Mathf.Clamp(newPos.y, bottomBoundary.position.y, topBoundary.position.y);
            transform.position = newPos;
        }
        else
        {
            curDirection = Vector3.zero;
            targetDirection = Vector3.zero;
        }
    }

#region Input
    void OnMove(InputValue inputValue){
        input = inputValue.Get<Vector2>();
        targetDirection = new Vector3(input.x, input.y, 0);
    }
#endregion
}
