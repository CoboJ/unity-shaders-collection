using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ScreenBlurFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PassSetting {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;

        [Range(1, 8)] public int downsample = 1;
        [Range(0, 20)] public int blurStrength = 5;
    }
    
    ScreenBlurPass pass;
    public PassSetting passSetting = new();

    public override void Create()
    {
        pass = new ScreenBlurPass(passSetting);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if(renderingData.cameraData.isPreviewCamera) { return; }
        
        renderer.EnqueuePass(pass);
    }
}
