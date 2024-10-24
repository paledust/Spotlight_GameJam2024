Shader "Water_FX/CG_CausticsFade"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Tiled ("Tiled", Float) = 6.283
		_Density ("Density", Range(0.002, 0.02)) = 0.005
		_Intensity ("Intensity", Range(0, 4)) = 1.4
		_Lerp ("Lerp", Range(0, 1)) = 0.5
		_FadeHeight ("Fade Height", Float) = 2
		_FadeFalloff ("Fade Falloff", Range(0.1, 2)) = 1
		_RWC2_Wave ("RWC2 Wave", Float) = 0.3
		_Speed("Animaiton Speed", Float) = 1.0
		
		_Mask ("Texture", 2D) = "white" {}
		_Fade ("Fade Off", Range(0,1)) = 0
		_Smooth("Smooth", Range(0,1)) = 0

		_ColorSeparate("Color Separation", Float) = 0

		[Toggle(USE_TYPE2)] _USETYPE2 ("Use Type2 Causetic", Float) = 0
		[Toggle(USE_MASK)] _USEMASK ("Use Mask", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha
			ZWrite Off
			Offset -1, -1
			Cull Off
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma shader_feature USE_TYPE2
			#pragma shader_feature USE_MASK
			#pragma vertex vert
			#pragma fragment frag

			uniform float _Fade;
			uniform float _Smooth;
			uniform float4x4 unity_Projector;
			uniform sampler2D _Mask;
			uniform float3 _Color;
			uniform float _Tiled;
			uniform float _Density;
			uniform float _Intensity;
			uniform float _Lerp;
			uniform float _FadeHeight;
			uniform float _FadeFalloff;
			uniform float _RWC2_Wave;
			uniform float _Speed;
			uniform float _ColorSeparate;

			#define ITER 5

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float3 wldpos : TEXCOORD1;
				float3 wldnor : TEXCOORD2;
				float4 posProj: TEXCOORD3;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;
				o.wldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.wldnor = mul(unity_ObjectToWorld, float4(SCALED_NORMAL.x, SCALED_NORMAL.y, SCALED_NORMAL.z, 0));
				o.posProj = mul(unity_Projector, v.vertex);
				return o;
			}
			float4 caustic(float2 uv){
				#define F length(0.5 - frac(cc.xyw = mul(float3x3(-2,-1,2, 3,-2,1, 1,2,2), cc.xyw)*
				float4 cc = float4(1, 1, 1, _Time.y) * 0.5 * _Speed;
				cc.xy = _Tiled * 100 * uv * (sin(cc).w * _RWC2_Wave + 2.0) / 2e2;
				cc = pow(min(min(F 0.5)),F 0.4))),F 0.3))), 6.0) * _Intensity * 2;

				return cc;
			}

			float4 frag (v2f input) : SV_TARGET
			{
				// height fade
				float fade = min(0,input.wldpos.y - _FadeHeight) / _FadeFalloff;
				fade = 1 - fade;

				// below side fade
				float3 UP = float3(0, 1, 0);
				float3 N = normalize(input.wldnor);
				fade *= min(1, max(0, dot(N, UP) + 0.5));
				fade = max(0,fade);
				// two kinds of caustics

				float2 posProj = input.posProj.xy/input.posProj.w;
				posProj = clamp(posProj, 0, 1);

			#ifdef USE_TYPE2
				float4 cR,cG,cB;
				float4 cc;
				cR = caustic(posProj + _ColorSeparate*float2(0,1)) * float4(1,0,0,1);
				cG = caustic(posProj + _ColorSeparate*float2(-0.7,0.5)) * float4(0,1,0,1);
				cB = caustic(posProj + _ColorSeparate*float2(0.7,0.5)) * float4(0,0,1,1);
				cc = cR+cG+cB;
				
			#else	
				float2 uv = posProj;
				float2 p = fmod(uv * _Tiled, _Tiled) - 250.0;
				float2 i = p;
				float c = 1.0;
							
				for (int n = 0; n < ITER; n++)
				{
					float t = _Time.y * (1.0 - (3.5 / float(n + 1)));
					i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c += 1.0 / length(float2(p.x / (sin(i.x + t) / _Density), p.y / (cos(i.y + t) / _Density)));
				}
				c /= float(ITER);
				c = 1.17 - pow(c, _Intensity);
				float tmp = pow(abs(c), 8.0);
				float3 cc = float3(tmp, tmp, tmp);
			#endif

			#ifdef USE_MASK


				if(input.posProj.w > 0.0){
					float mask = tex2D(_Mask, posProj).r;
					mask = (mask-_Smooth) * _Fade;
					mask = clamp(mask, 0, 1);

					return float4(cc * _Color * fade * mask, _Lerp);
				}
				else
					return 0.0;
			#else
				return float4(cc * _Color * fade, _Lerp);
			#endif
			}
			ENDCG
		}
	}
}
