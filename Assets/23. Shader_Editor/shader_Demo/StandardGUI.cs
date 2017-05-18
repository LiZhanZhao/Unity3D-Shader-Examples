using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

public enum BackBlendMode { AlphaBlend, Additive, SoftAdditive, Multiply, Subtract, Max, Min };
public class StandardGUI : ShaderGUI {
    private enum VertexColorMode { Off, On, Masked };
    private string[] vertexColorOptions = new string[] { "不使用", "使用", "使用顶点色遮罩" };
    private string[] vertexColorKeywords = new string[] { "VERTEX_COLOR_OFF", "USE_VERTEX_COLOR", "USE_VERTEX_COLOR_MASKED" };
    private VertexColorMode _vertexColorMode;

    private bool _specGlossMap, _alphaTest, _isTerrain, _emissionOnLightmap, _rimLight, _deathDissolve, _breakable, _isEnv, is2Side, _reverseBack;
    private bool _metallic;
    private string[] allKeywords = new string[] { "USE_VERTEX_COLOR", "USE_VERTEX_COLOR_MASKED", "VERTEX_LIGHTMAP", "_NORMALMAP", "_SPECGLOSSMAP", "_METALLIC", "_ALPHATEST_ON", "NO_DIRECT_SPECULAR",
                                                  "ONE_LAYER", "TWO_LAYER", "THREE_LAYER", "_EMISSION", "RIM_LIGHT", "DEATH_DISSOLVE", "IS_BREAKABLE", "REVERSE_BACKSIDE", "EMISSION_ADJUSTMENT"} ;
    private int terrainCount;
    private bool _isCharacter;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material tm = materialEditor.target as Material;

        _specGlossMap = tm.IsKeywordEnabled("_SPECGLOSSMAP");
        _metallic = tm.IsKeywordEnabled("_METALLIC");
        _vertexColorMode = (VertexColorMode)ShaderGUIUtils.GetMultiCompileKeywordIndex(vertexColorKeywords, tm);
        _alphaTest = tm.IsKeywordEnabled("_ALPHATEST_ON");
        _isTerrain = tm.shader.name.Contains("Terrain");
        _isEnv = tm.shader.name.Contains("Environment");
        is2Side = tm.shader.name.Contains("2-Side");
        _isCharacter = tm.shader.name.Contains("Character");
        _rimLight = tm.IsKeywordEnabled("RIM_LIGHT");
        _deathDissolve = tm.IsKeywordEnabled("DEATH_DISSOLVE");
        _breakable = tm.IsKeywordEnabled("IS_BREAKABLE");
        _reverseBack = tm.IsKeywordEnabled("REVERSE_BACKSIDE");
        _emissionOnLightmap = (tm.globalIlluminationFlags == MaterialGlobalIlluminationFlags.BakedEmissive);
        //clean up shader keywords
        List<string> keywords = new List<string>();
        foreach (string s in tm.shaderKeywords)
        {
            if (ArrayUtility.Contains<string>(allKeywords, s))
            {
                keywords.Add(s);
            }
        }
        tm.shaderKeywords = keywords.ToArray();

        terrainCount = 0;

        if (is2Side)
            _reverseBack = ShaderGUIUtils.ShaderKeywordToggle("反转反向法线", _reverseBack, "REVERSE_BACKSIDE", tm);
        _vertexColorMode = (VertexColorMode)ShaderGUIUtils.MultiKeywordSwitch("顶点色模式", vertexColorOptions, vertexColorKeywords, (int)_vertexColorMode, tm);
        _alphaTest = ShaderGUIUtils.ShaderKeywordToggle("使用Alpha Test", _alphaTest, "_ALPHATEST_ON", tm);

        if (_alphaTest)
        {
            MaterialProperty _Cutoff = FindProperty("_Cutoff", properties);
            _Cutoff.floatValue = EditorGUILayout.Slider("Alpha Cutoff", _Cutoff.floatValue, 0, 1);
            //materialEditor.FloatProperty(FindProperty("_Cutoff", properties), "Cutoff");
        }
        EditorGUILayout.Space();

        MaterialProperty _Color = FindProperty("_Color", properties);
        materialEditor.ColorProperty(_Color, "整体颜色");
        MaterialProperty _MainTex = FindProperty("_MainTex", properties);
        materialEditor.TexturePropertySingleLine(new GUIContent("主贴图", "RGB - albedo, A - 透明度"), _MainTex);
        MaterialProperty _BumpMap = FindProperty("_BumpMap", properties);
        materialEditor.TexturePropertySingleLine(new GUIContent("法线贴图"), _BumpMap);

