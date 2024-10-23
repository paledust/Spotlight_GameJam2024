// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaders/Sprite AdvancedDissolve Unlit"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseTiling1("NoiseTiling", Float) = 1
		_DissolvePanSpeed("DissolvePanSpeed", Vector) = (0,0,0,0)
		_NoiseSpeed1("NoiseSpeed", Vector) = (1,1,0,0)
		_NoiseMin1("NoiseMin", Float) = -1.25
		_NoiseMax1("NoiseMax", Float) = 1
		_DissolveSoftness("DissolveSoftness", Float) = 1
		_PatternScale("PatternScale", Float) = 1
		[KeywordEnum(Radius,TexBased,U_Direction,V_Direction,World_Direction)] _DissolveType("DissolveType", Float) = 0
		_RadiusCenterX("RadiusCenterX", Float) = 0.5
		_RadiusCenterY("RadiusCenterY", Float) = 0.5
		_DissolveRadius("DissolveRadius", Float) = 0.5
		_DissolveLength("DissolveLength", Float) = 0.1
		_DissolveGuideTex("DissolveGuideTex", 2D) = "white" {}
		_EdgeValue("EdgeValue", Float) = 0
		_EdgeSoftness("EdgeSoftness", Float) = 1
		[HDR]_EdgeColor("EdgeColor", Color) = (2.828427,2.029812,1.209014,1)
		[PerRendererData]_NoiseUVOffset("NoiseUVOffset", Vector) = (0,0,0,0)
		_DissolveDirection("DissolveDirection", Range( 0 , 360)) = 0
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
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_WORLD_DIRECTION


			sampler2D _NoiseTex;
			sampler2D _MainTex;
			sampler2D _DissolveGuideTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteAdvancedDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteAdvancedDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _EdgeColor;
			float2 _NoiseSpeed1;
			float2 _DissolvePanSpeed;
			float _NoiseMin1;
			float _NoiseMax1;
			float _NoiseTiling1;
			float _DissolveSoftness;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _DissolveDirection;
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

				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				o.ase_texcoord3.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float2 appendResult112 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner109 = ( 1.0 * _Time.y * _NoiseSpeed1 + ( appendResult112 * _NoiseTiling1 ));
				float smoothstepResult110 = smoothstep( _NoiseMin1 , _NoiseMax1 , tex2D( _NoiseTex, panner109 ).r);
				float noisePattern117 = smoothstepResult110;
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				float2 appendResult241 = (float2(ase_worldPos.x , ase_worldPos.y));
				float temp_output_250_0 = radians( _DissolveDirection );
				float temp_output_248_0 = cos( temp_output_250_0 );
				float temp_output_249_0 = sin( temp_output_250_0 );
				float3 appendResult251 = (float3(temp_output_248_0 , -temp_output_249_0 , 1.0));
				float3 appendResult253 = (float3(temp_output_249_0 , temp_output_248_0 , 1.0));
				float dotResult242 = dot( appendResult241 , (mul( float3x3(appendResult251, appendResult253, float3( 0,0,0 )), float3(1,0,0) )).xy );
				float worldLineDissolve279 = dotResult242;
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_WORLD_DIRECTION )
				float staticSwitch93 = worldLineDissolve279;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g30 = dissolveLength152;
				float temp_output_5_0_g30 = ( ( staticSwitch93 - ( dissolveRadius151 - temp_output_21_0_g30 ) ) / temp_output_21_0_g30 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * worldUV208 ) ).r * 1.0 ) + -temp_output_5_0_g30 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4(( noisePattern117 * (appendResult40).xyz ) , (appendResult40).w));
				
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
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_WORLD_DIRECTION


			sampler2D _NoiseTex;
			sampler2D _MainTex;
			sampler2D _DissolveGuideTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteAdvancedDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteAdvancedDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _EdgeColor;
			float2 _NoiseSpeed1;
			float2 _DissolvePanSpeed;
			float _NoiseMin1;
			float _NoiseMax1;
			float _NoiseTiling1;
			float _DissolveSoftness;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _DissolveDirection;
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

				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				o.ase_texcoord3.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float2 appendResult112 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner109 = ( 1.0 * _Time.y * _NoiseSpeed1 + ( appendResult112 * _NoiseTiling1 ));
				float smoothstepResult110 = smoothstep( _NoiseMin1 , _NoiseMax1 , tex2D( _NoiseTex, panner109 ).r);
				float noisePattern117 = smoothstepResult110;
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				float2 appendResult241 = (float2(ase_worldPos.x , ase_worldPos.y));
				float temp_output_250_0 = radians( _DissolveDirection );
				float temp_output_248_0 = cos( temp_output_250_0 );
				float temp_output_249_0 = sin( temp_output_250_0 );
				float3 appendResult251 = (float3(temp_output_248_0 , -temp_output_249_0 , 1.0));
				float3 appendResult253 = (float3(temp_output_249_0 , temp_output_248_0 , 1.0));
				float dotResult242 = dot( appendResult241 , (mul( float3x3(appendResult251, appendResult253, float3( 0,0,0 )), float3(1,0,0) )).xy );
				float worldLineDissolve279 = dotResult242;
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_WORLD_DIRECTION )
				float staticSwitch93 = worldLineDissolve279;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g30 = dissolveLength152;
				float temp_output_5_0_g30 = ( ( staticSwitch93 - ( dissolveRadius151 - temp_output_21_0_g30 ) ) / temp_output_21_0_g30 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * worldUV208 ) ).r * 1.0 ) + -temp_output_5_0_g30 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4(( noisePattern117 * (appendResult40).xyz ) , (appendResult40).w));
				
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
			#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_WORLD_DIRECTION


			sampler2D _NoiseTex;
			sampler2D _MainTex;
			sampler2D _DissolveGuideTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteAdvancedDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteAdvancedDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _EdgeColor;
			float2 _NoiseSpeed1;
			float2 _DissolvePanSpeed;
			float _NoiseMin1;
			float _NoiseMax1;
			float _NoiseTiling1;
			float _DissolveSoftness;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _DissolveDirection;
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

				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				o.ase_texcoord.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float3 ase_worldPos = IN.ase_texcoord.xyz;
				float2 appendResult112 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner109 = ( 1.0 * _Time.y * _NoiseSpeed1 + ( appendResult112 * _NoiseTiling1 ));
				float smoothstepResult110 = smoothstep( _NoiseMin1 , _NoiseMax1 , tex2D( _NoiseTex, panner109 ).r);
				float noisePattern117 = smoothstepResult110;
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				float2 appendResult241 = (float2(ase_worldPos.x , ase_worldPos.y));
				float temp_output_250_0 = radians( _DissolveDirection );
				float temp_output_248_0 = cos( temp_output_250_0 );
				float temp_output_249_0 = sin( temp_output_250_0 );
				float3 appendResult251 = (float3(temp_output_248_0 , -temp_output_249_0 , 1.0));
				float3 appendResult253 = (float3(temp_output_249_0 , temp_output_248_0 , 1.0));
				float dotResult242 = dot( appendResult241 , (mul( float3x3(appendResult251, appendResult253, float3( 0,0,0 )), float3(1,0,0) )).xy );
				float worldLineDissolve279 = dotResult242;
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_WORLD_DIRECTION )
				float staticSwitch93 = worldLineDissolve279;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g30 = dissolveLength152;
				float temp_output_5_0_g30 = ( ( staticSwitch93 - ( dissolveRadius151 - temp_output_21_0_g30 ) ) / temp_output_21_0_g30 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * worldUV208 ) ).r * 1.0 ) + -temp_output_5_0_g30 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4(( noisePattern117 * (appendResult40).xyz ) , (appendResult40).w));
				
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
        	#pragma shader_feature_local _DISSOLVETYPE_RADIUS _DISSOLVETYPE_TEXBASED _DISSOLVETYPE_U_DIRECTION _DISSOLVETYPE_V_DIRECTION _DISSOLVETYPE_WORLD_DIRECTION


			sampler2D _NoiseTex;
			sampler2D _MainTex;
			sampler2D _DissolveGuideTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteAdvancedDissolveUnlit)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseUVOffset)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveRadius)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteAdvancedDissolveUnlit)
			CBUFFER_START( UnityPerMaterial )
			float4 _EdgeColor;
			float2 _NoiseSpeed1;
			float2 _DissolvePanSpeed;
			float _NoiseMin1;
			float _NoiseMax1;
			float _NoiseTiling1;
			float _DissolveSoftness;
			float _PatternScale;
			float _RadiusCenterX;
			float _RadiusCenterY;
			float _DissolveDirection;
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

				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				o.ase_texcoord.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float3 ase_worldPos = IN.ase_texcoord.xyz;
				float2 appendResult112 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner109 = ( 1.0 * _Time.y * _NoiseSpeed1 + ( appendResult112 * _NoiseTiling1 ));
				float smoothstepResult110 = smoothstep( _NoiseMin1 , _NoiseMax1 , tex2D( _NoiseTex, panner109 ).r);
				float noisePattern117 = smoothstepResult110;
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float patternScale162 = _PatternScale;
				float2 _NoiseUVOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_NoiseUVOffset);
				float2 dissolvePanSpeed160 = _DissolvePanSpeed;
				float2 appendResult90 = (float2(ase_worldPos.x , ase_worldPos.y));
				float2 panner126 = ( 1.0 * _Time.y * dissolvePanSpeed160 + appendResult90);
				float2 worldUV208 = ( _NoiseUVOffset_Instance + panner126 );
				float2 texCoord87 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv143 = texCoord87;
				float2 appendResult141 = (float2(_RadiusCenterX , _RadiusCenterY));
				float worldRadiusLength266 = length( ( uv143 - appendResult141 ) );
				float2 appendResult241 = (float2(ase_worldPos.x , ase_worldPos.y));
				float temp_output_250_0 = radians( _DissolveDirection );
				float temp_output_248_0 = cos( temp_output_250_0 );
				float temp_output_249_0 = sin( temp_output_250_0 );
				float3 appendResult251 = (float3(temp_output_248_0 , -temp_output_249_0 , 1.0));
				float3 appendResult253 = (float3(temp_output_249_0 , temp_output_248_0 , 1.0));
				float dotResult242 = dot( appendResult241 , (mul( float3x3(appendResult251, appendResult253, float3( 0,0,0 )), float3(1,0,0) )).xy );
				float worldLineDissolve279 = dotResult242;
				#if defined( _DISSOLVETYPE_RADIUS )
				float staticSwitch93 = worldRadiusLength266;
				#elif defined( _DISSOLVETYPE_TEXBASED )
				float staticSwitch93 = ( 1.0 - tex2D( _DissolveGuideTex, uv143 ).r );
				#elif defined( _DISSOLVETYPE_U_DIRECTION )
				float staticSwitch93 = (uv143).x;
				#elif defined( _DISSOLVETYPE_V_DIRECTION )
				float staticSwitch93 = (uv143).y;
				#elif defined( _DISSOLVETYPE_WORLD_DIRECTION )
				float staticSwitch93 = worldLineDissolve279;
				#else
				float staticSwitch93 = worldRadiusLength266;
				#endif
				float _DissolveRadius_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveRadius);
				float dissolveRadius151 = _DissolveRadius_Instance;
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteAdvancedDissolveUnlit,_DissolveLength);
				float dissolveLength152 = _DissolveLength_Instance;
				float temp_output_21_0_g30 = dissolveLength152;
				float temp_output_5_0_g30 = ( ( staticSwitch93 - ( dissolveRadius151 - temp_output_21_0_g30 ) ) / temp_output_21_0_g30 );
				float temp_output_273_0 = ( ( tex2D( _NoiseTex, ( patternScale162 * worldUV208 ) ).r * 1.0 ) + -temp_output_5_0_g30 );
				float smoothstepResult42 = smoothstep( 0.0 , _DissolveSoftness , temp_output_273_0);
				float temp_output_41_0 = saturate( smoothstepResult42 );
				float smoothstepResult49 = smoothstep( _EdgeValue , ( _EdgeValue + _EdgeSoftness ) , temp_output_273_0);
				float4 lerpResult91 = lerp( tex2DNode5 , _EdgeColor , saturate( ( saturate( ( temp_output_41_0 * ( 1.0 - smoothstepResult49 ) ) ) * _EdgeColor.a ) ));
				float4 appendResult40 = (float4(lerpResult91.rgb , ( tex2DNode5.a * temp_output_41_0 )));
				float4 appendResult122 = (float4(( noisePattern117 * (appendResult40).xyz ) , (appendResult40).w));
				
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
Node;AmplifyShaderEditor.CommentaryNode;262;-7792,736;Inherit;False;2424.785;713.9421;Comment;15;248;249;238;250;252;253;251;245;254;247;255;237;241;242;279;World Direction Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-7664,992;Inherit;False;Property;_DissolveDirection;DissolveDirection;19;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;250;-7360,992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;249;-7168,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;248;-7168,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;252;-7008,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;253;-6816,1088;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;251;-6816,944;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;306;-7792,-400;Inherit;False;634.4478;987.8835;Comment;12;162;151;152;166;35;25;26;81;160;125;307;129;Parameter;1,1,1,1;0;0
Node;AmplifyShaderEditor.MatrixFromVectors;245;-6624,1008;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-5088,-1104;Inherit;False;Property;_RadiusCenterX;RadiusCenterX;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-5088,-1024;Inherit;False;Property;_RadiusCenterY;RadiusCenterY;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;247;-6592,1136;Inherit;False;Constant;_Vector1;Vector 1;32;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-5120,-1232;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;213;-7776,-1008;Inherit;False;1073.408;482.3657;Comment;7;206;207;126;90;165;89;208;world UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;125;-7760,96;Inherit;False;Property;_DissolvePanSpeed;DissolvePanSpeed;3;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-6368,1040;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;237;-6368,832;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-4912,-1232;Inherit;False;uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;-4912,-1072;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;89;-7728,-784;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-7520,96;Inherit;False;dissolvePanSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;255;-6224,1040;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-6160,864;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-4640,-1232;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-7552,-752;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-7600,-624;Inherit;False;160;dissolvePanSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;242;-5968,928;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;267;-4480,-1216;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-3312,-336;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;126;-7312,-704;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;206;-7312,-960;Inherit;False;InstancedProperty;_NoiseUVOffset;NoiseUVOffset;18;1;[PerRendererData];Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;-5808,944;Inherit;False;worldLineDissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-4320,-1216;Inherit;False;worldRadiusLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;-3136,-352;Inherit;True;Property;_DissolveGuideTex;DissolveGuideTex;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;194;-3168,48;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-3152,-80;Inherit;False;143;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-7072,-832;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;81;-7744,-336;Inherit;True;Property;_NoiseTex;NoiseTex;1;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;26;-7744,320;Inherit;False;InstancedProperty;_DissolveLength;DissolveLength;13;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-7744,224;Inherit;False;InstancedProperty;_DissolveRadius;DissolveRadius;12;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-7744,400;Inherit;False;Property;_PatternScale;PatternScale;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;195;-2944,48;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;176;-2912,-80;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;272;-2848,-320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-2944,-432;Inherit;False;266;worldRadiusLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;280;-2976,176;Inherit;False;279;worldLineDissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-7456,-336;Inherit;False;noiseTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-7520,320;Inherit;False;dissolveLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;-7520,224;Inherit;False;dissolveRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-6944,-832;Inherit;False;worldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-7520,400;Inherit;False;patternScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;93;-2416,-208;Inherit;False;Property;_DissolveType;DissolveType;9;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;Radius;TexBased;U_Direction;V_Direction;World_Direction;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;278;-2416,32;Inherit;False;208;worldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-2400,112;Inherit;False;166;noiseTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-2400,192;Inherit;False;162;patternScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-2368,272;Inherit;False;151;dissolveRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-2336,368;Inherit;False;152;dissolveLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1312,144;Inherit;False;Property;_EdgeSoftness;EdgeSoftness;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1280,80;Inherit;False;Property;_EdgeValue;EdgeValue;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;273;-1904,-224;Inherit;False;SGradientDissolve;-1;;30;785db4bdd2f91e7478256f23fbd5abd7;1,26,0;7;29;FLOAT;1;False;24;FLOAT;0;False;22;FLOAT2;0,0;False;17;SAMPLER2D;;False;18;FLOAT;1;False;20;FLOAT;0.5;False;21;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-1103.601,124.47;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1328,-144;Inherit;False;Property;_DissolveSoftness;DissolveSoftness;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;49;-944,64;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;42;-1072,-224;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;116;-1811.114,-1669.366;Inherit;False;1782.696;550.4119;Comment;12;169;108;109;117;107;106;114;113;112;111;110;105;NoisePattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;53;-688,64;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-896,-224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;113;-1761.114,-1619.366;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;129;-7744,-128;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-476.1532,-34.67459;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;112;-1581.265,-1595.578;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1613.866,-1459.578;Inherit;False;Property;_NoiseTiling1;NoiseTiling;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-7456,-144;Inherit;False;mainTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SaturateNode;59;-332.6537,-34.4746;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1417.866,-1534.578;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;108;-1448.123,-1383.594;Inherit;False;Property;_NoiseSpeed1;NoiseSpeed;4;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;54;-752,-784;Inherit;False;Property;_EdgeColor;EdgeColor;17;1;[HDR];Create;True;0;0;0;False;0;False;2.828427,2.029812,1.209014,1;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-129.8849,-33.53051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;109;-1257.123,-1533.594;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-1259.668,-1623.493;Inherit;False;166;noiseTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-896,-432;Inherit;False;307;mainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SaturateNode;205;25.00806,-32.72052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-924.643,-1368.858;Inherit;False;Property;_NoiseMin1;NoiseMin;5;0;Create;True;0;0;0;False;0;False;-1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-955.643,-1293.858;Inherit;False;Property;_NoiseMax1;NoiseMax;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-1063.963,-1558.01;Inherit;True;Property;_NoiseMask1;NoiseMask;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;5;-720,-432;Inherit;True;Property;_test;test;0;0;Create;True;0;0;0;False;0;False;129;7a170cdb7cc88024cb628cfcdbb6705c;7a170cdb7cc88024cb628cfcdbb6705c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SmoothstepOpNode;110;-722.643,-1389.858;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-384,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;91;256,-416;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;977.6847,-288.4521;Inherit;False;FLOAT4;4;0;FLOAT3;1,0,0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-444.2776,-1383.231;Inherit;False;noisePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;120;1172.593,-383.2383;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;1183.636,-464.3752;Inherit;False;117;noisePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;1398.373,-437.7367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;121;1184,-176;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;1808,-432;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;73;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit Forward;0;1;Sprite Unlit Forward;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;75;771.9996,-195.7002;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;ScenePickingPass;0;3;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;72;2048,-432;Float;False;True;-1;2;ASEMaterialInspector;0;15;AmplifyShaders/Sprite AdvancedDissolve Unlit;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit;0;0;Sprite Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;3;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;4;True;True;True;True;False;;False;0
WireConnection;250;0;238;0
WireConnection;249;0;250;0
WireConnection;248;0;250;0
WireConnection;252;0;249;0
WireConnection;253;0;249;0
WireConnection;253;1;248;0
WireConnection;251;0;248;0
WireConnection;251;1;252;0
WireConnection;245;0;251;0
WireConnection;245;1;253;0
WireConnection;254;0;245;0
WireConnection;254;1;247;0
WireConnection;143;0;87;0
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;160;0;125;0
WireConnection;255;0;254;0
WireConnection;241;0;237;1
WireConnection;241;1;237;2
WireConnection;86;0;143;0
WireConnection;86;1;141;0
WireConnection;90;0;89;1
WireConnection;90;1;89;2
WireConnection;242;0;241;0
WireConnection;242;1;255;0
WireConnection;267;0;86;0
WireConnection;126;0;90;0
WireConnection;126;2;165;0
WireConnection;279;0;242;0
WireConnection;266;0;267;0
WireConnection;101;1;144;0
WireConnection;207;0;206;0
WireConnection;207;1;126;0
WireConnection;195;0;194;0
WireConnection;176;0;175;0
WireConnection;272;0;101;1
WireConnection;166;0;81;0
WireConnection;152;0;26;0
WireConnection;151;0;25;0
WireConnection;208;0;207;0
WireConnection;162;0;35;0
WireConnection;93;1;269;0
WireConnection;93;0;272;0
WireConnection;93;2;176;0
WireConnection;93;3;195;0
WireConnection;93;4;280;0
WireConnection;273;24;93;0
WireConnection;273;22;278;0
WireConnection;273;17;274;0
WireConnection;273;18;275;0
WireConnection;273;20;276;0
WireConnection;273;21;277;0
WireConnection;57;0;51;0
WireConnection;57;1;52;0
WireConnection;49;0;273;0
WireConnection;49;1;51;0
WireConnection;49;2;57;0
WireConnection;42;0;273;0
WireConnection;42;2;43;0
WireConnection;53;0;49;0
WireConnection;41;0;42;0
WireConnection;58;0;41;0
WireConnection;58;1;53;0
WireConnection;112;0;113;1
WireConnection;112;1;113;2
WireConnection;307;0;129;0
WireConnection;59;0;58;0
WireConnection;105;0;112;0
WireConnection;105;1;107;0
WireConnection;204;0;59;0
WireConnection;204;1;54;4
WireConnection;109;0;105;0
WireConnection;109;2;108;0
WireConnection;205;0;204;0
WireConnection;106;0;169;0
WireConnection;106;1;109;0
WireConnection;5;0;309;0
WireConnection;110;0;106;1
WireConnection;110;1;111;0
WireConnection;110;2;114;0
WireConnection;39;0;5;4
WireConnection;39;1;41;0
WireConnection;91;0;5;0
WireConnection;91;1;54;0
WireConnection;91;2;205;0
WireConnection;40;0;91;0
WireConnection;40;3;39;0
WireConnection;117;0;110;0
WireConnection;120;0;40;0
WireConnection;123;0;118;0
WireConnection;123;1;120;0
WireConnection;121;0;40;0
WireConnection;122;0;123;0
WireConnection;122;3;121;0
WireConnection;72;1;122;0
ASEEND*/
//CHKSM=134EEB6C395A048670C036CD590722944AD1D317