Shader "Custom/OutlineSprite"
{
    Properties
    {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Range(0, 1)) = 1
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline"="UniversalRenderPipeline" 
        }

        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite off 
        Cull off

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
                half4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                half4 color : COLOR;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            half4 _Color;
            half4 _OutlineColor;
            float _OutlineWidth;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexInputs.positionCS;
                o.worldPos = vertexInputs.positionWS;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            float2 uvPerWorldUnit (float2 uv, float2 space) 
            {
                float2 uvPerPixelX = abs(ddx(uv));
                float2 uvPerPixelY = abs(ddy(uv));
                float unitPerPixelX = length(ddx(space));
                float unitPerPixelY = length(ddx(space));
                float2 uvPerUnitX = uvPerPixelX / unitPerPixelX;
                float2 uvPerUnitY = uvPerPixelY / unitPerPixelY;
                return (uvPerUnitX + uvPerUnitY);
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                col *= _Color;
                col *= i.color;

                float2 sampleDistance = uvPerWorldUnit(i.uv, i.worldPos.xy) * _OutlineWidth;

                #define DIV_SQRT_2 0.70710678118
                float2 directions[8] = {float2(1, 0), float2(0, 1), float2(-1, 0), float2(0, -1),
                float2(DIV_SQRT_2, DIV_SQRT_2), float2(-DIV_SQRT_2, DIV_SQRT_2),
                float2(-DIV_SQRT_2, -DIV_SQRT_2), float2(DIV_SQRT_2, -DIV_SQRT_2)};

                float maxAlpha = 0;
                for(uint index = 0; index < 8; index++) {
                    float2 sampleUV = i.uv + directions[index] * sampleDistance;
                    maxAlpha = max(maxAlpha, SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, sampleUV).a);
                }


                col.rgb = lerp(_OutlineColor.rgb, col.rgb, col.a);
                col.a = max(col.a, maxAlpha);

                return col;
            }
            ENDHLSL
        }
    }
}
