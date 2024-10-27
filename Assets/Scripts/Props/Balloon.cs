using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Balloon : MonoBehaviour
{
    public GameObject balloonPic;
    public GameObject urchinPic;
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
            StartCoroutine(Explode(other.gameObject));
        }
    }

    private IEnumerator Explode(GameObject player)
    {
        urchinPic.SetActive(true);
        urchinPic.GetComponent<Animation>().Play();
        yield return new WaitForSeconds(0.08f);
        balloonPic.GetComponent<Animator>().SetTrigger("Balloon");
        player.GetComponent<PlaneControl_Free>().ShakePlaneForItem();
        yield return new WaitForSeconds(1f);
        Destroy(gameObject);
    }
}
