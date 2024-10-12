using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class IK_Control:MonoBehaviour
{
    [SerializeField] private bool isLeft;
    [SerializeField] private Transform Root;
    [SerializeField] private Transform joint_A;
    [SerializeField] private Transform joint_B;
    [SerializeField] private Transform joint_C;
    [SerializeField] private Transform IK_target;

    private Quaternion initJointA_Rot;
    private Quaternion initJointB_Rot;
    private float length0;
    private float length1;
    private float length0_pow;
    private float length1_pow;

    void Start(){
        initJointA_Rot = joint_A.localRotation;
        initJointB_Rot = joint_B.localRotation;

        length0 = Vector3.Distance(joint_A.position, joint_B.position);
        length1 = Vector3.Distance(joint_B.position, joint_C.position);

        length0_pow = length0 * length0;
        length1_pow = length1 * length1;
    }
    void Update()
    {
        float length2 = Vector3.Distance(joint_A.position, IK_target.position);
        float length2_pow = length2 * length2;
        Vector3 diff = Root.InverseTransformVector(IK_target.position - joint_A.position);
        float atan = -Mathf.Atan2(diff.y, (isLeft?-1:1)*diff.x) * Mathf.Rad2Deg;
        float jointAngle_a = 0;
        float jointAngle_b = 0;

        if((length0 + length1) < length2){
            jointAngle_a = atan;
            jointAngle_b = 0f;
        }
        else{
            float cos_a = (length2_pow + length0_pow - length1_pow)/(2*length2*length0);
            float angle_a = Mathf.Acos(cos_a) * Mathf.Rad2Deg;
            float cos_b = (length1_pow + length0_pow - length2_pow)/(2*length1*length0);
            float angle_b = Mathf.Acos(cos_b) * Mathf.Rad2Deg;
            jointAngle_a = angle_a + atan;
            jointAngle_b = angle_b - 180;
        }

        joint_A.transform.rotation = Quaternion.Euler(Vector3.forward*(isLeft?1:-1)*jointAngle_a) * joint_A.parent.rotation * initJointA_Rot;
        joint_B.transform.rotation = Quaternion.Euler(Vector3.forward*(isLeft?1:-1)*jointAngle_b) * joint_B.parent.rotation * initJointB_Rot;
    }
    void OnDrawGizmos(){
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(joint_A.position, joint_B.position);
        Gizmos.DrawLine(joint_B.position, joint_C.position);
        Gizmos.color = Color.green;
        Gizmos.DrawLine(joint_A.position, joint_C.position);
        DebugExtension.DrawPoint(IK_target.position, Color.yellow, 0.2f);
    }
}
