using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;
using SimpleAudioSystem;
public class StopSign : MonoBehaviour
{
    public AudioSource audioSource1;
    public AudioSource audioSource2;
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
            AudioManager.Instance.PlaySoundEffect(audioSource1, "sfx_hand", 1f);
            stopSign.GetComponent<Animation>().Play();
            other.GetComponent<PlaneControl_Free>().ShakePlaneForItem();
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return new WaitForSeconds(0.5f);
        AudioManager.Instance.PlaySoundEffect(audioSource2, "sfx_color", 1f);
        GameObject obj = Instantiate(particlePrefab, transform.position, Quaternion.identity);
        obj.transform.parent = player.transform;
        yield return new WaitForSeconds(1f);
        Destroy(gameObject);
    }
}