        if (_isTerrain)
        {
            materialEditor.TextureScaleOffsetProperty(_MainTex);
            terrainCount = 1;
        }

        if (!_isTerrain)
        {
            if (!_isCharacter){
                _metallic = ShaderGUIUtils.ShaderKeywordToggle("金属度模式", _metallic, "_METALLIC", tm);

                MaterialProperty _EmissionColor = FindProperty("_EmissionColor", properties);
                materialEditor.ColorProperty(_EmissionColor, "自发光颜色");

                MaterialProperty _EmissionMap = FindProperty("_EmissionMap", properties);
                materialEditor.TexturePropertySingleLine(new GUIContent("自发光贴图"), _EmissionMap);
            }


            // if (!_specGlossMap)
            // {
            //     if (_metallic)
            //     {
            //         MaterialProperty _Metallic = FindProperty("_Metallic", properties);
            //         _Metallic.floatValue = EditorGUILayout.Slider("金属度", _Metallic.floatValue, 0, 1);
            //         MaterialProperty _Roughness = FindProperty("_Roughness", properties);
            //         _Roughness.floatValue = EditorGUILayout.Slider("粗糙度", _Roughness.floatValue, 0, 1);
            //     }
            //     else
            //     {
            //         materialEditor.ColorProperty(FindProperty("_SpecColor", properties), "高光色");
            //         MaterialProperty _Glossiness = FindProperty("_Glossiness", properties);
            //         _Glossiness.floatValue = EditorGUILayout.Slider("光滑度", _Glossiness.floatValue, 0, 1);
            //     }
            // }
            MaterialProperty _SpecGlossMap = FindProperty("_SpecGlossMap", properties);
            if (_metallic)
                materialEditor.TexturePropertySingleLine(new GUIContent("高光贴图(MRAV)", "R-金属度，G-粗糙度，B-AO，A-顶点色遮罩"), _SpecGlossMap);
            else{
                materialEditor.TexturePropertySingleLine(new GUIContent("R-光泽度 G-透贴 B-自发光遮罩", "R - 光泽度，G - 透贴， B - 自发光遮罩"), _SpecGlossMap);
                // materialEditor.TexturePropertySingleLine(new GUIContent("高光贴图(SSSG)", "RGB - 高光色， A - 光滑度"), _SpecGlossMap);

            // if (_isCharacter || _isEnv){
                MaterialProperty _Glossiness = FindProperty("_Glossiness", properties);
                _Glossiness.floatValue = EditorGUILayout.Slider("光滑度", _Glossiness.floatValue, 0, 1);
                if (_Glossiness.floatValue < 0.01f)
                    tm.EnableKeyword("NO_DIRECT_SPECULAR");
                else
                    tm.DisableKeyword("NO_DIRECT_SPECULAR");
            // }
            }
            _emissionOnLightmap = EditorGUILayout.ToggleLeft("自发光影响Lightmap", _emissionOnLightmap);
            MaterialProperty _EmissionLightmapScale = FindProperty("_EmissionLightmapScale", properties);
            materialEditor.FloatProperty(_EmissionLightmapScale, "Lightmap中自发光强度");
        }



        if (_isCharacter)
        {
            tm.EnableKeyword("EMISSION_ADJUSTMENT");

            _rimLight = ShaderGUIUtils.ShaderKeywordToggle("边缘发光效果", _rimLight, "RIM_LIGHT", tm);
            if (_rimLight)
            {
                // MaterialProperty _RimColor = FindProperty("_RimColor", properties);
                // materialEditor.ColorProperty(_RimColor, "边缘发光颜色");

                // MaterialProperty _RimFactor = FindProperty("_RimFactor", properties);
                // materialEditor.VectorProperty(_RimFactor, "边缘光参数    X:   Y:  Z:范围  W:强度  ");
            }
            _deathDissolve = ShaderGUIUtils.ShaderKeywordToggle("死亡溶解效果", _deathDissolve, "DEATH_DISSOLVE", tm);
            if (_deathDissolve)
            {
                MaterialProperty _DissovleColor = FindProperty("_DissolveColor", properties);
                materialEditor.ColorProperty(_DissovleColor, "溶解边界颜色");
                MaterialProperty _DissolveTex = FindProperty("_DissolveTex", properties);
                materialEditor.TexturePropertySingleLine(new GUIContent("溶解灰度贴图"), _DissolveTex);
            }
        }
        else{
            tm.DisableKeyword("EMISSION_ADJUSTMENT");
        }

