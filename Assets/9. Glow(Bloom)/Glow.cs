using UnityEngine;
using System.Collections;

public class Glow : MonoBehaviour {

    public Material glowMaterial;
    public float blurSpread = 1.0f;
    public float glowStrength = 1.2f;
    public Color glowColorMultiplier = Color.white;

    // renderTexture size
    public int downsampleSize = 256;
    // 模糊的循环次数
    public int blurIterations = 4;


    // private 
    private Camera shaderCamera;
    private RenderTexture replaceRenderTexture;

	// Use this for initialization
	void Start () {
        if (!SystemInfo.supportsImageEffects)
        {
            Debug.Log("Image effects are not supported (do you have Unity Pro?)");
            enabled = false;
        }
        UpdateMatProperty();


        shaderCamera = new GameObject("Test", typeof(Camera)).GetComponent<Camera>();

        Camera origCamera = GetComponent<Camera>();
        replaceRenderTexture = new RenderTexture((int)origCamera.pixelWidth, (int)origCamera.pixelHeight, 0, RenderTextureFormat.ARGB32);
        replaceRenderTexture.wrapMode = TextureWrapMode.Clamp;
        replaceRenderTexture.useMipMap = false;
        replaceRenderTexture.filterMode = FilterMode.Bilinear;
        replaceRenderTexture.Create();

        glowMaterial.SetTexture("_Glow", replaceRenderTexture);

	}


    void UpdateMatProperty()
    {
        if (glowMaterial != null)
        {
            glowMaterial.SetFloat("_BlurSpread", blurSpread);
            glowMaterial.SetFloat("_GlowStrength", glowStrength);
            glowMaterial.SetColor("_GlowColorMultiplier", glowColorMultiplier);
        }
    }


    public void OnPreRender()
    {
        Camera origCamera = GetComponent<Camera>();
        shaderCamera.CopyFrom(origCamera);
        shaderCamera.backgroundColor = Color.clear;
        shaderCamera.clearFlags = CameraClearFlags.SolidColor;
        shaderCamera.renderingPath = RenderingPath.Forward;
        shaderCamera.targetTexture = replaceRenderTexture;

        // 这里可以选择哪一些物体才进行发光,渲成replaceRenderTexture之后，再传入glowMaterial的"_Glow"
        //shaderCamera.RenderWithShader(glowReplaceShader, "RenderType");

    }
    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (glowMaterial != null)
        {
            UpdateMatProperty();
            RenderTexture blurA = RenderTexture.GetTemporary(downsampleSize, downsampleSize, 0, RenderTextureFormat.ARGB32);
            RenderTexture blurB = RenderTexture.GetTemporary(downsampleSize, downsampleSize, 0, RenderTextureFormat.ARGB32);

            // init blurB
            Graphics.Blit(replaceRenderTexture, blurB, glowMaterial, 0);

            //glowMaterial.SetTexture("_Glow", blurA);
            //glowMaterial.SetTexture("_Glow", blurB);

            for (int i = 0; i < blurIterations; ++i)
            {
                // 偶数
                if (i % 2 == 0)
                {
                    blurA.DiscardContents();
                    // pass 0 - blur the main texture
                    Graphics.Blit(blurB, blurA, glowMaterial, 0);

                }
                // 奇数
                else
                {
                    blurB.DiscardContents();
                    // pass 0 - blur the main texture
                    Graphics.Blit(blurA, blurB, glowMaterial, 0);
                }

            }

            Graphics.Blit(source, destination, glowMaterial, 1);

            RenderTexture.ReleaseTemporary(blurA);
            RenderTexture.ReleaseTemporary(blurB);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
        
    }
}
