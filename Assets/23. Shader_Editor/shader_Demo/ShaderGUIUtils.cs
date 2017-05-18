using UnityEngine;
using UnityEditor;
using System.Collections;

public static class ShaderGUIUtils
{
    public static void SetShaderKeyword(bool value, string keyword, Material material)
    {
        if (value)
            material.EnableKeyword(keyword);
        else
            material.DisableKeyword(keyword);
    }

    public static void SetMultiCompileKeyword(string[] keywords, string keyword, Material material)
    {
        for (int i = 0; i < keywords.Length; i++)
        {
            if (keywords[i] == keyword)
                material.EnableKeyword(keywords[i]);
            else
                material.DisableKeyword(keywords[i]);
        }
    }

    public static void SetMultiCompileKeyword(string[] keywords, int index, Material material)
    {
        for (int i = 0; i < keywords.Length; i++)
        {
            if (i == index)
                material.EnableKeyword(keywords[i]);
            else
                material.DisableKeyword(keywords[i]);
        }
    }

    public static int GetMultiCompileKeywordIndex(string[] keywords, Material material)
    {
        for (int i = 0; i < keywords.Length; i++)
        {
            if (material.IsKeywordEnabled(keywords[i]))
                return i;
        }
        return 0;
    }

    public static bool ShaderKeywordToggle(string label, bool value, string keyword, Material material)
    {
        EditorGUI.BeginChangeCheck();
        value = EditorGUILayout.ToggleLeft(label, value);
        if (EditorGUI.EndChangeCheck())
        {
            if (value)
                material.EnableKeyword(keyword);
            else
                material.DisableKeyword(keyword);
        }
        return value;
    }

    public static int MultiKeywordSwitch(string label, string[] options, string[] keywords, int value, Material material)
    {
        EditorGUI.BeginChangeCheck();
        int[] values = new int[options.Length];
        for (int i=0; i<values.Length; i++)
            values[i] = i;
        value = EditorGUILayout.IntPopup(label, value, options, values);
        if (EditorGUI.EndChangeCheck())
        {
            SetMultiCompileKeyword(keywords, keywords[value], material);
        }
        return value;
    }

    public static int GetSelectionIndex(int value, int[] options)
    {
        for (int i = 0; i < options.Length; i++)
        {
            if (value == options[i])
                return i;
        }
        return 0;
    }
}