using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StopSign : MonoBehaviour
{
    public GameObject particlePrefab;
    public GameObject stopSign;

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
            stopSign.GetComponent<Animation>().Play();
            other.GetComponent<PlaneControl_Free>().ShakePlaneForItem();
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return new WaitForSeconds(0.5f);
        GameObject obj = Instantiate(particlePrefab, transform.position, Quaternion.identity);
        obj.transform.parent = player.transform;
        yield return new WaitForSeconds(1f);
        Destroy(gameObject);
    }
}
