using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PixelPlaneControl : MonoBehaviour
{
    public float speed;
    public float acceleration;
    
    private Animator animator;
    private Vector3 targetDirection;
    private Vector3 curDirection;
    private Vector2 input;
    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        curDirection = Vector3.Lerp(curDirection, targetDirection, acceleration * Time.fixedDeltaTime);
        transform.position += curDirection * speed * Time.fixedDeltaTime;
    }

    public void TriggerDamageAnim()
    {
        animator.SetTrigger("Damage");
    }

#region Input
    void OnMove(InputValue inputValue){
        input = inputValue.Get<Vector2>();
        targetDirection = new Vector3(input.x, input.y, 0);
    }
#endregion
}
