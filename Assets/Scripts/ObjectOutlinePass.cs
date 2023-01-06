using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ObjectOutlinePass : ScriptableRenderPass
{
    const string ProfilerTag = "Object Outline Pass";

    ObjectOutlineFeature.PassSettings settings;
    
    public ObjectOutlinePass(ObjectOutlineFeature.PassSettings settings)
    {
        this.settings = settings;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        throw new System.NotImplementedException();
    }
}
