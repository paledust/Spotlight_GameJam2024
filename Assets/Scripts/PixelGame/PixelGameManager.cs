using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PixelGameManager : MonoBehaviour
{
    public static PixelGameManager Instance { get; private set; }
    public List<GameObject> hearts;
    public GameObject world;
    public float worldMoveSpeed;
    public GameObject endPoint;
    public GameObject mapPointer;
    public float mapStartPos;
    public float mapEndPos;
    public GameObject fuelBar;
    public Text milesText;
    public Text fuelText;
    public GameObject retryPanel;
    public GameObject winPanel;

    private PixelPlaneControl pixelPlaneControl;
    private int curHp;
    private Vector3 worldStartPos;
    private Vector3 worldEndPos;
    private Vector3 planeStartPos;
    private int fuelUsed;
    private int fuelMax;
    [HideInInspector]
    public bool gameStart = true;
    private int milesTextNum;
    private int fuelTextNum;
    
    void Awake()
    {
        Instance = this;
        pixelPlaneControl = GameObject.FindWithTag("Player").GetComponent<PixelPlaneControl>();
        curHp = hearts.Count;
        worldStartPos = world.transform.position;
        worldEndPos = endPoint.transform.position;
        planeStartPos = pixelPlaneControl.transform.position;
        fuelUsed = 0;
        fuelMax = fuelBar.transform.childCount;
        milesTextNum = 0;
        fuelTextNum = 10000;
    }

    void FixedUpdate()
    {
        if (world.transform.position.x > endPoint.transform.position.x)
        {
            if (gameStart)
            {
                world.transform.position += Vector3.left * worldMoveSpeed * Time.fixedDeltaTime;
                UpdateProgress();
            }
        }
        else if (gameStart)
        {
            Debug.Log("GameEnd");
            winPanel.SetActive(true);
            gameStart = false;
        }

        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (retryPanel.activeSelf)
                RestartGame();
            else if (winPanel.activeSelf)
                FinishGame();
        }
    }

    public void ReduceHp()
    {
        hearts[curHp - 1].SetActive(false);
        curHp--;
        pixelPlaneControl.GetComponent<Animator>().SetTrigger("Damage");
        if (curHp == 0)
        {
            gameStart = false;
            retryPanel.SetActive(true);
        }
    }

    public void RestartGame()
    {
        world.transform.position = worldStartPos;
        float mapX = mapStartPos;
        float mapY = mapPointer.GetComponent<RectTransform>().anchoredPosition.y;
        mapPointer.GetComponent<RectTransform>().anchoredPosition = new Vector2(mapX, mapY);
        pixelPlaneControl.transform.position = planeStartPos;

        curHp = 3;
        for (int i = 0; i < hearts.Count; i++)
            hearts[i].SetActive(true);

        fuelUsed = 0;
        for (int i = 0; i < fuelMax; i++)
            fuelBar.transform.GetChild(i).gameObject.SetActive(true);

        milesTextNum = 0;
        fuelTextNum = 10000;
        SetMilesText();
        SetFuelText();

        retryPanel.SetActive(false);
        gameStart = true;
    }

    public void FinishGame()
    {
        EventHandler.Call_OnPixelGameFinished();
    }

    public float GetProgress()
    {
        return (world.transform.position.x - worldStartPos.x) / (worldEndPos.x - worldStartPos.x);
    }

    private void UpdateProgress()
    {
        float progress = GetProgress();
        RectTransform mapRect = mapPointer.GetComponent<RectTransform>();
        float mapX = mapStartPos + (mapEndPos - mapStartPos) * progress;
        float mapY = mapRect.anchoredPosition.y;
        mapRect.anchoredPosition = new Vector2(mapX, mapY);
        if (fuelUsed < fuelMax && (float)fuelUsed / fuelMax < progress)
        {
            fuelBar.transform.GetChild(fuelUsed).gameObject.SetActive(false);
            fuelUsed++;
        }

        milesTextNum = (int)(10000 * progress);
        fuelTextNum = 10000 - (int)(progress * 10000);
        SetMilesText();
        SetFuelText();
    }

    private void SetMilesText()
    {
        string s = milesTextNum.ToString().PadLeft(6, '0');
        milesText.text = s.Substring(0, 2) + "'" + s.Substring(2, 2) + "." + s.Substring(4) + "'";
    }

    private void SetFuelText()
    {
        string s = fuelTextNum.ToString().PadLeft(5, '0');
        fuelText.text = s.Substring(0, 3) + ":" + s.Substring(3);
    }
}
