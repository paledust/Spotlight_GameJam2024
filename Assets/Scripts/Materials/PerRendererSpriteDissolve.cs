using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerRendererSpriteDissolve : PerRendererBehavior
{
    public float dissolveValue;
    private readonly int DissolveValueID = Shader.PropertyToID("_DissolveValue");
    protected override void UpdateProperties()
    {
        base.UpdateProperties();
        mpb.SetFloat(DissolveValueID, dissolveValue);
    }
}
