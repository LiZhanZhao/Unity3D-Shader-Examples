using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestTextureArray : MonoBehaviour {

    public Texture2D[] texArr;
    public Material mat;
	// Use this for initialization
	void Start () {
        //mat.mainTexture = texArr[0];
        //mat.SetTexture("_TestTextArray_0", texArr[0]);
        //mat.SetTexture("_TestTextArray_1", texArr[1]);

        // 相当于 给Shader的_TestTextArray[0] 赋值
        //mat.SetTexture("_TestTextArray", texArr[0]);
        //mat.SetTexture("_TestTextArray0", texArr[0]);


        //MaterialPropertyBlock arrayPropertyBlock = new MaterialPropertyBlock();
        //arrayPropertyBlock.SetTexture
        //Shader.SetGlobalTexture("_TestTextArray0", texArr[0]);
        //texArr[0].GetNativeTexturePtr

        
    }

    // Update is called once per frame
    void Update () {
    }
}
