void IceDepth_half(
    in UnityTexture2D MainTex,
    in float2 UV,
    in float Samples,
    in float Offset,
    in float3 WPOS,
    in float Lerp,
    in int LOD,
    out float4 Out)
{
    half4 col = 0;
    half u_off = 0;
    half v_off = 0;
    half samples = Samples;

    for(int s = 0; s < samples; s++)
    {
        float2 uvs = float2(u_off, v_off);
        col += SAMPLE_TEXTURE2D_LOD(MainTex, MainTex.samplerstate, uvs + UV, LOD);
        u_off += Offset * (_WorldSpaceCameraPos.x - WPOS.x);
        v_off += Offset * (_WorldSpaceCameraPos.z - WPOS.z);
    }

    half4 render = (col /= samples);
    Out = lerp(SAMPLE_TEXTURE2D(MainTex, MainTex.samplerstate, UV), render, Lerp);
}