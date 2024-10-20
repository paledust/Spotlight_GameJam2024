using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelGameManager : MonoBehaviour
{
    public static PixelGameManager Instance { get; private set; }
    public List<GameObject> hearts;
    public GameObject world;
    public float worldMoveSpeed;

    private PixelPlaneControl pixelPlaneControl;
    private int curHp;
    void Awake()
    {
        Instance = this;
        pixelPlaneControl = GameObject.FindWithTag("Player").GetComponent<PixelPlaneControl>();
        curHp = hearts.Count;
    }

    void FixedUpdate()
    {
        world.transform.position += Vector3.left * worldMoveSpeed * Time.fixedDeltaTime;
    }

    public void ReduceHp()
    {
        hearts[curHp - 1].SetActive(false);
        curHp--;
        pixelPlaneControl.TriggerDamageAnim();
        if (curHp == 0)
        {
            worldMoveSpeed = 0;
            pixelPlaneControl.gameObject.SetActive(false);
        }
    }
}
