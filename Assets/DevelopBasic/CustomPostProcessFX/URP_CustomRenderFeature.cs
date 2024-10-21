using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class URP_CustomRenderFeature : ScriptableRendererFeature
{
    private Blur_URP_Pass blur_pass;
    private CustomFog_URP_Pass fog_pass;

    public override void Create(){
        blur_pass = new Blur_URP_Pass();
        fog_pass = new CustomFog_URP_Pass();
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData){
        renderer.EnqueuePass(fog_pass);
        renderer.EnqueuePass(blur_pass);
    }
}