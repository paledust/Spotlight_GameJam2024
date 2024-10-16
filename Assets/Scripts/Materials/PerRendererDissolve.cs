using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerRendererDissolve : PerRendererBehavior
{
    [SerializeField] private DissolveControl dissolveCenter;
    [SerializeField] private float dissolveRadius;
    private readonly int DissolveRadiusID = Shader.PropertyToID("_DissolveRadius");
    private readonly int DissolveCenterID = Shader.PropertyToID("_DissolveCenter");
    protected override void UpdateProperties()
    {
        base.UpdateProperties();
        mpb.SetFloat(DissolveRadiusID, dissolveCenter.radius);
        mpb.SetVector(DissolveCenterID, dissolveCenter.transform.position);
    }
}