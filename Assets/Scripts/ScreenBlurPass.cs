using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ScreenBlurPass : ScriptableRenderPass
{
    const string ProfilerTag = "Screen Blur Pass";

    ScreenBlurFeature.PassSetting passSetting;

    RenderTargetIdentifier colorBuffer, temporaryBuffer;
    int temporaryBufferID = Shader.PropertyToID("_TemporaryBuffer");

    Material material;

    static readonly int BlurStrengthProperty = Shader.PropertyToID("_BlurStrength");

    public ScreenBlurPass(ScreenBlurFeature.PassSetting settings) {
        this.passSetting = settings;
        renderPassEvent = settings.renderPassEvent;

        if(material = null) material = CoreUtils.CreateEngineMaterial("Hidden/Box Blur");

        material.SetInteger(BlurStrengthProperty, passSetting.blurStrength);
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;

        descriptor.width /= passSetting.downsample;
        descriptor.height /= passSetting.downsample;

        descriptor.depthBufferBits = 0;

        colorBuffer = renderingData.cameraData.renderer.cameraColorTarget;

        cmd.GetTemporaryRT(temporaryBufferID, descriptor, FilterMode.Bilinear);
        temporaryBuffer = new RenderTargetIdentifier(temporaryBufferID);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, new ProfilingSampler(ProfilerTag)))
        {
            Blit(cmd, colorBuffer, temporaryBuffer, material, 0);
            Blit(cmd, temporaryBuffer, colorBuffer, material, 1);
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
