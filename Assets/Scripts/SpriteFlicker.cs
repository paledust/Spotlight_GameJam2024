using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpriteFlicker : MonoBehaviour
{
    [SerializeField] private SpriteRenderer m_targetSprite;
    [SerializeField] private Color flickerColor;
    [SerializeField] private float flickerFreq;
    private float seed;
    private Color initColor;
    void Start()
    {
        seed = Random.Range(0f, 1f);
        initColor = m_targetSprite.color;        
    }
    void Update()
    {
        m_targetSprite.color = Color.Lerp(initColor, flickerColor, Mathf.PerlinNoise(Time.time*flickerFreq, seed));
    }
}
