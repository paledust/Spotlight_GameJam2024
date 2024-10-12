using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class IK_Control:MonoBehaviour
{
    [SerializeField] private Transform joint_A;
    [SerializeField] private Transform joint_B;
    [SerializeField] private Transform joint_C;
    [SerializeField] private Transform IK_target;

    private float length0;
    private float length1;
    private float length0_pow;
    private float length1_pow;

    void Start(){
        length0 = Vector3.Distance(joint_A.position, joint_B.position);
        length1 = Vector3.Distance(joint_B.position, joint_C.position);

        length0_pow = length0 * length0;
        length1_pow = length1 * length1;
    }
    void Update()
    {
        float length2 = Vector3.Distance(joint_A.position, IK_target.position);
        float length2_pow = length2 * length2;
        Vector3 diff = IK_target.position - joint_A.position;
        float atan = Mathf.Atan2(diff.x, diff.z) * Mathf.Rad2Deg;
        float jointAngle_a = 0;
        float jointAngle_b = 0;

        if(length0 + length1 < length2){
            jointAngle_a = atan;
            jointAngle_b = 0f;
        }
        else{
            float cos_a = (length2_pow + length0_pow - length1_pow)/(2*length2*length0);
            float angle_a = -Mathf.Acos(cos_a) * Mathf.Rad2Deg;
            float cos_b = (length1_pow + length0_pow - length2_pow)/(2*length1*length0);
            float angle_b = -Mathf.Acos(cos_b) * Mathf.Rad2Deg;
            jointAngle_a = atan - angle_a;
            jointAngle_b = 180f - angle_b;
        }

        Vector3 euler_a = joint_A.transform.localEulerAngles;
        euler_a.y = jointAngle_a;
        joint_A.transform.localEulerAngles = euler_a;

        Vector3 euler_b = joint_B.transform.localEulerAngles;
        euler_b.y = jointAngle_b;
        joint_B.transform.localEulerAngles = euler_b;
    }
}
