using System.Collections;
using UnityEngine.UI;
using UnityEngine;
using SimpleAudioSystem;
using System.Collections.Generic;
public class HulaCircle : MonoBehaviour
{
    public GameObject circle;
    public List<Sprite> circleSprites;
    public List<Color> circleColors;
    public float circleTime;
    public float trailTime;
    private float timer = 0;
    private int index = 0;
    private bool triggered = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (triggered) return;

        timer += Time.deltaTime;
        if (timer >= circleTime)
        {
            ChangeCircle();
        }
    }

    public void ChangeCircle()
    {
        timer = 0;
        index = (index + 1) % circleSprites.Count;
        circle.GetComponent<SpriteRenderer>().sprite = circleSprites[index];
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == Service.PLAYER_TAG)
        {
            other.GetComponent<PlaneControl_Free>().FadeTrailColor(circleColors[index], 1);
            circle.GetComponent<Animation>().Play();
            triggered = true;
            StartCoroutine(DestroySelf(other.gameObject));
        }
    }

    private IEnumerator DestroySelf(GameObject player)
    {
        yield return new WaitForSeconds(trailTime);
        player.GetComponent<PlaneControl_Free>().FadeTrailColorDefault(1);
        yield return new WaitForSeconds(0.5f);
        Destroy(gameObject);
    }
}
