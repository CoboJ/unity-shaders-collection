Shader "Custom/ScreenBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };
            
        TEXTURE2D(_MainTex);

        SAMPLER(sampler_MainTex);
        float4 _MainTex_TexelSize;
        float4 _MainTex_ST;

        int _BlurStrength;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = TransformObjectToHClip(v.vertex.xyz);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }
        ENDHLSL

        Pass
        {
            Name "Vertical Box Blur"
            
            HLSLPROGRAM
            half4 frag (v2f i) : SV_Target
            {
                float2 res = _MainTex_TexelSize.xy;
                half4 sum = 0;

                int samples = 2 * _BlurStrength + 1;

                for (float y = 0; y < samples; y++)
                {
                    float2 offset = float(0, y - _BlurStrength);
                    sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + offset * res);
                }

                return sum / samples;
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Horizontal Box Blur"
            
            HLSLPROGRAM
            half4 frag (v2f i) : SV_Target
            {
                float2 res = _MainTex_TexelSize.xy;
                half4 sum = 0;

                int samples = 2 * _BlurStrength + 1;

                for (float x = 0; x < samples; x++)
                {
                    float2 offset = float(x - _BlurStrength, 0);
                    sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + offset * res);
                }

                return sum / samples;
            }
            ENDHLSL
        }
    }
}
