using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;
using SimpleAudioSystem;

public class Birds : MonoBehaviour
{
    public AudioSource audioSource1;
    public AudioSource audioSource2;
    public List<Sprite> birdThingsSmall;
    public List<Sprite> birdThingsBig;
    public GameObject birdThingSmallPrefab;
    public GameObject birdThingBigPrefab;
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
            AudioManager.Instance.PlaySoundEffect(audioSource1, "sfx_pi", 1f);
            AudioManager.Instance.PlaySoundEffect(audioSource2, "group_bird", 1f);
            GameObject canvas = Camera.main.transform.Find("InGameCanvas").gameObject;
            GameObject obj = Instantiate(birdThingSmallPrefab, canvas.transform);
            obj.GetComponent<Image>().sprite = birdThingsSmall[Random.Range(0, birdThingsSmall.Count)];
            obj.transform.position += new Vector3(Random.Range(-600f, 600f), Random.Range(-300f, 300f), 0f);
            for (int i = 0; i < Random.Range(1, 5); i++)
            {
                StartCoroutine(CreateBirdThingSmall());
            }
            for (int i = 0; i < Random.Range(1, 3); i++)
            {
                StartCoroutine(CreateBirdThingBig());
            }
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator CreateBirdThingSmall()
    {
        yield return new WaitForSeconds(Random.Range(0.25f, 1.5f));
        AudioManager.Instance.PlaySoundEffect(audioSource2, "group_bird", 1f);
        GameObject canvas = Camera.main.transform.Find("InGameCanvas").gameObject;
        GameObject obj = Instantiate(birdThingSmallPrefab, canvas.transform);
        obj.GetComponent<Image>().sprite = birdThingsSmall[Random.Range(0, birdThingsSmall.Count)];
        obj.transform.position += new Vector3(Random.Range(-600f, 600f), Random.Range(-300f, 300f), 0f);
        yield return new WaitForSeconds(7f);
        Destroy(obj);
    }

    private IEnumerator CreateBirdThingBig()
    {
        yield return new WaitForSeconds(Random.Range(1f, 2f));
        AudioManager.Instance.PlaySoundEffect(audioSource2, "group_bird", 1f);
        GameObject canvas = Camera.main.transform.Find("InGameCanvas").gameObject;
        GameObject obj = Instantiate(birdThingBigPrefab, canvas.transform);
        obj.GetComponent<Image>().sprite = birdThingsBig[Random.Range(0, birdThingsBig.Count)];
        obj.transform.position += new Vector3(Random.Range(-600f, 600f), Random.Range(-300f, 300f), 0f);
        yield return new WaitForSeconds(7f);
        Destroy(obj);
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return new WaitForSeconds(1f);
        //gameObject.GetComponent<Image>().enabled = false;
        yield return new WaitForSeconds(10f);
        Destroy(gameObject);
    }
}
