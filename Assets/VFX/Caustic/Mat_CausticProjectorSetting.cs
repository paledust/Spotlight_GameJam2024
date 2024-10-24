using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Mat_CausticProjectorSetting : MonoBehaviour {
    public Projector m_projector;
    public Material TargetMaterial;
    protected Material m_mat;
#region  MAT_PARAMS
    public Color color;
    public float Tiled;
    public float Density;
    public float Intensity;
    public float Lerp;
    public float FadeHeight;
    public float FadeFalloff;
    public float RWC2Wave;
    public float AnimationSpeed;
    [Range(0,1)]
    public float MaskFadeOff;
    [Range(0,1)]
    public float MaskFadeSmoothness;
    [Range(0,0.01f)]
    public float ColorSeparate = 0;
    public bool UseType2Caustic;
    public bool UseMask;
    public int RenderQueue=3000;
    protected int IntensityID = Shader.PropertyToID("_Intensity");
    protected int TiledID = Shader.PropertyToID("_Tiled");
    protected int DensityID = Shader.PropertyToID("_Density");
    protected int LerpID = Shader.PropertyToID("_Lerp");
    protected int FadeHeightID = Shader.PropertyToID("_FadeHeight");
    protected int FadeFalloffID = Shader.PropertyToID("_FadeFalloff");
    protected int RWC2WaveID = Shader.PropertyToID("_RWC2_Wave");
    protected int AnimationSpeedID = Shader.PropertyToID("_Speed");
    protected int MaskFadeOffID = Shader.PropertyToID("_Fade");
    protected int MaskFadeSmoothnessID = Shader.PropertyToID("_Smooth");
    protected int ColorSeparateID = Shader.PropertyToID("_ColorSeparate");
    protected string TypeKey = "USE_TYPE2";
    protected string MaskKey = "USE_MASK";
#endregion
    protected void OnEnable(){
        if(!ParameterChecking())return;
        if(m_mat==null){
            InitMaterial();
        }
        if(m_projector.material!=m_mat){
            m_projector.material = m_mat;
        }
		CopyMaterialFromShareMaterial();
		ParameterUpdate();
    }
    protected void Update(){
		if(!ParameterChecking())return;
		if(m_mat==null){
			InitMaterial();
		}

		ParameterUpdate();        
    }
    protected void ParameterUpdate(){
        m_mat.color = color;
        m_mat.SetFloat(IntensityID, Intensity);
        m_mat.SetFloat(TiledID, Tiled);
        m_mat.SetFloat(DensityID, Density);
        m_mat.SetFloat(LerpID, Lerp);
        m_mat.SetFloat(FadeHeightID, FadeHeight);
        m_mat.SetFloat(FadeFalloffID, FadeFalloff);
        m_mat.SetFloat(RWC2WaveID, RWC2Wave);
        m_mat.SetFloat(AnimationSpeedID, AnimationSpeed);
        m_mat.SetFloat(MaskFadeOffID, MaskFadeOff);
        m_mat.SetFloat(MaskFadeSmoothnessID, MaskFadeSmoothness);
        m_mat.SetFloat(ColorSeparateID, ColorSeparate);
        m_mat.renderQueue = RenderQueue;

        if(UseType2Caustic)
            m_mat.EnableKeyword(TypeKey);
        else
            m_mat.DisableKeyword(TypeKey);

        if(UseMask)
            m_mat.EnableKeyword(MaskKey);
        else
            m_mat.DisableKeyword(MaskKey);
    }
	protected void CopyMaterialFromShareMaterial(){
	#if UNITY_EDITOR
		if(!UnityEditor.EditorApplication.isPlaying)
			m_mat.CopyPropertiesFromMaterial(TargetMaterial);
		
	#endif
	}
	protected void InitMaterial(){
		m_mat = Instantiate(TargetMaterial);
		m_projector.material = m_mat;
	}
	protected bool ParameterChecking(){
		if(!m_projector||!TargetMaterial) return false;

		return true;
	}
}