        if (_isEnv)
        {
            _breakable = ShaderGUIUtils.ShaderKeywordToggle("是否击碎物", _breakable, "IS_BREAKABLE", tm);
            if (_breakable)
            {
                MaterialProperty _BreakableDistance = FindProperty("_BreakableDistance", properties);
                materialEditor.FloatProperty(_BreakableDistance, "击碎物标记距离");
                MaterialProperty _BreakableColor = FindProperty("_BreakableColor", properties);
                materialEditor.ColorProperty(_BreakableColor, "击碎物边缘颜色");
            }
        }

        if (_isTerrain)
        {

            MaterialProperty _SpecMap = FindProperty("_SpecMap", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L1 高光", "RGB - Spec"), _SpecMap);

            // L2
            // EditorGUILayout.LabelField("地形用贴图区域");
            MaterialProperty _MainTex1 = FindProperty("_MainTex1", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L2 纹理", "RGB - diffuse"), _MainTex1);
            if (tm.GetTexture("_MainTex1") != null)
                terrainCount = 2;
            MaterialProperty _BumpMap1 = FindProperty("_BumpMap1", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L2 法线", "RGB - 法线"), _BumpMap1);

            MaterialProperty _SpecMap2 = FindProperty("_SpecMap1", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L2 高光", "RGB - Spec"), _SpecMap2);


            // L3
            MaterialProperty _MainTex2 = FindProperty("_MainTex2", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L3 纹理", "RGB - diffuse， A - 光滑度"), _MainTex2);
            if (tm.GetTexture("_MainTex2") != null)
                terrainCount = 3;
            MaterialProperty _BumpMap2 = FindProperty("_BumpMap2", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L3 法线", "RGB - 法线"), _BumpMap2);

            MaterialProperty _SpecMap3 = FindProperty("_SpecMap2", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("L3 高光", "RGB - Spec"), _SpecMap3);

            MaterialProperty _SplatTex = FindProperty("_SplatTex", properties);
            materialEditor.TexturePropertySingleLine(new GUIContent("地形混合贴图", "RGB - 对应三个层次"), _SplatTex);
        }

        if (tm.GetTexture("_BumpMap") != null)
            tm.EnableKeyword("_NORMALMAP");
        else
            tm.DisableKeyword("_NORMALMAP");

        if (tm.GetTexture("_SpecGlossMap") != null)
            tm.EnableKeyword("_SPECGLOSSMAP");
        else
        {
            tm.DisableKeyword("_SPECGLOSSMAP");
            MaterialProperty _Glossiness = FindProperty("_Glossiness", properties);
            if (_Glossiness.floatValue < 0.01f)
                tm.EnableKeyword("NO_DIRECT_SPECULAR");
            else
                tm.DisableKeyword("NO_DIRECT_SPECULAR");
        }

        if (!_isTerrain)
        {
            MaterialProperty _EmissionColor = FindProperty("_EmissionColor", properties);
            if (_EmissionColor.colorValue.grayscale > 0.01f)
            {
                tm.EnableKeyword("_EMISSION");
                tm.globalIlluminationFlags = (_emissionOnLightmap)?MaterialGlobalIlluminationFlags.BakedEmissive : MaterialGlobalIlluminationFlags.None;
            }
            else
            {
                tm.DisableKeyword("_EMISSION");
            }
        }



        if (_isTerrain)
        {
            //Debug.Log("Terrain Count " + terrainCount);
            tm.DisableKeyword("IS_TERRAIN");
            if (terrainCount == 1)
            {
                tm.EnableKeyword("ONE_LAYER"); tm.DisableKeyword("TWO_LAYER"); tm.DisableKeyword("THREE_LAYER");
            }
            if (terrainCount == 2)
            {
                tm.DisableKeyword("ONE_LAYER"); tm.EnableKeyword("TWO_LAYER"); tm.DisableKeyword("THREE_LAYER");
            }
            if (terrainCount == 3)
            {
                tm.DisableKeyword("ONE_LAYER"); tm.DisableKeyword("TWO_LAYER"); tm.EnableKeyword("THREE_LAYER");
            }
        }
        tm.DisableKeyword("VIRTUAL_LIGHT_ON");
    }
}
