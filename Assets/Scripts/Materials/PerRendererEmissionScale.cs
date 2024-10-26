using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerRendererEmissionScale : PerRendererBehavior
{
    [SerializeField] private float emissionScale = 1;
    private const string emissionScaleName = "_EmissionScale";
    protected override void UpdateProperties()
    {
        base.UpdateProperties();
        mpb.SetFloat(emissionScaleName, emissionScale);
    }
}
