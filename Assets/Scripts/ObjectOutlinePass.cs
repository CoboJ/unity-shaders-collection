using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ObjectOutlinePass : ScriptableRenderPass
{
    const string ProfilerTag = "Object Outline Pass";

    RenderTargetIdentifier selectionBuffer, colorBuffer;
    int selectionBufferID = Shader.PropertyToID("_SelectionBuffer");

    RTHandle _Destination;
    Renderer outlinedObject;
    Material writeObject;
    Material applyOutline;

    ObjectOutlineFeature.PassSettings settings;
    
    public ObjectOutlinePass(ObjectOutlineFeature.PassSettings settings)
    {
        this.outlinedObject = GameObject.Find(settings.outlinedObjectName).GetComponent<Renderer>();
        this.writeObject = settings.writeObject;
        this.applyOutline = settings.applyOutline;
        this.settings = settings;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        colorBuffer = renderingData.cameraData.renderer.cameraColorTarget;

        cmd.GetTemporaryRT(selectionBufferID, descriptor);
        selectionBuffer = new RenderTargetIdentifier(selectionBufferID);
        ConfigureTarget(selectionBuffer);
        ConfigureClear(ClearFlag.All, Color.clear);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();

        using (new ProfilingScope(cmd, new ProfilingSampler(ProfilerTag)))
        {
            if (outlinedObject != null)
            {
                cmd.DrawRenderer(outlinedObject, writeObject);
            } 
            else
            {
                Debug.LogWarning("Outlined object renderer not found!");
            }

            Blit(cmd, selectionBuffer, colorBuffer);
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (cmd == null) throw new ArgumentNullException("cmd");

        cmd.ReleaseTemporaryRT(selectionBufferID);
    }
}
