using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class MenuManager : MonoBehaviour
{
    [SerializeField] private Texture2D cursorTex;
    void Start(){
        Cursor.visible = true;
        Cursor.SetCursor(cursorTex, new Vector2(16, 16), CursorMode.Auto);
    }
    public void ButtonEvent_StartGame(){
        Cursor.visible = false;
        GameManager.Instance.SwitchingScene(Service.WORKING);
    }
    public void ButtonEvent_EndGame(){
        Cursor.visible = false;
        GameManager.Instance.EndGame();
    }
}
