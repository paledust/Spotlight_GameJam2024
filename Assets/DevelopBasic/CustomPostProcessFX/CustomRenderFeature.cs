using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderFeature : ScriptableRendererFeature
{
    private Blur_URP_Pass blur_pass;

    public override void Create(){
        blur_pass = new Blur_URP_Pass();
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData){
        renderer.EnqueuePass(blur_pass);
    }
}
