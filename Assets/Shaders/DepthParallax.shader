Shader "Custom/DepthParallax"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DepthMap("DepthMap", 2D) = "grey" {}
        _Normal("Normal", 2D) = "bump" {}
        _Parallax("Parallax Depth", Range(0,10)) = 0.0
    }
    SubShader
    {        
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

        LOD 200

        HLSLPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_DepthMap);
        SAMPLER(sampler_DepthMap);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Normal;
            float3 viewDir;
        };

        CBUFFER_START(UnityPerMaterial)
        half _Glossiness;
        half _Metallic;
        half4 _Color;
        float _Parallax;
        CBUFFER_END

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // depth map for parallax   
            float d = SAMPLE_TEXTURE2D(_DepthMap, sampler_DepthMap, IN.uv_MainTex).r;
            float2 parallax = ParallaxOffset(d, _Parallax, IN.viewDir);
            o.Normal = UnpackNormal(SAMPLE_TEXTURE2D(_Normal, sampler_Normal, IN.uv_Normal + parallax));
            // Albedo comes from a texture tinted by color
            half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDHLSL
    }
    FallBack "Diffuse"
}
