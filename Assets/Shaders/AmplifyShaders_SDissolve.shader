// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaders/Sprite Dissolve"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_DissolveValue("DissolveValue", Float) = 0.94
		[Toggle]_InverseDissolveDirection("InverseDissolveDirection", Float) = 1
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_DissolveRadius("DissolveRadius", Float) = 0
		_DissolveLength("DissolveLength", Float) = 1
		_EdgeOffset("EdgeOffset", Float) = 0.5
		_EdgeSmoothness("EdgeSmoothness", Float) = -0.01
		[HDR]_EdgeColor("EdgeColor", Color) = (1,1,1,1)

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


			sampler2D _MainTex;
			sampler2D _DissolveTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteDissolve)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				UNITY_DEFINE_INSTANCED_PROP(float4, _DissolveTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EdgeColor)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveValue)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteDissolve)
			CBUFFER_START( UnityPerMaterial )
			float _EdgeOffset;
			float _EdgeSmoothness;
			float _DissolveRadius;
			float _InverseDissolveDirection;
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

				float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_Color);
				float2 texCoord23 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode14 = tex2D( _MainTex, texCoord23 );
				float4 _DissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveTex_ST);
				float2 uv_DissolveTex = IN.texCoord0.xy * _DissolveTex_ST_Instance.xy + _DissolveTex_ST_Instance.zw;
				float _DissolveValue_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveValue);
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveLength);
				float temp_output_66_0 = ( ( _DissolveValue_Instance - _DissolveRadius ) / _DissolveLength_Instance );
				float lerpResult67 = lerp( temp_output_66_0 , ( 1.0 - temp_output_66_0 ) , _InverseDissolveDirection);
				float dissolve69 = lerpResult67;
				float clip74 = saturate( ( tex2D( _DissolveTex, uv_DissolveTex ).r + dissolve69 ) );
				float smoothstepResult90 = smoothstep( _EdgeOffset , ( _EdgeOffset + _EdgeSmoothness ) , clip74);
				float4 _EdgeColor_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_EdgeColor);
				float3 edge96 = ( smoothstepResult90 * _EdgeColor_Instance.rgb );
				float4 appendResult104 = (float4(( ( _Color_Instance.rgb * tex2DNode14.rgb ) + edge96 ) , ( tex2DNode14.a * step( 0.5 , clip74 ) )));
				
				float4 Color = appendResult104;

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


			sampler2D _MainTex;
			sampler2D _DissolveTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteDissolve)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				UNITY_DEFINE_INSTANCED_PROP(float4, _DissolveTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EdgeColor)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveValue)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteDissolve)
			CBUFFER_START( UnityPerMaterial )
			float _EdgeOffset;
			float _EdgeSmoothness;
			float _DissolveRadius;
			float _InverseDissolveDirection;
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

				float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_Color);
				float2 texCoord23 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode14 = tex2D( _MainTex, texCoord23 );
				float4 _DissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveTex_ST);
				float2 uv_DissolveTex = IN.texCoord0.xy * _DissolveTex_ST_Instance.xy + _DissolveTex_ST_Instance.zw;
				float _DissolveValue_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveValue);
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveLength);
				float temp_output_66_0 = ( ( _DissolveValue_Instance - _DissolveRadius ) / _DissolveLength_Instance );
				float lerpResult67 = lerp( temp_output_66_0 , ( 1.0 - temp_output_66_0 ) , _InverseDissolveDirection);
				float dissolve69 = lerpResult67;
				float clip74 = saturate( ( tex2D( _DissolveTex, uv_DissolveTex ).r + dissolve69 ) );
				float smoothstepResult90 = smoothstep( _EdgeOffset , ( _EdgeOffset + _EdgeSmoothness ) , clip74);
				float4 _EdgeColor_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_EdgeColor);
				float3 edge96 = ( smoothstepResult90 * _EdgeColor_Instance.rgb );
				float4 appendResult104 = (float4(( ( _Color_Instance.rgb * tex2DNode14.rgb ) + edge96 ) , ( tex2DNode14.a * step( 0.5 , clip74 ) )));
				
				float4 Color = appendResult104;

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


			sampler2D _MainTex;
			sampler2D _DissolveTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteDissolve)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				UNITY_DEFINE_INSTANCED_PROP(float4, _DissolveTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EdgeColor)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveValue)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteDissolve)
			CBUFFER_START( UnityPerMaterial )
			float _EdgeOffset;
			float _EdgeSmoothness;
			float _DissolveRadius;
			float _InverseDissolveDirection;
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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
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
				float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_Color);
				float2 texCoord23 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode14 = tex2D( _MainTex, texCoord23 );
				float4 _DissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveTex_ST);
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST_Instance.xy + _DissolveTex_ST_Instance.zw;
				float _DissolveValue_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveValue);
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveLength);
				float temp_output_66_0 = ( ( _DissolveValue_Instance - _DissolveRadius ) / _DissolveLength_Instance );
				float lerpResult67 = lerp( temp_output_66_0 , ( 1.0 - temp_output_66_0 ) , _InverseDissolveDirection);
				float dissolve69 = lerpResult67;
				float clip74 = saturate( ( tex2D( _DissolveTex, uv_DissolveTex ).r + dissolve69 ) );
				float smoothstepResult90 = smoothstep( _EdgeOffset , ( _EdgeOffset + _EdgeSmoothness ) , clip74);
				float4 _EdgeColor_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_EdgeColor);
				float3 edge96 = ( smoothstepResult90 * _EdgeColor_Instance.rgb );
				float4 appendResult104 = (float4(( ( _Color_Instance.rgb * tex2DNode14.rgb ) + edge96 ) , ( tex2DNode14.a * step( 0.5 , clip74 ) )));
				
				float4 Color = appendResult104;

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


			sampler2D _MainTex;
			sampler2D _DissolveTex;
			UNITY_INSTANCING_BUFFER_START(AmplifyShadersSpriteDissolve)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				UNITY_DEFINE_INSTANCED_PROP(float4, _DissolveTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EdgeColor)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveValue)
				UNITY_DEFINE_INSTANCED_PROP(float, _DissolveLength)
			UNITY_INSTANCING_BUFFER_END(AmplifyShadersSpriteDissolve)
			CBUFFER_START( UnityPerMaterial )
			float _EdgeOffset;
			float _EdgeSmoothness;
			float _DissolveRadius;
			float _InverseDissolveDirection;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            float4 _SelectionID;

			
			VertexOutput vert(VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
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
				float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_Color);
				float2 texCoord23 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode14 = tex2D( _MainTex, texCoord23 );
				float4 _DissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveTex_ST);
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST_Instance.xy + _DissolveTex_ST_Instance.zw;
				float _DissolveValue_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveValue);
				float _DissolveLength_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_DissolveLength);
				float temp_output_66_0 = ( ( _DissolveValue_Instance - _DissolveRadius ) / _DissolveLength_Instance );
				float lerpResult67 = lerp( temp_output_66_0 , ( 1.0 - temp_output_66_0 ) , _InverseDissolveDirection);
				float dissolve69 = lerpResult67;
				float clip74 = saturate( ( tex2D( _DissolveTex, uv_DissolveTex ).r + dissolve69 ) );
				float smoothstepResult90 = smoothstep( _EdgeOffset , ( _EdgeOffset + _EdgeSmoothness ) , clip74);
				float4 _EdgeColor_Instance = UNITY_ACCESS_INSTANCED_PROP(AmplifyShadersSpriteDissolve,_EdgeColor);
				float3 edge96 = ( smoothstepResult90 * _EdgeColor_Instance.rgb );
				float4 appendResult104 = (float4(( ( _Color_Instance.rgb * tex2DNode14.rgb ) + edge96 ) , ( tex2DNode14.a * step( 0.5 , clip74 ) )));
				
				float4 Color = appendResult104;
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
Node;AmplifyShaderEditor.RangedFloatNode;60;-3568,1392;Inherit;False;Property;_DissolveRadius;DissolveRadius;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-3568,1312;Inherit;False;InstancedProperty;_DissolveValue;DissolveValue;2;0;Create;True;0;0;0;False;0;False;0.94;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-3360,1312;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-3104,1488;Inherit;False;InstancedProperty;_DissolveLength;DissolveLength;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;66;-2864,1312;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;68;-2656,1408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2752,1488;Inherit;False;Property;_InverseDissolveDirection;InverseDissolveDirection;3;1;[Toggle];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-2432,1312;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-3360,544;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-3376,352;Inherit;True;Property;_DissolveTex;DissolveTex;4;0;Create;True;0;0;0;False;0;False;937066ef7ca7d124e950924ee50fdf23;937066ef7ca7d124e950924ee50fdf23;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2256,1312;Inherit;True;dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;108;-3056,512;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2944,736;Inherit;False;69;dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-2672,560;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;73;-2464,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3072,1952;Inherit;False;Property;_EdgeOffset;EdgeOffset;7;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3104,2032;Inherit;False;Property;_EdgeSmoothness;EdgeSmoothness;8;0;Create;True;0;0;0;False;0;False;-0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-2304,560;Inherit;True;clip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-2848,2016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-3056,1872;Inherit;False;74;clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;90;-2688,1936;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;95;-2704,2160;Inherit;False;InstancedProperty;_EdgeColor;EdgeColor;9;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;524.7559,-419.4265;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-2419.995,2084.221;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;21;828.7559,-611.4265;Inherit;False;InstancedProperty;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;14;768,-416;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-2240,2096;Inherit;True;edge;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;86;1024,-32;Inherit;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;992,48;Inherit;False;74;clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;1096.887,-473.4427;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;928,-192;Inherit;True;96;edge;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;106;1184,0;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;1264,-464;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;1388.163,-260.3099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;1456,-416;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;101;1600,-208;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit Forward;0;1;Sprite Unlit Forward;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;102;1600,-208;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;103;1600,-208;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;ScenePickingPass;0;3;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;100;1648,-416;Float;False;True;-1;2;ASEMaterialInspector;0;15;AmplifyShaders/Sprite Dissolve;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit;0;0;Sprite Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;3;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;4;True;True;True;True;False;;False;0
WireConnection;87;0;109;0
WireConnection;87;1;60;0
WireConnection;66;0;87;0
WireConnection;66;1;61;0
WireConnection;68;0;66;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;67;2;64;0
WireConnection;69;0;67;0
WireConnection;108;0;5;0
WireConnection;108;1;107;0
WireConnection;71;0;108;1
WireConnection;71;1;70;0
WireConnection;73;0;71;0
WireConnection;74;0;73;0
WireConnection;92;0;91;0
WireConnection;92;1;93;0
WireConnection;90;0;99;0
WireConnection;90;1;91;0
WireConnection;90;2;92;0
WireConnection;94;0;90;0
WireConnection;94;1;95;5
WireConnection;14;1;23;0
WireConnection;96;0;94;0
WireConnection;20;0;21;5
WireConnection;20;1;14;5
WireConnection;106;0;86;0
WireConnection;106;1;75;0
WireConnection;105;0;20;0
WireConnection;105;1;97;0
WireConnection;110;0;14;4
WireConnection;110;1;106;0
WireConnection;104;0;105;0
WireConnection;104;3;110;0
WireConnection;100;1;104;0
ASEEND*/
//CHKSM=9A05CC095594C263C1C2318FC52AFDD5C442E274