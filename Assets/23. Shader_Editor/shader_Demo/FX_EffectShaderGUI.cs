using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using System.Collections;

// public enum BackBlendMode { AlphaBlend, Additive, SoftAdditive, Multiply, Subtract, Max, Min };
public class FX_EffectShaderGUI : ShaderGUI
{
    private string[] backBlendOptions = new string[] { "Alpha混合", "加法", "柔和加法", "乘法" , "减法", "最大值", "最小值"};
    private BackBlendMode backBlendMode;
    private string[] cullingOptions = new string[] { "不裁剪", "裁剪正面", "裁剪背面" };
    private string[] depthTestOptions = new string[] {"默认", "总是可见", "被遮挡时可见"};
    private int[] depthTestValues = new int[] { (int)CompareFunction.LessEqual, (int)CompareFunction.Always, (int)CompareFunction.GreaterEqual };
    private string[] queueOptions = new string[] {"自定义", "3000:半透明", "3500", "4000:覆盖层", "4500", "5000:最后渲染" };
    private int[] renderQueueValues = new int[] {3000, 3000, 3500, 4000, 4500, 5000 };
    // public enum AlphaBlendMode { Blend=0, Dissolve=1, SampleTexture=2};
    // public enum EdgeColorMode { Replace, Add, Multiply };
    // public enum UVDistortMode { None, Constant, SinWave };
    // public enum FXLightMode { None, Simple, Normal, Soft };
    // public enum RimColorMode { None, Simple };
    public enum DissolveMode { None, Model, Particle };
    private bool _initialized = false;
    // private bool _animatedTexture, _twoTexture, _maskTexture, _normalMap, _specularOn, _reflectionOn, _vertexWaveOn;
    private bool _normalMap, _animatedTexture, _twoTexture, _maskTexture, _vertexWaveOn, _turbulence, _rimLight, _rimTexture;
    // private string[] blendOptions = new string[] { "普通混合", "边缘溶解", "依渐变贴图溶解"};
    // private string[] blendKeywords = new string[] { "EDGE_OFF", "EDGE_DISSOLVE", "EDGE_TEXTURE"};
    // private AlphaBlendMode blendMode;
    // private string[] edgeColorOptions = new string[] { "替代原本颜色", "加法混合", "乘法混合" };
    // private string[] edgeColorKeywords = new string[] { "EDGE_TEX_REP", "EDGE_TEX_ADD", "EDGE_TEX_MUL" };
    // private EdgeColorMode edgeColorMode;
    // private string[] distortOptions = new string[] { "关闭", "线性扭曲" };
    // private string[] distortKeywords = new string[] { "DISTORT_OFF", "DISTORT_CONSTANT" };
    // private UVDistortMode uvDistortMode;
    // private string[] rimOptions = new string[] { "关闭", "边缘发光"};
    // private string[] rimKeywords = new string[] { "RIM_LIGHT_OFF", "RIM_LIGHT"};
    // private RimColorMode rimColorMode;
    // private string[] lightOptions = new string[] { "无光照", "整体光照", "普通光照", "柔和光照" };
    // private string[] lightKeywords = new string[] { "NO_LIGHT", "SIMPLE_LIGHT", "NORMAL_LIGHT", "SOFT_LIGHT" };
    // private FXLightMode lightMode;

