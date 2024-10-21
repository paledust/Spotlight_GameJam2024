// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ScreenEffect/Cg_CustomFog"
{
	Properties
	{
		_Color("FadeColor", Color) = (0,0,0,0)
		_MinDistance("MinDistance", Float) = 0
		_DistanceScale("DistanceScale", Float) = 0
		_Opacity("Opacity", Float) = 0
		_ControlOffset("ControlOffset", Range( 0.001 , 0.999)) = 0.11
		_ControlValue("ControlValue", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			
		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				float4 ase_texcoord2 : TEXCOORD2;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float4 _Color;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _MinDistance;
			uniform float _DistanceScale;
			uniform float _ControlOffset;
			uniform float _ControlValue;
			uniform float _Opacity;


			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode15 = tex2D( _MainTex, uv_MainTex );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float eyeDepth3 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_grabScreenPosNorm.xy ));
				float x13_g2 = saturate( saturate( ( ( eyeDepth3 - _MinDistance ) / _DistanceScale ) ) );
				float a26 = _ControlOffset;
				float a14_g2 = a26;
				float b25 = _ControlValue;
				float b15_g2 = b25;
				float temp_output_7_0_g2 = ( b15_g2 - ( b15_g2 * pow( ( 1.0 - ( x13_g2 / a14_g2 ) ) , 3.0 ) ) );
				float ifLocalVar9_g2 = 0;
				if( x13_g2 <= a14_g2 )
				ifLocalVar9_g2 = temp_output_7_0_g2;
				else
				ifLocalVar9_g2 = ( b15_g2 + ( ( 1.0 - b15_g2 ) * pow( ( ( x13_g2 - a14_g2 ) / ( 1.0 - a14_g2 ) ) , 3.0 ) ) );
				float DistanceFade10 = ifLocalVar9_g2;
				float4 lerpResult16 = lerp( tex2DNode15 , _Color , DistanceFade10);
				float4 lerpResult19 = lerp( tex2DNode15 , lerpResult16 , _Opacity);
				

				float4 color = lerpResult19;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.GrabScreenPosition;2;-2078.631,286.8661;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;3;-1838.505,288.7654;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1793.433,426.4903;Float;False;Property;_MinDistance;MinDistance;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1645.042,531.6166;Float;False;Property;_DistanceScale;DistanceScale;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1613.75,349.0661;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1305.054,739.2212;Inherit;False;Property;_ControlValue;ControlValue;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1310.217,562.2744;Inherit;False;Property;_ControlOffset;ControlOffset;4;0;Create;True;0;0;0;False;0;False;0.11;0;0.001;0.999;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;-1417,350.4515;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1023.019,561.7589;Inherit;False;a;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1032.125,745.064;Inherit;False;b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;9;-1271.745,351.4228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;28;-719.3095,354.4251;Inherit;False;Double-Cubic Seat;-1;;2;b0a389f3638a01f45a34019044af0a95;0;3;5;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-434.4684,349.6432;Float;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;13;-1151.612,-236.1413;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-1180.652,-24.8953;Float;False;Property;_Color;FadeColor;0;0;Create;False;0;0;0;False;0;False;0,0,0,0;0.4485294,0.7261662,1,1;False;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;15;-1028.825,-240.992;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;12;-938.4857,156.8185;Inherit;False;10;DistanceFade;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-668.5682,72.41799;Float;False;Property;_Opacity;Opacity;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;16;-667.763,-47.81002;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;-484.3862,-69.88161;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;29;-322.4268,-69.98682;Float;False;True;-1;2;ASEMaterialInspector;0;8;ScreenEffect/Cg_CustomFog;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;7;False;;False;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;3;0;2;0
WireConnection;4;0;3;0
WireConnection;4;1;6;0
WireConnection;8;0;4;0
WireConnection;8;1;5;0
WireConnection;26;0;23;0
WireConnection;25;0;24;0
WireConnection;9;0;8;0
WireConnection;28;5;9;0
WireConnection;28;3;26;0
WireConnection;28;4;25;0
WireConnection;10;0;28;0
WireConnection;15;0;13;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;16;2;12;0
WireConnection;19;0;15;0
WireConnection;19;1;16;0
WireConnection;19;2;18;0
WireConnection;29;0;19;0
ASEEND*/
//CHKSM=7A231A52A7B0E9EC4180070D74823EA7F3DB5EA2