using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloatingMotion : MonoBehaviour
{
    public float floatFreq = 1;
    public float floatHeight = 2;
    public float floatOffset = 1;
[Header("Noise")]
    [SerializeField] private float noiseScale = 0.5f;
    [SerializeField] private float noiseFreq = 1;

    private float timer = 0;
    private float seed;
    private Vector3 initPos;

    void Start(){
        seed = Random.Range(-1f, 1f);
        initPos = transform.localPosition;
    }
    void Update(){
        timer += Time.deltaTime*Mathf.PI*floatFreq;
        float noise = Mathf.PerlinNoise(noiseFreq*(Time.time+seed),noiseFreq*(Time.time+seed));
        noise = (noise*2 - 1)*noiseScale;

        transform.localPosition = Vector3.up * floatHeight * (Mathf.Sin(timer + seed*Mathf.PI)+noise) + Vector3.right * floatOffset * Mathf.Cos(timer*0.7f + seed*Mathf.PI) + initPos;
    }
}
