using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelationPass : ScriptableRenderPass
{
    const string ProfilerTag = "Pixelation Pass";

    public PixelationPass(PixelationFeature.PassSetting settings) {

    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        base.Configure(cmd, cameraTextureDescriptor);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        throw new NotImplementedException();
    }
}
