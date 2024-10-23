using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PixelType : MonoBehaviour
{
    private string content = "THIS DREAM IS DONE\nLET'S START A NEW ONE.";
    public float typeInterval;
    private float timer = 0;
    private int index = 0;
    private Text text;
    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<Text>();
        text.text = "";
    }

    // Update is called once per frame
    void Update()
    {
        if (index <= content.Length)
        {
            timer += Time.deltaTime;
            if (timer >= typeInterval)
            {
                timer = 0;
                text.text = content.Substring(0, index);
                index++;
            }
        }
    }
}
