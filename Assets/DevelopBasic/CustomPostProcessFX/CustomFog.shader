Shader "Hidden/Custom/CustomFog"
{
	Properties 
	{
	    _MainTex ("Main Texture", 2D) = "white" {}
	}
    
    HLSLINCLUDE
// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);

    TEXTURE2D_X_FLOAT(_CameraDepthTexture);
    SAMPLER(sampler_CameraDepthTexture);

    half4 _Color;
    half _StartDistance;
    half _FadeLength;
    half _ControlOffset;
    half _ControlValue;
    half _Intensity;

    struct Attributes
    {
        float4 positionOS : POSITION;
        float2 uv         : TEXCOORD0;
    };

    struct Varyings
    {
        float2 uv        : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float4 scrPos : TEXCOORD1;
        UNITY_VERTEX_OUTPUT_STEREO
    };
    
    float DoubleCubic(float a, float b, float t){
        if(t>a){
            float temp = (t-a)/(1-a);
            temp = pow(temp, 3);
            return b+(1-b)*temp; 
        }
        else{
            float temp = 1-t/a;
            temp = pow(temp, 3);
            return b-b*temp;
        }
    }
    Varyings vert(Attributes input)
    {
        Varyings o = (Varyings)0;
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o)
        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        o.vertex = vertexInput.positionCS;
        o.scrPos = ComputeScreenPos(vertexInput.positionCS);
        o.uv = input.uv;
        
        return o;
    }
    float4 frag (Varyings input) : SV_Target 
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        float2 screenPos = input.scrPos.xy/input.scrPos.w;
        float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos).r;
        float depthValue = LinearEyeDepth(depth, _ZBufferParams);
        float fogCurve = saturate((depthValue-_StartDistance)/_FadeLength);
        float fade = saturate(DoubleCubic(_ControlOffset, _ControlValue, fogCurve));

    	float4 screen = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
        float4 color = screen;
        color.rgb = lerp(screen.rgb, _Color.rgb, fade);
        color.rgb = lerp(screen.rgb, color.rgb, _Intensity);
    	return color;
    }

    ENDHLSL
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
            ENDHLSL
        }
    }
}