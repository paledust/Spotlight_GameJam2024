// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaders/Sprite Strap Dissolve Unlit"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_DissolvePanSpeed("DissolvePanSpeed", Vector) = (0,0,0,0)
		_DissolveSoftness("DissolveSoftness", Float) = 1
		_PatternScale("PatternScale", Float) = 1
		[KeywordEnum(Radius,TexBased,U_Direction,V_Direction,Polar)] _DissolveType("DissolveType", Float) = 0
		_RadiusCenterX("RadiusCenterX", Float) = 0.5
		_RadiusCenterY("RadiusCenterY", Float) = 0.5
		_DissolveRadius("DissolveRadius", Float) = 0.5
		_DissolveLength("DissolveLength", Float) = 0.1
		_DissolveGuideTex("DissolveGuideTex", 2D) = "white" {}
		_EdgeValue("EdgeValue", Float) = 0
		_EdgeSoftness("EdgeSoftness", Float) = 1
		[HDR]_EdgeColor("EdgeColor", Color) = (2.828427,2.029812,1.209014,1)
		[PerRendererData]_NoiseUVOffset("NoiseUVOffset", Vector) = (0,0,0,0)
		_DissolveTexTile("DissolveTexTile", Vector) = (1,1,0,0)
		_WiggleTex("WiggleTex", 2D) = "white" {}
		_WigglePan("WigglePan (RG Tile, BA Pan)", Vector) = (0,0,0,0)
		_WiggleStrength("WiggleStrength", Float) = 0
		_WiggleFade("WiggleFade", Float) = 0
		_WiggleFadeSmooth("WiggleFadeSmooth", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 2.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
		ENDHLSL

		
		Pass
		{
			Name "Sprite Unlit"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITEUNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#pragma multi_compile_instancing
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_POLAR


			sampler2D _WiggleTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveGuideTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteStrapDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteStrapDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _WigglePan;
			float4 _EdgeColor;
			float2 _DissolvePanSpeed;
			float2 _DissolveTexTile;
			float _WiggleFade;
			float _WiggleFadeSmooth;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _WiggleStrength;
			float _DissolveSoftness;
			float _EdgeValue;
			float _EdgeSoftness;
			CBUFFER_END


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float4 _RendererColor;

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult358 = (float2(_WigglePan.z , _WigglePan.w));
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 appendResult357 = (float2(_WigglePan.x , _WigglePan.y));
				float2 panner356 = ( 1.0 * _Time.y * appendResult358 + ( worldUV208 * appendResult357 ));
				float4 tex2DNode350 = tex2Dlod( _WiggleTex, float4( panner356, 0, 0.0) );
				float2 appendResult351 = (float2(tex2DNode350.r , tex2DNode350.g));
				float2 wiggle366 = ( ( appendResult351 * float2( 2,2 ) ) - float2( 1,1 ) );
				float patternScale162 = _PatternScale;
				float2 texCoord87 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2Dlod( _DissolveGuideTex, float4( uv143, 0, 0.0) ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2Dlod( _NoiseTex, float4( ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ), 0, 0.0) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult364 = smoothstep( _WiggleFade , ( _WiggleFade + _WiggleFadeSmooth ) , temp_output_273_0);
				float3 appendResult373 = (float3(0.0 , ( ( wiggle366.y * ( 1.0 - smoothstepResult364 ) ) * _WiggleStrength ) , 0.0));
				
				o.ase_texcoord3.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = appendResult373;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.positionCS = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4((appendResult40).xyz , (appendResult40).w));
				
				float4 Color = appendResult122;

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif

				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				Color *= IN.color * _RendererColor;
				return Color;
			}

			ENDHLSL
		}
		
		Pass
		{
			
			Name "Sprite Unlit Forward"
            Tags { "LightMode"="UniversalForward" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITEFORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#pragma multi_compile_instancing
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_POLAR


			sampler2D _WiggleTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveGuideTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteStrapDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteStrapDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _WigglePan;
			float4 _EdgeColor;
			float2 _DissolvePanSpeed;
			float2 _DissolveTexTile;
			float _WiggleFade;
			float _WiggleFadeSmooth;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _WiggleStrength;
			float _DissolveSoftness;
			float _EdgeValue;
			float _EdgeSoftness;
			CBUFFER_END


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float4 _RendererColor;

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult358 = (float2(_WigglePan.z , _WigglePan.w));
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 appendResult357 = (float2(_WigglePan.x , _WigglePan.y));
				float2 panner356 = ( 1.0 * _Time.y * appendResult358 + ( worldUV208 * appendResult357 ));
				float4 tex2DNode350 = tex2Dlod( _WiggleTex, float4( panner356, 0, 0.0) );
				float2 appendResult351 = (float2(tex2DNode350.r , tex2DNode350.g));
				float2 wiggle366 = ( ( appendResult351 * float2( 2,2 ) ) - float2( 1,1 ) );
				float patternScale162 = _PatternScale;
				float2 texCoord87 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2Dlod( _DissolveGuideTex, float4( uv143, 0, 0.0) ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2Dlod( _NoiseTex, float4( ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ), 0, 0.0) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult364 = smoothstep( _WiggleFade , ( _WiggleFade + _WiggleFadeSmooth ) , temp_output_273_0);
				float3 appendResult373 = (float3(0.0 , ( ( wiggle366.y * ( 1.0 - smoothstepResult364 ) ) * _WiggleStrength ) , 0.0));
				
				o.ase_texcoord3.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = appendResult373;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.positionCS = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4((appendResult40).xyz , (appendResult40).w));
				
				float4 Color = appendResult122;

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif


				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				Color *= IN.color * _RendererColor;
				return Color;
			}

			ENDHLSL
		}
		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            Cull Off

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma multi_compile_instancing
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_POLAR


			sampler2D _WiggleTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveGuideTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteStrapDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteStrapDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _WigglePan;
			float4 _EdgeColor;
			float2 _DissolvePanSpeed;
			float2 _DissolveTexTile;
			float _WiggleFade;
			float _WiggleFadeSmooth;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _WiggleStrength;
			float _DissolveSoftness;
			float _EdgeValue;
			float _EdgeSoftness;
			CBUFFER_END


            struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};


            int _ObjectId;
            int _PassValue;

			
			VertexOutput vert(VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult358 = (float2(_WigglePan.z , _WigglePan.w));
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 appendResult357 = (float2(_WigglePan.x , _WigglePan.y));
				float2 panner356 = ( 1.0 * _Time.y * appendResult358 + ( worldUV208 * appendResult357 ));
				float4 tex2DNode350 = tex2Dlod( _WiggleTex, float4( panner356, 0, 0.0) );
				float2 appendResult351 = (float2(tex2DNode350.r , tex2DNode350.g));
				float2 wiggle366 = ( ( appendResult351 * float2( 2,2 ) ) - float2( 1,1 ) );
				float patternScale162 = _PatternScale;
				float2 texCoord87 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2Dlod( _DissolveGuideTex, float4( uv143, 0, 0.0) ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2Dlod( _NoiseTex, float4( ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ), 0, 0.0) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult364 = smoothstep( _WiggleFade , ( _WiggleFade + _WiggleFadeSmooth ) , temp_output_273_0);
				float3 appendResult373 = (float3(0.0 , ( ( wiggle366.y * ( 1.0 - smoothstepResult364 ) ) * _WiggleStrength ) , 0.0));
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult373;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(v.positionOS);
				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4((appendResult40).xyz , (appendResult40).w));
				
				float4 Color = appendResult122;

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

            Cull Off

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        	#pragma multi_compile_instancing
        	#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_POLAR


			sampler2D _WiggleTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveGuideTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteStrapDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteStrapDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _WigglePan;
			float4 _EdgeColor;
			float2 _DissolvePanSpeed;
			float2 _DissolveTexTile;
			float _WiggleFade;
			float _WiggleFadeSmooth;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _WiggleStrength;
			float _DissolveSoftness;
			float _EdgeValue;
			float _EdgeSoftness;
			CBUFFER_END


            struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            float4 _SelectionID;

			
			VertexOutput vert(VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult358 = (float2(_WigglePan.z , _WigglePan.w));
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 appendResult357 = (float2(_WigglePan.x , _WigglePan.y));
				float2 panner356 = ( 1.0 * _Time.y * appendResult358 + ( worldUV208 * appendResult357 ));
				float4 tex2DNode350 = tex2Dlod( _WiggleTex, float4( panner356, 0, 0.0) );
				float2 appendResult351 = (float2(tex2DNode350.r , tex2DNode350.g));
				float2 wiggle366 = ( ( appendResult351 * float2( 2,2 ) ) - float2( 1,1 ) );
				float patternScale162 = _PatternScale;
				float2 texCoord87 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2Dlod( _DissolveGuideTex, float4( uv143, 0, 0.0) ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2Dlod( _NoiseTex, float4( ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ), 0, 0.0) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult364 = smoothstep( _WiggleFade , ( _WiggleFade + _WiggleFadeSmooth ) , temp_output_273_0);
				float3 appendResult373 = (float3(0.0 , ( ( wiggle366.y * ( 1.0 - smoothstepResult364 ) ) * _WiggleStrength ) , 0.0));
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult373;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(v.positionOS);
				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 temp_output_34_0_g31 = ( texCoord87 - float2( 0.5,0.5 ) );
				float2 break39_g31 = temp_output_34_0_g31;
				float2 appendResult50_g31 = (float2(( 1.0 * ( length( temp_output_34_0_g31 ) * 2.0 ) ) , ( ( atan2( break39_g31.x , break39_g31.y ) * ( 1.0 / TWO_PI ) ) * 1.0 )));
				float2 polarUV313 = ( appendResult50_g31 + float2( 0,0.5 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float2 staticSwitch321 = worldUV208;
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float2 staticSwitch321 = uv143;
				#elif defined( _DISSOLVETYPE_POLAR )
				float2 staticSwitch321 = polarUV313;
				#else
				float2 staticSwitch321 = worldUV208;
				#endif
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_POLAR )
				float staticSwitch93 = (polarUV313).y;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteStrapDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g32 = dissolveLength152;
				float temp_output_5_0_g32 = ( ( abs( ( ( staticSwitch93 * 2.0 ) - 1.0 ) ) - ( dissolveRadius151 - temp_output_21_0_g32 ) ) / temp_output_21_0_g32 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * ( staticSwitch321 * _DissolveTexTile ) ) ).r * 1.0 ) + temp_output_5_0_g32 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4((appendResult40).xyz , (appendResult40).w));
				
				float4 Color = appendResult122;
				half4 outColor = _SelectionID;
				return outColor;
			}

            ENDHLSL
        }
		
	}
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.CommentaryNode;306;-3264,-1968;Inherit;False;634.4478;987.8835;Comment;12;162;151;152;166;35;25;26;81;160;125;307;129;Parameter;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;213;-3248,-2576;Inherit;False;1073.408;482.3657;Comment;7;206;207;126;90;165;89;208;world UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;125;-3232,-1472;Inherit;False;Property;_DissolvePanSpeed;DissolvePanSpeed;2;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;317;-1810,-2578;Inherit;False;1556;531;Comment;11;139;140;87;141;143;86;311;267;313;266;341;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-2992,-1472;Inherit;False;dissolvePanSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;89;-3216,-2352;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-1760,-2368;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;139;-1296,-2240;Inherit;False;Property;_RadiusCenterX;RadiusCenterX;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1296,-2160;Inherit;False;Property;_RadiusCenterY;RadiusCenterY;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-3024,-2320;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-3072,-2192;Inherit;False;160;dissolvePanSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;-1120,-2208;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-1104,-2368;Inherit;False;uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;311;-1456,-2528;Inherit;False;Polar Coordinates;-1;;31;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.PannerNode;126;-2784,-2272;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;206;-2784,-2448;Inherit;False;InstancedProperty;_NoiseUVOffset;NoiseUVOffset;14;1;[PerRendererData];Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-848,-2368;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;341;-1232,-2528;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-2560,-2368;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;267;-688,-2352;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-4576,-288;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;-1104,-2528;Inherit;False;polarUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-2432,-2368;Inherit;False;worldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-528,-2352;Inherit;False;worldRadiusLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-4560,-80;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-4560,16;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;101;-4400,-288;Inherit;True;Property;_DissolveGuideTex;DissolveGuideTex;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;314;-4560,112;Inherit;False;313;polarUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-3872,304;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-3872,224;Inherit;False;208;worldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-3872,384;Inherit;False;313;polarUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;195;-4336,16;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;176;-4336,-80;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;272;-4112,-256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-4368,-368;Inherit;False;266;worldRadiusLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;316;-4336,112;Inherit;True;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;93;-3664,-208;Inherit;False;Property;_DissolveType;DissolveType;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;Radius;TexBased;U_Direction;V_Direction;Polar;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;321;-3664,256;Inherit;False;Property;_Keyword0;Keyword 0;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;93;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;326;-3632,448;Inherit;False;Property;_DissolveTexTile;DissolveTexTile;15;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;355;-1776,-1552;Inherit;False;Property;_WigglePan;WigglePan (RG Tile, BA Pan);17;0;Create;False;0;0;0;False;0;False;0,0,0,0;0.1,0.1,0.3,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;81;-3216,-1904;Inherit;True;Property;_NoiseTex;NoiseTex;1;0;Create;True;0;0;0;False;0;False;None;8035005feb8f6c44db61a3f886180b9c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;26;-3216,-1248;Inherit;False;InstancedProperty;_DissolveLength;DissolveLength;9;0;Create;True;0;0;0;False;0;False;0.1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-3216,-1168;Inherit;False;Property;_PatternScale;PatternScale;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-3424,352;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-3216,-1344;Inherit;False;InstancedProperty;_DissolveRadius;DissolveRadius;8;0;Create;True;0;0;0;False;0;False;0.5;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-3376,-208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;357;-1488,-1584;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;-1520,-1808;Inherit;False;208;worldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-2992,-1248;Inherit;False;dissolveLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;-2992,-1344;Inherit;False;dissolveRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-2992,-1168;Inherit;False;patternScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;327;-3024,64;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-2944,-1904;Inherit;False;noiseTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;334;-3168,-208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;358;-1488,-1472;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-1312,-1808;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-2400,112;Inherit;False;166;noiseTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-2400,192;Inherit;False;162;patternScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-2368,272;Inherit;False;151;dissolveRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;328;-2192,0;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-2336,352;Inherit;False;152;dissolveLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1456,192;Inherit;False;Property;_EdgeSoftness;EdgeSoftness;12;0;Create;True;0;0;0;False;0;False;1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1424,128;Inherit;False;Property;_EdgeValue;EdgeValue;11;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;335;-2960,-208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;356;-1056,-1808;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;273;-1904,-224;Inherit;True;SGradientDissolve;-1;;32;785db4bdd2f91e7478256f23fbd5abd7;1,26,1;7;29;FLOAT;1;False;24;FLOAT;0;False;22;FLOAT2;0,0;False;17;SAMPLER2D;;False;18;FLOAT;1;False;20;FLOAT;0.5;False;21;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1632,-144;Inherit;False;Property;_DissolveSoftness;DissolveSoftness;3;0;Create;True;0;0;0;False;0;False;1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-1248,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;350;-848,-1824;Inherit;True;Property;_WiggleTex;WiggleTex;16;0;Create;True;0;0;0;False;0;False;-1;None;fd48e811ee510204199a2134cdffb02f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SmoothstepOpNode;42;-1376,-224;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;49;-1088,112;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;351;-544,-1776;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;41;-1184,-224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-832,112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-476.1532,-34.67459;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;129;-3216,-1696;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-352,-1776;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;59;-332.6537,-34.4746;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;54;-752,-784;Inherit;False;Property;_EdgeColor;EdgeColor;13;1;[HDR];Create;True;0;0;0;False;0;False;2.828427,2.029812,1.209014,1;1.498039,1.082353,0.6431373,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-2992,-1696;Inherit;False;mainTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;362;1040,224;Inherit;False;Property;_WiggleFade;WiggleFade;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;992,304;Inherit;False;Property;_WiggleFadeSmooth;WiggleFadeSmooth;20;0;Create;True;0;0;0;False;0;False;1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;379;-192,-1776;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-129.8849,-33.53051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-896,-432;Inherit;False;307;mainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;363;1216,272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-32,-1776;Inherit;False;wiggle;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;205;25.00806,-32.72052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-720,-432;Inherit;True;Property;_test;test;0;0;Create;True;0;0;0;False;0;False;129;7a170cdb7cc88024cb628cfcdbb6705c;7a170cdb7cc88024cb628cfcdbb6705c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SmoothstepOpNode;364;1376,208;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;1488,-80;Inherit;False;366;wiggle;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-384,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;91;256,-416;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;365;1600,208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;372;1664,-80;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;40;977.6847,-288.4521;Inherit;False;FLOAT4;4;0;FLOAT3;1,0,0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;360;1792,32;Inherit;False;Property;_WiggleStrength;WiggleStrength;18;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;1808,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;121;1184,-176;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;120;1184,-432;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;1971.427,11.07056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;1808,-432;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;-1392,-576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;331;-1056,-576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;330;-1216,-576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;373;2096,-96;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;73;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit Forward;0;1;Sprite Unlit Forward;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;75;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;ScenePickingPass;0;3;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;72;2048,-432;Float;False;True;-1;2;ASEMaterialInspector;0;15;AmplifyShaders/Sprite Strap Dissolve Unlit;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit;0;0;Sprite Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;3;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;4;True;True;True;True;False;;False;0
WireConnection;160;0;125;0
WireConnection;90;0;89;1
WireConnection;90;1;89;2
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;143;0;87;0
WireConnection;311;1;87;0
WireConnection;126;0;90;0
WireConnection;126;2;165;0
WireConnection;86;0;143;0
WireConnection;86;1;141;0
WireConnection;341;0;311;0
WireConnection;207;0;206;0
WireConnection;207;1;126;0
WireConnection;267;0;86;0
WireConnection;313;0;341;0
WireConnection;208;0;207;0
WireConnection;266;0;267;0
WireConnection;101;1;144;0
WireConnection;195;0;194;0
WireConnection;176;0;175;0
WireConnection;272;0;101;1
WireConnection;316;0;314;0
WireConnection;93;1;269;0
WireConnection;93;0;272;0
WireConnection;93;2;176;0
WireConnection;93;3;195;0
WireConnection;93;4;316;0
WireConnection;321;1;324;0
WireConnection;321;0;324;0
WireConnection;321;2;319;0
WireConnection;321;3;319;0
WireConnection;321;4;318;0
WireConnection;322;0;321;0
WireConnection;322;1;326;0
WireConnection;333;0;93;0
WireConnection;357;0;355;1
WireConnection;357;1;355;2
WireConnection;152;0;26;0
WireConnection;151;0;25;0
WireConnection;162;0;35;0
WireConnection;327;0;322;0
WireConnection;166;0;81;0
WireConnection;334;0;333;0
WireConnection;358;0;355;3
WireConnection;358;1;355;4
WireConnection;352;0;376;0
WireConnection;352;1;357;0
WireConnection;328;0;327;0
WireConnection;335;0;334;0
WireConnection;356;0;352;0
WireConnection;356;2;358;0
WireConnection;273;24;335;0
WireConnection;273;22;328;0
WireConnection;273;17;274;0
WireConnection;273;18;275;0
WireConnection;273;20;276;0
WireConnection;273;21;277;0
WireConnection;57;0;51;0
WireConnection;57;1;52;0
WireConnection;350;1;356;0
WireConnection;42;0;273;0
WireConnection;42;2;43;0
WireConnection;49;0;273;0
WireConnection;49;1;51;0
WireConnection;49;2;57;0
WireConnection;351;0;350;1
WireConnection;351;1;350;2
WireConnection;41;0;42;0
WireConnection;53;0;49;0
WireConnection;58;0;41;0
WireConnection;58;1;53;0
WireConnection;378;0;351;0
WireConnection;59;0;58;0
WireConnection;307;0;129;0
WireConnection;379;0;378;0
WireConnection;204;0;59;0
WireConnection;204;1;54;4
WireConnection;363;0;362;0
WireConnection;363;1;361;0
WireConnection;366;0;379;0
WireConnection;205;0;204;0
WireConnection;5;0;309;0
WireConnection;364;0;273;0
WireConnection;364;1;362;0
WireConnection;364;2;363;0
WireConnection;39;0;5;4
WireConnection;39;1;41;0
WireConnection;91;0;5;0
WireConnection;91;1;54;0
WireConnection;91;2;205;0
WireConnection;365;0;364;0
WireConnection;372;0;369;0
WireConnection;40;0;91;0
WireConnection;40;3;39;0
WireConnection;377;0;372;1
WireConnection;377;1;365;0
WireConnection;121;0;40;0
WireConnection;120;0;40;0
WireConnection;381;0;377;0
WireConnection;381;1;360;0
WireConnection;122;0;120;0
WireConnection;122;3;121;0
WireConnection;331;0;330;0
WireConnection;330;0;329;0
WireConnection;373;1;381;0
WireConnection;72;1;122;0
WireConnection;72;3;373;0
ASEEND*/
//CHKSM=82160F47A9AD07747825AB03E875EC9E8764489D