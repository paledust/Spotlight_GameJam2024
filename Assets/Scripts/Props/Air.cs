using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Air : MonoBehaviour
{
    public GameObject particlePrefab;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == Service.PLAYER_TAG)
        {
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return null;
        GameObject obj = Instantiate(particlePrefab, transform.position, Quaternion.identity);
        obj.transform.parent = player.transform;
        Destroy(gameObject);
    }
}
