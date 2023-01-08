Shader "Custom/ApplyOutline"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Range(0, 1)) = 1
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            HLSLPROGRAM
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
            TEXTURE2D(_SelectionBuffer);
            SAMPLER(sampler_SelectionBuffer);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _OutlineColor;
            float _OutlineWidth;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                #define DIV_SQRT_2 0.70710678118
                float2 directions[8] = {float2(1, 0), float2(0, 1), float2(-1, 0), float2(0, -1),
                float2(DIV_SQRT_2, DIV_SQRT_2), float2(-DIV_SQRT_2, DIV_SQRT_2),
                float2(-DIV_SQRT_2, -DIV_SQRT_2), float2(DIV_SQRT_2, -DIV_SQRT_2)};

                float aspect = _ScreenParams.x * (_ScreenParams.w - 1);
                float2 sampleDistance = float2(_OutlineWidth / aspect, _OutlineWidth);

                float maxAlpha = 0;
                for(uint index = 0; index < 8; index++) {
                    float2 sampleUV = i.uv + directions[index] * sampleDistance;
                    maxAlpha = max(maxAlpha, SAMPLE_TEXTURE2D(_SelectionBuffer, sampler_SelectionBuffer, sampleUV).a);
                }

                float border = max(0, maxAlpha - SAMPLE_TEXTURE2D(_SelectionBuffer, sampler_SelectionBuffer, i.uv).a);

                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                col = lerp(col, _OutlineColor, border);

                return col;
            }
            ENDHLSL
        }
    }
}
