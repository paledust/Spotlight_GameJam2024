using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class Plan_Ending : MonoBehaviour
{
    [SerializeField] private Texture2D cursorTex;
    [SerializeField] private PlayableDirector tl_ending;
    [SerializeField] private PlayableDirector tl_goToMenu;
    [SerializeField] private CanvasGroup bCanvas;
    void Start()
    {
        Cursor.visible = false;
        tl_ending.Play();
    }
    public void BEvent_GoToMenu(){
        bCanvas.interactable = false;
        tl_goToMenu.Play();
    }
    public void tlEvent_GoToMenu(){
        GameManager.Instance.SwitchingScene(Service.MENU, 0.2f, Color.clear);
    }
    public void tlEvent_ActivateCursor(){
        Cursor.visible = true;
        Cursor.SetCursor(cursorTex, new Vector2(16, 16), CursorMode.Auto);
    }
}