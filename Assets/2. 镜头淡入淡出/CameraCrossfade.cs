using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class CameraCrossfade : MonoBehaviour {
    public Shader shader = null;
    public Color targetColor;
    private Material _material;
    protected Material material
    {
        get
        {
            if (_material == null)
            {
                if (shader == null)
                {
                    shader = Shader.Find("Camera/Crossfade");
                }
                _material = new Material(shader);
                _material.hideFlags = HideFlags.DontSave;
            }
            return _material;
        }
    }

    protected void OnEnable()
    {
        Camera camera = GetComponent<Camera>();
        Debug.Assert(camera != null, "没有Camera组件");
        // 初始化
        material.SetColor("_Color", targetColor);
    }

    
   
    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetColor("_Color", targetColor);
        if (material != null)
        {
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }

    }
}
