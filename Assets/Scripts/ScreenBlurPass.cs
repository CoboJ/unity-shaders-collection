using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ScreenBlurPass : ScriptableRenderPass
{
    public ScreenBlurPass(ScreenBlurFeature.PassSetting settings) {

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        throw new System.NotImplementedException();
    }
}
