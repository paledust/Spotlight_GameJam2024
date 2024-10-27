using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Target : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        PixelGameManager.Instance.onRestartGame += Reset;
    }

    void OnDestroy()
    {
        PixelGameManager.Instance.onRestartGame -= Reset;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == Service.PLAYER_TAG)
        {
            PixelGameManager.Instance.AddStar();
            gameObject.SetActive(false);
        }
    }

    void Reset()
    {
        gameObject.SetActive(true);
    }
}