    private string[] dissolveOptions = new string[] { "关闭", "模型溶解", "粒子溶解"};
    private string[] dissolveKeywords = new string[] { "DISSOLVE_OFF", "DISSOLVE_MODEL", "DISSOLVE_PARTICLE"};
    private DissolveMode dissolveMode;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //base.OnGUI(materialEditor, properties);
        Material mat = materialEditor.target as Material;
        if (!_initialized)
        {
            _animatedTexture = mat.IsKeywordEnabled("ANIMATED_TEXTURE");
            _twoTexture = mat.IsKeywordEnabled("TWO_LAYER");
            _maskTexture = mat.IsKeywordEnabled("MASK_TEXTURE");
            _normalMap = mat.IsKeywordEnabled("NORMALMAP");
            // _specularOn = mat.IsKeywordEnabled("SPECULAR_ON");
            // _reflectionOn = mat.IsKeywordEnabled("REFLECTION_ON");
            _vertexWaveOn = mat.IsKeywordEnabled("VERTEX_WAVE");
            _turbulence = mat.IsKeywordEnabled("TURBULENCE");
            _rimLight = mat.IsKeywordEnabled("RIM_LIGHT");
            _rimTexture = mat.IsKeywordEnabled("RIM_TEXTURE");
            // _dissolve = mat.IsKeywordEnabled("DISSOLVE");
            dissolveMode = (DissolveMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(dissolveKeywords, mat);
            // blendMode = (AlphaBlendMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(blendKeywords, mat);
            // edgeColorMode = (EdgeColorMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(edgeColorKeywords, mat);
            // uvDistortMode = (UVDistortMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(distortKeywords, mat);
            // rimColorMode = (RimColorMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(rimKeywords, mat);
            // lightMode = (FXLightMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(lightKeywords, mat);
        }
        bool isSolid = mat.shader.name.Contains("Solid");
        GUI.color = Color.yellow;
        EditorGUILayout.LabelField("渲染模式选项");
        GUI.color = Color.white;

        BackBlendModeGUI(materialEditor, properties);
        //culling control
        MaterialProperty _Culling = FindProperty("_Culling", properties);
        _Culling.floatValue = EditorGUILayout.Popup("裁剪模式", (int)_Culling.floatValue, cullingOptions);
        //ztest
        MaterialProperty _ZTest = FindProperty("_ZTest", properties);
        int zt = (int)_ZTest.floatValue;
        if (zt != (int)CompareFunction.LessEqual && zt != (int)CompareFunction.Always && zt != (int)CompareFunction.GreaterEqual)
            _ZTest.floatValue = (int)CompareFunction.LessEqual;
        _ZTest.floatValue = EditorGUILayout.IntPopup("深度测试模式", (int)_ZTest.floatValue, depthTestOptions, depthTestValues);
        //render queue
        MaterialProperty _Queue = FindProperty("_Queue", properties);
        _Queue.floatValue = EditorGUILayout.Popup("渲染次序", (int)_Queue.floatValue, queueOptions);
        if ((int)_Queue.floatValue > 0)
            mat.renderQueue = renderQueueValues[(int)_Queue.floatValue];
        else
            mat.renderQueue = EditorGUILayout.IntField("Render Queue", mat.renderQueue);

        EditorGUILayout.Space();
        GUI.color = Color.yellow;
        EditorGUILayout.LabelField("材质属性选项");
        GUI.color = Color.white;
        // lightMode = (FXLightMode)ShaderGUIUtils.MultiKeywordSwitch("受光模式", lightOptions, lightKeywords, (int)lightMode, mat);
        // if (lightMode != FXLightMode.None)
        // {
        //     _specularOn = ShaderGUIUtils.ShaderKeywordToggle("打开高光", _specularOn, "SPECULAR_ON", mat);
        //     if (_specularOn)
        //     {
        //         MaterialProperty _SpecularPower = FindProperty("_SpecularPower", properties);
        //         _SpecularPower.floatValue = EditorGUILayout.FloatField("Spec. Power", _SpecularPower.floatValue);
        //         MaterialProperty _SpecularColor = FindProperty("_SpecularColor", properties);
        //         _SpecularColor.colorValue = EditorGUILayout.ColorField("Spec. Color", _SpecularColor.colorValue);
        //     }
        // }
        // _reflectionOn = ShaderGUIUtils.ShaderKeywordToggle("打开反射", _reflectionOn, "REFLECTION_ON", mat);
        // if (_reflectionOn)
        // {
        //     MaterialProperty _Reflectivity = FindProperty("_Reflectivity", properties);
        //     _Reflectivity.colorValue = EditorGUILayout.ColorField("反射颜色", _Reflectivity.colorValue);
        // }
        _animatedTexture = ShaderGUIUtils.ShaderKeywordToggle("打开UV动画", _animatedTexture, "ANIMATED_TEXTURE", mat);
        EditorGUILayout.Space();

        // if (isSolid)
        // {
        //     MaterialProperty _Cutoff = FindProperty("_Cutoff", properties);
        //     _Cutoff.floatValue = EditorGUILayout.Slider("Alpha Cutoff", _Cutoff.floatValue, 0, 1.1f);
        // }
        //color property always exists
        MaterialProperty _Color = FindProperty("_Color", properties);
        _Color.colorValue = materialEditor.ColorProperty(_Color, "Tint Color");
        // MaterialProperty _AlphaBoost = FindProperty("_AlphaBoost", properties);
        // _AlphaBoost.floatValue = materialEditor.FloatProperty(_AlphaBoost, "Alpha增幅");
        MaterialProperty _MainTex = FindProperty("_MainTex", properties);
        materialEditor.TextureProperty(_MainTex, "主贴图", true);

        _normalMap = ShaderGUIUtils.ShaderKeywordToggle("使用法线贴图", _normalMap, "NORMALMAP", mat);
        if (_normalMap) {
            MaterialProperty _BumpMap = FindProperty("_BumpMap", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("主法线贴图"), _BumpMap);
        }

        if (_animatedTexture)
        {
            MaterialProperty _MainTexMove = FindProperty("_MainTexMove", properties);
            _MainTexMove.vectorValue = materialEditor.VectorProperty(_MainTexMove, "主贴图运动参数 (XY, 速度, ZW, 没有用)");
        }


        EditorGUILayout.Space();
        _twoTexture = ShaderGUIUtils.ShaderKeywordToggle("使用第二张贴图", _twoTexture, "TWO_LAYER", mat);
        if (_twoTexture)
        {
            MaterialProperty _SubTex = FindProperty("_SubTex", properties);
            materialEditor.TextureProperty(_SubTex, "第二张贴图", true);
            // if (_normalMap)
            // {
            //     MaterialProperty _MainNormalMap = FindProperty("_SubNormalMap", properties);
            //     materialEditor.TexturePropertySingleLine(new GUIContent("第二张法线贴图"), _MainNormalMap);
            // }
            if (_animatedTexture)
            {
                MaterialProperty _SubTexMove = FindProperty("_SubTexMove", properties);
                _SubTexMove.vectorValue = materialEditor.VectorProperty(_SubTexMove, "第二贴图运动参数 (XY, 速度, ZW, 没有用)");
            }
        }


        EditorGUILayout.Space();
        _maskTexture = ShaderGUIUtils.ShaderKeywordToggle("使用Alpha遮罩", _maskTexture, "MASK_TEXTURE", mat);
        if (_maskTexture)
        {
            MaterialProperty _MaskTex = FindProperty("_MaskTex", properties);
            materialEditor.TextureProperty(_MaskTex, "遮罩贴图", true);
        }

        // EditorGUILayout.Space();
        // rimColorMode = (RimColorMode)ShaderGUIUtils.MultiKeywordSwitch("边缘发光", rimOptions, rimKeywords, (int)rimColorMode, mat);
        // if (rimColorMode == RimColorMode.Simple)
        // {
        //     MaterialProperty _RimPower = FindProperty("_RimPower", properties);
        //     _RimPower.floatValue = EditorGUILayout.Slider("边缘发光指数", _RimPower.floatValue, 0, 100);
        //     MaterialProperty _RimColor = FindProperty("_RimColor", properties);
        //     materialEditor.ColorProperty(_RimColor, "边缘发光颜色");
        //     //MaterialProperty _CenterColor = FindProperty("_CenterColor", properties);
        //     //materialEditor.ColorProperty(_CenterColor, "中心部分颜色");
        // }

        // EditorGUILayout.Space();
        // blendMode = (AlphaBlendMode)ShaderGUIUtils.MultiKeywordSwitch("透明度混合模式", blendOptions, blendKeywords, (int)blendMode, mat);
        // MaterialProperty _Hardness = FindProperty("_Hardness", properties);
        // if (blendMode == AlphaBlendMode.Dissolve)
        // {
        //     MaterialProperty _DissolveOpacity = FindProperty("_DissolveOpacity", properties);
        //     _DissolveOpacity.floatValue = EditorGUILayout.Slider("整体透明度", _DissolveOpacity.floatValue, 0, 1);
        //     _Hardness.floatValue = EditorGUILayout.FloatField("边缘硬度", _Hardness.floatValue);
        // }

        // if (blendMode == AlphaBlendMode.SampleTexture)
        // {
        //     _Hardness.floatValue = EditorGUILayout.FloatField("边缘硬度", _Hardness.floatValue);
        //     MaterialProperty _EdgeTex = FindProperty("_EdgeTex", properties);
        //     materialEditor.TexturePropertySingleLine(new GUIContent("边缘色彩渐变贴图"), _EdgeTex);
        // }

        // if (blendMode != AlphaBlendMode.Blend)
        //     edgeColorMode = (EdgeColorMode)ShaderGUIUtils.MultiKeywordSwitch("边缘色彩模式", edgeColorOptions, edgeColorKeywords, (int)edgeColorMode, mat);

        // EditorGUILayout.Space();
        // uvDistortMode = (UVDistortMode)ShaderGUIUtils.MultiKeywordSwitch("UV坐标扭曲", distortOptions, distortKeywords, (int)uvDistortMode, mat);
        // if (uvDistortMode == UVDistortMode.Constant)
        // {
        //     MaterialProperty _DistortParamX = FindProperty("_DistortParamX", properties);
        //     _DistortParamX.vectorValue = materialEditor.VectorProperty(_DistortParamX, "坐标扭曲参数(U)：x-振幅，yzw-没用");
        //     MaterialProperty _DistortParamY = FindProperty("_DistortParamY", properties);
        //     _DistortParamY.vectorValue = materialEditor.VectorProperty(_DistortParamY, "坐标扭曲参数(V)：x-振幅，yzw-没用");
        //     MaterialProperty _DistortTex = FindProperty("_DistortTex", properties);
        //     materialEditor.TextureProperty(_DistortTex, "UV扭曲贴图（使用RG通道）", true);
        //     if (_animatedTexture)
        //     {
        //         MaterialProperty _DistortTexMove = FindProperty("_DistortTexMove", properties);
        //         _DistortTexMove.vectorValue = materialEditor.VectorProperty(_DistortTexMove, "UV扭曲贴图运动参数 (XY, 速度, ZW, 没有用)");
        //     }
        // }

        EditorGUILayout.Space();
        _vertexWaveOn = ShaderGUIUtils.ShaderKeywordToggle("开启顶点波浪效果", _vertexWaveOn, "VERTEX_WAVE", mat);
        if (_vertexWaveOn)
        {
            MaterialProperty _VertexWaveMask = FindProperty("_VertexWaveMask", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("顶点波浪效果遮罩"), _VertexWaveMask);
            MaterialProperty _VertexWaveTex = FindProperty("_VertexWaveTex", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("顶点波浪效果强度"), _VertexWaveTex);
            MaterialProperty _VertexWaveCoord = FindProperty("_VertexWaveCoord", properties);
            materialEditor.VectorProperty(_VertexWaveCoord, "XY-U运动频率速度， ZW-V运动频率速度");
            MaterialProperty _VertexWaveForce = FindProperty("_VertexWaveForce", properties);
            materialEditor.VectorProperty(_VertexWaveForce, "XYZ分别对应法线、切线、副法线的波动强度");
        }

        EditorGUILayout.Space();
        _turbulence = ShaderGUIUtils.ShaderKeywordToggle("开启纹理扰动效果", _turbulence, "TURBULENCE", mat);
        if (_turbulence)
        {
            MaterialProperty _Blend_Texture = FindProperty("_Blend_Texture", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("第一张混合纹理"), _Blend_Texture);
            MaterialProperty _Blend_Texture01 = FindProperty("_Blend_Texture01", properties);
            MaterialProperty _Color02 = FindProperty("_Color02", properties);
            materialEditor.ColorProperty(_Color02, "第一张纹理颜色");
            materialEditor.TexturePropertySingleLine(new GUIContent("第二张混合纹理"), _Blend_Texture01);
            MaterialProperty _Speed_Brightness = FindProperty("_Speed_Brightness", properties);
            MaterialProperty _Color03 = FindProperty("_Color03", properties);
            materialEditor.ColorProperty(_Color03, "第二张纹理颜色");
            materialEditor.VectorProperty(_Speed_Brightness, "XY:混合纹理流动速度, ZW:主纹理和混合效果强度");
        }

        // EditorGUILayout.Space();
        // _dissolve = ShaderGUIUtils.ShaderKeywordToggle("开启溶解效果", _dissolve, "DISSOLVE", mat);
        // if (_dissolve)
        // {
        //     _dissolveParticle = ShaderGUIUtils.ShaderKeywordToggle("使用粒子顶点色", _dissolveParticle, "DISSOLVE_PARTICLE", mat);
        //     MaterialProperty _Dissolve_Texture = FindProperty("_Dissolve_Texture", properties);
        //     materialEditor.TexturePropertySingleLine(new GUIContent("溶解纹理"), _Dissolve_Texture);
        //     MaterialProperty _Dissolve_ColorTex = FindProperty("_Dissolve_ColorTex", properties);
        //     materialEditor.TexturePropertySingleLine(new GUIContent("颜色映射纹理"), _Dissolve_ColorTex);
        //     MaterialProperty _DissolveParameters = FindProperty("_DissolveParameters", properties);
        //     materialEditor.VectorProperty(_DissolveParameters, "X:溶解进度, Y:边缘宽度, Z:边缘亮度, W:缩放");
        // }
        EditorGUILayout.Space();
        dissolveMode = (DissolveMode)ShaderGUIUtils.MultiKeywordSwitch("溶解效果", dissolveOptions, dissolveKeywords, (int)dissolveMode, mat);
        if (dissolveMode == DissolveMode.Model)
        {
            MaterialProperty _Dissolve_Texture = FindProperty("_Dissolve_Texture", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("溶解纹理"), _Dissolve_Texture);
            MaterialProperty _Dissolve_ColorTex = FindProperty("_Dissolve_ColorTex", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("颜色映射纹理"), _Dissolve_ColorTex);

            MaterialProperty _DissolveParameters = FindProperty("_DissolveParameters", properties);
            materialEditor.VectorProperty(_DissolveParameters, "X:溶解进度, Y:边缘宽度, Z:边缘亮度, W:缩放");
        }
        if (dissolveMode == DissolveMode.Particle)
        {
            MaterialProperty _DissolveParameters = FindProperty("_DissolveParameters", properties);
            materialEditor.VectorProperty(_DissolveParameters, "X:溶解度, Y:硬度, ZW:没用");
        }


        EditorGUILayout.Space();
        _rimLight = ShaderGUIUtils.ShaderKeywordToggle("开启边缘光效果", _rimLight, "RIM_LIGHT", mat);
        if (_rimLight)
        {

            MaterialProperty _RimColor = FindProperty("_RimColor", properties);
            _RimColor.colorValue = materialEditor.ColorProperty(_RimColor, "边缘光颜色");
            _rimTexture = ShaderGUIUtils.ShaderKeywordToggle("使用贴图", _rimTexture, "RIM_TEXTURE", mat);
            if (_rimTexture)
            {
                MaterialProperty _Rim_Texture = FindProperty("_Rim_Texture", properties);
                materialEditor.TexturePropertySingleLine(new GUIContent("边缘光纹理"), _Rim_Texture);
            }
            MaterialProperty _RimParameters = FindProperty("_RimParameters", properties);
            materialEditor.VectorProperty(_RimParameters, "X:宽度, Y:亮度, ZW:没用");
        }

        EditorUtility.SetDirty(mat);
    }

