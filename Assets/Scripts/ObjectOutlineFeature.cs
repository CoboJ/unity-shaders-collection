using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ObjectOutlineFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PassSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRendering;
        public string outlinedObjectName;
        public Material writeObject;
        public Material applyOutline;
    }
    
    public PassSettings settings = new();
    ObjectOutlinePass pass;

    public override void Create()
    {
        pass = new ObjectOutlinePass(settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if(renderingData.cameraData.isPreviewCamera) { return; }
        
        renderer.EnqueuePass(pass);
    }
}