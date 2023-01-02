Shader "Custom/ToonShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ToonLUT ("Toon LUT", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim Power", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            /*#include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"*/

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            TEXTURE2D(_ToonLUT);
            SAMPLER(sampler_ToonLUT);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _ToonLUT_ST;
            half3 _RimColor;
            half _RimPower;
            half4 _Color;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                //o.vertex = TransformObjectToHClip(v.vertex.xyz);
                VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexInputs.positionCS;
                //o.normal = normalize(mul(unity_ObjectToWorld, v.normal));
                o.normal = normalize(TransformObjectToWorldNormal(v.normal));
                o.viewDir = GetWorldSpaceNormalizeViewDir(vertexInputs.positionWS);
                o.uv = v.uv;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float ndotl = dot(i.normal, _MainLightPosition.xyz);
                float ndotv = saturate(dot(i.normal, i.viewDir));

                float4 lut = SAMPLE_TEXTURE2D(_ToonLUT, sampler_ToonLUT, float2(ndotl, 0));
                float3 rim = _RimColor * pow(1 - ndotv, _RimPower) * ndotl;

                float3 directDiffuse = lut.xyz * _MainLightColor.rgb;
                float3 indirectDiffuse = unity_AmbientSky.xyz;

                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color;
                col.rgb *= directDiffuse + indirectDiffuse;
                col.rgb += rim;
                col.a = 1.0;
                
                return col;
            }
            ENDHLSL
        }
    }
}
