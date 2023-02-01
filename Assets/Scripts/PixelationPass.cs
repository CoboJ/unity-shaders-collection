using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelationPass : ScriptableRenderPass
{
    const string ProfilerTag = "Pixelation Pass";

    PixelationFeature.PassSetting settings = null;

    RenderTargetIdentifier colorBuffer, temporaryBuffer;
    int temporaryBufferID = Shader.PropertyToID("_TemporaryBuffer");

    public PixelationPass(PixelationFeature.PassSetting settings) {
        this.renderPassEvent = settings.renderPassEvent;
        this.settings = settings;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        descriptor.height /= settings.pixelation;
        descriptor.width /= settings.pixelation;

        colorBuffer = renderingData.cameraData.renderer.cameraColorTarget;
        
        cmd.GetTemporaryRT(temporaryBufferID, descriptor);
        temporaryBuffer = new RenderTargetIdentifier(temporaryBufferID);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();

        using (new ProfilingScope(cmd, new ProfilingSampler(ProfilerTag)))
        {
            Blit(cmd, colorBuffer, temporaryBuffer);
            Blit(cmd, temporaryBuffer, colorBuffer);
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (cmd == null) throw new ArgumentNullException("cmd");

        cmd.ReleaseTemporaryRT(temporaryBufferID);
    }
}
