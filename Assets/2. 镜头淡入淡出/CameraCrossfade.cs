using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class CameraCrossfade : MonoBehaviour {
    public Shader shader = null;
    private RenderTexture srcTex = null;
    private RenderTexture dstTex = null;
    public Camera srcCamera;
    public Camera dstCamera;
    public float alpha;
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
        if(srcTex == null)
        {
            srcTex = new RenderTexture(Screen.width, Screen.height, 24);
            srcCamera.targetTexture = srcTex;
            dstTex = new RenderTexture(Screen.width, Screen.height, 24);
            dstCamera.targetTexture = dstTex;
        }
        
    }

    
   
    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        material.SetTexture("_SrcTex", srcCamera.targetTexture);
        material.SetTexture("_DstTex", dstCamera.targetTexture);
        material.SetFloat("_Alpha", alpha);
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
