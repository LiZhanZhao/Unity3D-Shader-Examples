using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class GaussianBlur : MonoBehaviour
{

    public Shader shader;
    private Material material;

    public float blurSize = 0.5f;
    public int blurIterations = 2;

    void Start()
    {
        //new mat
        if (!material && shader != null)
        {
            material = new Material(shader);
        }

    }

    void OnDisable()
    {
        if (material)
        {
            DestroyImmediate(material);
        }

    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
           
            int rtWidth = source.width / 2;
            int rtHeight = source.height / 2;

            // clone
            RenderTexture tempSrc = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            Graphics.Blit(source, tempSrc);
            for (int i = 0; i < blurIterations; i++)
            {
                // 方案1
                /*
                for (int j = 0; j < 2; j++) 
                {
                    material.SetFloat("_BlurSize", blurSize + j);

                    RenderTexture tempDes = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                    Graphics.Blit(tempSrc, tempDes, material, 0);
                    RenderTexture.ReleaseTemporary(tempSrc);
                    tempSrc = tempDes;


                    tempDes = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                    Graphics.Blit(tempSrc, tempDes, material, 1);
                    RenderTexture.ReleaseTemporary(tempSrc);
                    tempSrc = tempDes;
                }

                rtWidth /= 2;
                rtHeight /= 2;
                 */

                // 方案2
                ///*
                material.SetFloat("_BlurSize", blurSize);
                RenderTexture tempDes = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                Graphics.Blit(tempSrc, tempDes, material, 0);
                RenderTexture.ReleaseTemporary(tempSrc);
                tempSrc = tempDes;


                tempDes = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                Graphics.Blit(tempSrc, tempDes, material, 1);
                RenderTexture.ReleaseTemporary(tempSrc);
                tempSrc = tempDes;

                rtWidth /= 2;
                rtHeight /= 2;
                // */ 
            }
            Graphics.Blit(tempSrc, destination);
            RenderTexture.ReleaseTemporary(tempSrc);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
