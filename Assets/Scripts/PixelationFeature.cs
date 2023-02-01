using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PixelationFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PassSetting {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
        [Range(1, 16)] int pixelation = 1;
    }

    PixelationPass pass;
    public PassSetting passSetting = new();
    
    public override void Create()
    {
        pass = new PixelationPass(passSetting);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if(renderingData.cameraData.isPreviewCamera) { return; }
        
        renderer.EnqueuePass(pass);
    }
}
