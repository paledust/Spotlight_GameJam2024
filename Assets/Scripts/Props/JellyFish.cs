using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JellyFish : MonoBehaviour
{
    public GameObject fish;
    public float boostSpeed;
    public float boostTime;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < fish.transform.childCount; i++)
        {
            fish.transform.GetChild(i).GetComponent<Animator>().Play("JellyFish" + Random.Range(0, 4), 0, Random.Range(0f, 1f));
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == Service.PLAYER_TAG)
        {
            other.GetComponent<PlaneControl_Free>().boostSpeed = boostSpeed;
            fish.SetActive(false);
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return new WaitForSeconds(boostTime);
        player.GetComponent<PlaneControl_Free>().boostSpeed = 0;
        yield return new WaitForSeconds(0.5f);
        Destroy(gameObject);
    }
}
