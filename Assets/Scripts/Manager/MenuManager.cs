using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;
using UnityEngine.UI;

public class MenuManager : MonoBehaviour
{
    [SerializeField] private Texture2D cursorTex;
    [SerializeField] private CanvasGroup bCanvas;
[Header("Credits")]
    [SerializeField] private Button creditButton;
    [SerializeField] private Button creditBackButton;
    [SerializeField] private SpriteRenderer creditImage;
    private bool isCreditsOn = false;
    private bool isCreditTransition = false;
    void OnEnable(){
        bCanvas.alpha = 0f;
    }
    void Start(){
        Cursor.visible = true;
        Cursor.SetCursor(cursorTex, new Vector2(16, 16), CursorMode.Auto);

        StartCoroutine(coroutineFadeInButtonGroup());
    }
    public void ButtonEvent_StartGame(){
        Cursor.visible = false;
        bCanvas.interactable = false;
        GameManager.Instance.SwitchingScene(Service.WORKING);
    }
    public void ButtonEvent_EndGame(){
        Cursor.visible = false;
        bCanvas.interactable = false;
        GameManager.Instance.EndGame();
    }
    public void ButtonEvent_Credits(){
        if(isCreditTransition) return;

        isCreditsOn = !isCreditsOn;
        StartCoroutine(coroutineTransistToCredit(isCreditsOn));
    }
    IEnumerator coroutineFadeInButtonGroup(){
        bCanvas.interactable = true;
        bCanvas.alpha = 0;
        yield return new WaitForLoop(0.5f,(t)=>{
            bCanvas.alpha = Mathf.Lerp(0, 1, EasingFunc.Easing.QuadEaseOut(t));
        });
    }
    IEnumerator coroutineTransistToCredit(bool isOn){
        isCreditTransition = true;
        StartCoroutine(CommonCoroutine.coroutineFadeUI(creditButton.image, 0, 0.5f));
        creditBackButton.interactable = false;
        creditBackButton.interactable = true;
        yield return CommonCoroutine.coroutineFadeUI(creditBackButton.image, 1, 0.5f);
        isCreditTransition = false;
    }
}
