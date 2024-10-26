using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class LightConeSetting : MonoBehaviour {
	[Header("LightCone Setting")]
	public Material mat;
	[ColorUsage(true, true)]
	public Color color			= Color.white;
	[Range(0,2)]
	public float FallOff		= 1f;
	public float Power			= 1.2f;
	[Range(0,2)]
	public float DepthFade 		= 0.12f;
	[Range(0,2)]
	public float DepthFallOff 	= 0.77f;
	public float DepthOffset	= 0.59f;
	[Range(0,5000)]
	public int RenderQueue = 3000;
	protected Color _color;
	protected float _fallOff;
	protected float _power;
	protected float _depthFade;
	protected float _depthFallOff;
	protected float _depthOffset;
	[Header("Light Attach")]
	public Light attahcedLight;
	public float Multiplier = 1;
	public bool AlphaMultiplier = false;
	protected Material m_mat;
	protected MeshRenderer m_renderer;
	void OnEnable() {
		m_renderer = GetComponent<MeshRenderer>();
		if(m_mat == null){
			m_mat = new Material(mat);
		}
		m_mat.renderQueue = RenderQueue;
		m_renderer.material = m_mat;
	}
	void Start() {
		m_renderer = GetComponent<MeshRenderer>();
		if(m_mat == null){
			m_mat = new Material(mat);
		}
		m_mat.renderQueue = RenderQueue;
		m_renderer.material = m_mat;
	}
	void Update(){
		if(m_mat == null){
			m_mat = new Material(mat);
			m_renderer.material = m_mat;
		}
		float _multi = ((attahcedLight == null)?1:attahcedLight.intensity) * Multiplier;
		Color _col 	 = color;
		_col.r *= _multi;
		_col.g *= _multi;
		_col.b *= _multi;
		if(AlphaMultiplier){
			_col.a *= _multi;
		}

		if(_color 		!= _col){
			_color 		= _col;
			m_mat.color = _color;
		}
		if(FallOff 		!= _fallOff){
			_fallOff 	= FallOff;
			m_mat.SetFloat("_FallOff",_fallOff);
		}
		if(Power 		!= _power){
			_power 		= Power;
			m_mat.SetFloat("_Power", _power);
		}
		if(DepthFade 	!= _depthFade){
			_depthFade 	= DepthFade;
			m_mat.SetFloat("_DepthFade", _depthFade);
		}
		if(DepthFallOff != _depthFallOff){
			_depthFallOff = DepthFallOff;
			m_mat.SetFloat("_DepthFallOff", _depthFallOff);
		}
		if(DepthOffset 	!= _depthOffset){
			_depthOffset = DepthOffset;
			m_mat.SetFloat("_DepthOffset", _depthOffset);		
		}
	}
}
