using System.Collections;
using System.Collections.Generic;
using SimpleAudioSystem;
using UnityEngine;

public class Whale : MonoBehaviour
{
    private AudioSource audioSource;
    // Start is called before the first frame update
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == Service.PLAYER_TAG)
        {
            AudioManager.Instance.PlaySoundEffect(audioSource, "sfx_whale_long", 1f);
        }
    }
}