    private void BackBlendModeGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material mat = materialEditor.target as Material;
        MaterialProperty _Mode = FindProperty("_Mode", properties);
        _Mode.floatValue = (float)EditorGUILayout.Popup("背景混合模式", (int)_Mode.floatValue, backBlendOptions);
        backBlendMode = (BackBlendMode)(int)_Mode.floatValue;
        switch (backBlendMode)
        {
            case BackBlendMode.AlphaBlend:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.OneMinusSrcAlpha;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.Zero;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Add;
                mat.EnableKeyword("BLEND_ALPHA");
                mat.DisableKeyword("BLEND_ADD");
                mat.DisableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.Additive:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.One;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.OneMinusSrcAlpha;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Add;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.EnableKeyword("BLEND_ADD");
                mat.DisableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.SoftAdditive:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.OneMinusSrcColor;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.OneMinusSrcAlpha;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Add;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.EnableKeyword("BLEND_ADD");
                mat.DisableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.Multiply:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.Zero;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.SrcColor;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.Zero;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Add;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.DisableKeyword("BLEND_ADD");
                mat.EnableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.Subtract:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.One;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.Zero;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.ReverseSubtract;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.EnableKeyword("BLEND_ADD");
                mat.DisableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.Max:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.One;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.SrcAlpha;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.OneMinusSrcAlpha;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Max;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.EnableKeyword("BLEND_ADD");
                mat.DisableKeyword("BLEND_MULT");
                break;
            case BackBlendMode.Min:
                FindProperty("_SrcBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_DstBlend", properties).floatValue = (int)BlendMode.One;
                // FindProperty("_SrcAlphaBlend", properties).floatValue = (int)BlendMode.Zero;
                // FindProperty("_DstAlphaBlend", properties).floatValue = (int)BlendMode.One;
                FindProperty("_BlendOp", properties).floatValue = (int)BlendOp.Min;
                mat.DisableKeyword("BLEND_ALPHA");
                mat.DisableKeyword("BLEND_ADD");
                mat.EnableKeyword("BLEND_MULT");
                break;
        }
    }
}
