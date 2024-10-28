using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PropPoint : MonoBehaviour
{
    public List<GameObject> props;
    public float distance;

    void Update()
    {
        GameObject player = GameObject.FindWithTag(Service.PLAYER_TAG);
        if (Vector3.Distance(transform.position, player.transform.position) < distance)
        {
            Instantiate(props[Random.Range(0, props.Count)], transform.position, transform.rotation);
            Destroy(gameObject);
        }
    }
}
