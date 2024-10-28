using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class Balloon : MonoBehaviour
{
    public GameObject balloonPic;
    public GameObject urchinPic;
    public AudioSource audioSource1;
    public AudioSource audioSource2;
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
        AudioManager.Instance.PlaySoundEffect(audioSource1, "sfx_cat", 1f);
        yield return new WaitForSeconds(0.08f);
        AudioManager.Instance.PlaySoundEffect(audioSource2, "sfx_balloon", 1f);
        balloonPic.GetComponent<Animator>().SetTrigger("Balloon");
        player.GetComponent<PlaneControl_Free>().ShakePlaneForItem();
        yield return new WaitForSeconds(3f);
        Destroy(gameObject);
    }
}
