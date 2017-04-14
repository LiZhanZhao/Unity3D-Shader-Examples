using UnityEngine;
using System.Collections;

public class CameraBloom : MonoBehaviour {

    public Material bloomMaterial;
    public int blurIterations = 4;
    public float blurSpread = 1.0f;
    public int blurTextureSize = 256;
    public Color glowColorMultiplier = Color.white;
    [Range(0,1)]
    public float glowAlpha = 0;

    private Camera shaderCamera;
    private RenderTexture replaceRenderTexture;
    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            Debug.Log("Image effects are not supported (do you have Unity Pro?)");
            enabled = false;
        }

        
        shaderCamera = new GameObject("Test", typeof(Camera)).GetComponent<Camera>();

        Camera origCamera = GetComponent<Camera>();
        replaceRenderTexture = new RenderTexture((int)origCamera.pixelWidth, (int)origCamera.pixelHeight, 0, RenderTextureFormat.ARGB32);
        replaceRenderTexture.wrapMode = TextureWrapMode.Clamp;
        replaceRenderTexture.useMipMap = false;
        replaceRenderTexture.filterMode = FilterMode.Bilinear;
        replaceRenderTexture.Create();

        UpdateMatProperty();
    }

    void UpdateMatProperty()
    {
        if (bloomMaterial != null)
        {
            bloomMaterial.SetFloat("_BlurSpread", blurSpread);
            bloomMaterial.SetColor("_GlowColorMultiplier", glowColorMultiplier);
            bloomMaterial.SetFloat("_GlowAlpha", glowAlpha);       
        }
    }

    public void OnPreRender()
    {
        Camera origCamera = GetComponent<Camera>();
        shaderCamera.CopyFrom(origCamera);
        //shaderCamera.backgroundColor = Color.clear;
        shaderCamera.backgroundColor = new Color(0, 0, 0, 0);
        shaderCamera.clearFlags = CameraClearFlags.SolidColor;
        
        shaderCamera.renderingPath = RenderingPath.Forward;
        shaderCamera.targetTexture = replaceRenderTexture;

        // 这里可以选择哪一些物体才进行发光,渲成replaceRenderTexture之后，再传入glowMaterial的"_Glow"
        //shaderCamera.RenderWithShader(glowReplaceShader, "RenderType");

    }

	public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (bloomMaterial != null)
        {

            UpdateMatProperty();
            RenderTexture blurA = RenderTexture.GetTemporary(blurTextureSize, blurTextureSize, 0, RenderTextureFormat.ARGB32);
            RenderTexture blurB = RenderTexture.GetTemporary(blurTextureSize, blurTextureSize, 0, RenderTextureFormat.ARGB32);
            RenderTexture blurRes = null;
            // init blurB
            Graphics.Blit(replaceRenderTexture, blurB);

            for (int i = 0; i < blurIterations; ++i)
            {
                
                if (i % 2 == 0)
                {
                    blurA.DiscardContents();
                    // pass 0 - blur the main texture
                    Graphics.Blit(blurB, blurA, bloomMaterial, 0);
                    blurRes = blurA;
                }
                else
                {
                    blurB.DiscardContents();
                    //blur
                    Graphics.Blit(blurA, blurB, bloomMaterial, 0);
                    blurRes = blurB;
                }
            }


            // 测试模糊效果
            //Graphics.Blit(blurRes, destination);

            // 方法二
            ///*
            //bloomMaterial.SetTexture("_MainTex", blurRes);
            RenderTexture blurC = RenderTexture.GetTemporary(blurTextureSize, blurTextureSize, 0, RenderTextureFormat.ARGB32);
            Graphics.Blit(blurRes, blurC, bloomMaterial, 2);

            // */ 
            bloomMaterial.SetTexture("_Blur", blurC);
             
            Graphics.Blit(source, destination, bloomMaterial, 1);

            blurRes = null;
            RenderTexture.ReleaseTemporary(blurA);
            RenderTexture.ReleaseTemporary(blurB);
            RenderTexture.ReleaseTemporary(blurC);

        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
