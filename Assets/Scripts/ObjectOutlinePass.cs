using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ObjectOutlinePass : ScriptableRenderPass
{
    const string ProfilerTag = "Object Outline Pass";

    RenderTargetIdentifier selectionBuffer, _Source, _Destination;
    int _DestinationID = Shader.PropertyToID("_Destination");
    Renderer outlinedObject;
    Material writeObject;
    Material applyOutline;

    ObjectOutlineFeature.PassSettings settings;
    static readonly int selectionBufferID = Shader.PropertyToID("_SelectionBuffer");
    
    public ObjectOutlinePass(ObjectOutlineFeature.PassSettings settings)
    {
        this.renderPassEvent = settings.renderPassEvent;
        this.outlinedObject = GameObject.Find(settings.outlinedObjectName).GetComponent<Renderer>();
        this.writeObject = settings.writeObject;
        this.applyOutline = settings.applyOutline;
        this.settings = settings;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        _Source = renderingData.cameraData.renderer.cameraColorTarget;
        
        cmd.GetTemporaryRT(_DestinationID, descriptor);
        _Destination = new RenderTargetIdentifier(_DestinationID);

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

            Blit(cmd, _Source, _Destination, applyOutline);
            Blit(cmd, _Destination, _Source);
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (cmd == null) throw new ArgumentNullException("cmd");

        cmd.ReleaseTemporaryRT(selectionBufferID);
        cmd.ReleaseTemporaryRT(_DestinationID);
    }
}
