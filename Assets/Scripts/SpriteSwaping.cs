using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class SpriteSwaping : MonoBehaviour
{
    [SerializeField] private Sprite[] sprites;
    [SerializeField] private Vector2 swapCycleRange;
    private float timer = 0;
    private float currentCycle;
    private int shuffleCounter = 0;
    private Sprite[] pendingSprites;
    private SpriteRenderer spriteRenderer;

    void Start(){
        spriteRenderer = GetComponent<SpriteRenderer>();
        pendingSprites = new Sprite[sprites.Length];
        for(int i=0; i<sprites.Length; i++){
            pendingSprites[i] = sprites[i];
        }
        ShuffleSprite();
        currentCycle = swapCycleRange.GetRndValueInVector2Range();
    }
    void Update()
    {
        timer += Time.deltaTime;
        if(timer > currentCycle){
            timer = 0;
            currentCycle = swapCycleRange.GetRndValueInVector2Range();

            spriteRenderer.sprite = pendingSprites[shuffleCounter];
            shuffleCounter ++;
            if(shuffleCounter >= pendingSprites.Length){
                shuffleCounter = 0;
                ShuffleSprite();
            }
        }
    }
    void ShuffleSprite(){
        Service.Shuffle(ref pendingSprites);
    }
}
