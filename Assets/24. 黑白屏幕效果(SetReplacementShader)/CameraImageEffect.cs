
using UnityEngine;
using System.Collections;

public class CameraImageEffect : MonoBehaviour
{

    private Camera shaderCamera;
    private RenderTexture replaceRenderTexture;

    public Material material;

    public void Start()
    {
        shaderCamera = new GameObject("Test", typeof(Camera)).GetComponent<Camera>();
        Camera origCamera = GetComponent<Camera>();
        replaceRenderTexture = new RenderTexture((int)origCamera.pixelWidth, (int)origCamera.pixelHeight, 16, RenderTextureFormat.ARGB32);
        replaceRenderTexture.wrapMode = TextureWrapMode.Clamp;
        replaceRenderTexture.useMipMap = false;
        replaceRenderTexture.filterMode = FilterMode.Bilinear;
        replaceRenderTexture.Create();

        shaderCamera.CopyFrom(origCamera);
        shaderCamera.clearFlags = CameraClearFlags.SolidColor;
        shaderCamera.renderingPath = RenderingPath.Forward;
        shaderCamera.targetTexture = replaceRenderTexture;
        shaderCamera.depth = 10;

        shaderCamera.SetReplacementShader(Shader.Find("FXMakerGrayscaleEffect"), "RenderType");
        
    }

    private void OnDisable()
    {
        RenderTexture.Destroy(replaceRenderTexture);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetTexture("_MainTex", source);
            material.SetTexture("_RegionTex", replaceRenderTexture);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}

