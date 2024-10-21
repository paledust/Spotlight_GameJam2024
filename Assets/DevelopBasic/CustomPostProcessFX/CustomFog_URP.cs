using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenuForRenderPipeline("Custom/CustomFog", typeof(UniversalRenderPipeline))]
public class CustomFog_URP : VolumeComponent, IPostProcessComponent
{
    public ColorParameter color = new ColorParameter(Color.blue);
    public ClampedFloatParameter intensity = new ClampedFloatParameter(value : 1f, 0f, 1f);
    public FloatParameter startDistance = new FloatParameter(value : 0f);
    public FloatParameter fadeLength = new FloatParameter(value : 100f);
    public ClampedFloatParameter controlOffset = new ClampedFloatParameter(value : 0.11f, 0.001f, 0.999f);
    public ClampedFloatParameter controlValue = new ClampedFloatParameter(value : 0f, 0f, 1f);
    public bool IsActive()=>intensity.value>0;
    public bool IsTileCompatible() => true;
}

[System.Serializable]
public class CustomFog_URP_Pass : ScriptableRenderPass
{
    RenderTargetIdentifier src;
    RenderTargetIdentifier temp;
    private Material material;
    private int screenTexID = Shader.PropertyToID("ScreenTexID");

    public CustomFog_URP_Pass(){
        renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData){
        material = CoreUtils.CreateEngineMaterial(Shader.Find("Hidden/Custom/CustomFog"));

        src = renderingData.cameraData.renderer.cameraColorTarget;
        
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        cmd.GetTemporaryRT(screenTexID, descriptor, FilterMode.Bilinear);
        temp = new RenderTargetIdentifier(screenTexID);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData){
        if(material == null){
            Debug.LogError("Fog Materials instance is null");
            return;
        }

        CommandBuffer cmd = CommandBufferPool.Get("Fog");
        cmd.Clear();

        var fogEffect = VolumeManager.instance.stack.GetComponent<CustomFog_URP>();

        if(fogEffect.IsActive()){
            material.SetColor("_Color",fogEffect.color.value);
            material.SetFloat("_Intensity",fogEffect.intensity.value);
            material.SetFloat("_StartDistance", fogEffect.startDistance.value);
            material.SetFloat("_FadeLength", fogEffect.fadeLength.value);
            material.SetFloat("_ControlOffset",fogEffect.controlOffset.value);
            material.SetFloat("_ControlValue",fogEffect.controlValue.value);
        }
        else{
            return;
        }

        Blit(cmd, src, temp, material, 0);
        Blit(cmd, temp, src);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
    public override void OnCameraCleanup(CommandBuffer cmd){
        cmd.ReleaseTemporaryRT(screenTexID);
    }
}
