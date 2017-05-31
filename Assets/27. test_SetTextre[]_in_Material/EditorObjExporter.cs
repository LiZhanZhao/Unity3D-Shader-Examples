
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System;

struct ObjMaterial
{
    public string name;
    public string textureName;
}

public class EditorObjExporter : ScriptableObject
{
    private static int vertexOffset = 0;
    private static int normalOffset = 0;
    private static int uvOffset = 0;
    
    
    //User should probably be able to change this. It is currently left as an excercise for
    //the reader.
    private static string targetFolder = "ExportedObj";

    private static float ScaleFactor = 1;
    

    private static string MeshToString(MeshFilter mf, Dictionary<string, ObjMaterial> materialList) 
    {
        Mesh m = mf.sharedMesh;
        if (m == null) { return ""; }
        Material[] mats = mf.GetComponent<Renderer>().sharedMaterials;
        
        StringBuilder sb = new StringBuilder();
        
        sb.Append("g ").Append(mf.name).Append("\n");

        mf.transform.position.Scale(new Vector3(ScaleFactor, ScaleFactor, ScaleFactor));

        foreach(Vector3 lv in m.vertices) 
        {
            Vector3 wv = mf.transform.TransformPoint(lv);   
            //This is sort of ugly - inverting x-component since we're in
            //a different coordinate system than "everyone" is "used to".
            //sb.Append(string.Format("v {0} {1} {2}\n", -wv.x * ScaleFactor, wv.y * ScaleFactor, wv.z * ScaleFactor));
            sb.Append(string.Format("v {0} {1} {2}\n", -wv.x * ScaleFactor, wv.y * ScaleFactor, wv.z * ScaleFactor));
        }
        sb.Append("\n");

        mf.transform.position.Scale(new Vector3(1 / ScaleFactor, 1 / ScaleFactor,1/ScaleFactor));
        
        foreach(Vector3 lv in m.normals) 
        {
            Vector3 wv = mf.transform.TransformDirection(lv);

            sb.Append(string.Format("vn {0} {1} {2}\n", -wv.x, wv.y, wv.z));
        }
        sb.Append("\n");
        
        foreach(Vector3 v in m.uv) 
        {
            sb.Append(string.Format("vt {0} {1}\n", v.x, v.y));
        }
        
        for (int material=0; material < m.subMeshCount; material ++) {
            sb.Append("\n");
            sb.Append("usemtl ").Append(mats[material].name).Append("\n");
            sb.Append("usemap ").Append(mats[material].name).Append("\n");
                
            //See if this material is already in the materiallist.
            try
            {
                ObjMaterial objMaterial = new ObjMaterial();
              
                objMaterial.name = mats[material].name;

                if (mats[material].mainTexture)
                    objMaterial.textureName = AssetDatabase.GetAssetPath(mats[material].mainTexture);
                else
                    objMaterial.textureName = null;
              
                materialList.Add(objMaterial.name, objMaterial);
            }
            catch (ArgumentException)
            {
                //Already in the dictionary
            }

                
            int[] triangles = m.GetTriangles(material);
            for (int i=0;i<triangles.Length;i+=3) 
            {
                //Because we inverted the x-component, we also needed to alter the triangle winding.
                sb.Append(string.Format("f {1}/{1}/{1} {0}/{0}/{0} {2}/{2}/{2}\n", 
                    triangles[i]+1 + vertexOffset, triangles[i+1]+1 + normalOffset, triangles[i+2]+1 + uvOffset));
            }
        }
        
        vertexOffset += m.vertices.Length;
        normalOffset += m.normals.Length;
        uvOffset += m.uv.Length;
        
        return sb.ToString();
    }
    
    private static void Clear()
    {
        vertexOffset = 0;
        normalOffset = 0;
        uvOffset = 0;
    }
    
    private static Dictionary<string, ObjMaterial> PrepareFileWrite()
    {
        Clear();
        
        return new Dictionary<string, ObjMaterial>();
    }
    
    private static void MaterialsToFile(Dictionary<string, ObjMaterial> materialList, string folder, string filename)
    {
        //using 定义一个范围，在范围结束时处理对象
        using (StreamWriter sw = new StreamWriter(folder + "/" + filename + ".mtl")) 
        {
            foreach( KeyValuePair<string, ObjMaterial> kvp in materialList )
            {
                sw.Write("\n");
                sw.Write("newmtl {0}\n", kvp.Key);
                sw.Write("Ka  0.6 0.6 0.6\n");
                sw.Write("Kd  0.6 0.6 0.6\n");
                sw.Write("Ks  0 0 0\n");
                sw.Write("Ke  0 0 0\n");
                sw.Write("d  1.0\n");
                sw.Write("Ns 1.0\n");
                sw.Write("Ni 1.5\n");
                sw.Write("Tr 1.5\n");
                sw.Write("Tf 1 1 1\n");
                sw.Write("illum 2\n");
                
                // 调整纹理的路径
                if (kvp.Value.textureName != null)
                {
                    string destinationFile = kvp.Value.textureName;

                    int stripIndex = destinationFile.LastIndexOf('/');
         
                    if (stripIndex >= 0)
                        destinationFile = destinationFile.Substring(stripIndex + 1).Trim();
                    
                    
                    string relativeFile = destinationFile;
                    
                    destinationFile = folder + "/" + destinationFile;
                
                    Debug.Log("Copying texture from " + kvp.Value.textureName + " to " + destinationFile);
                
                    try
                    {
                        //Copy the source file
                        File.Copy(kvp.Value.textureName, destinationFile);
                    }
                    catch
                    {
                        Debug.LogWarning("Can't not Copy Texture" + kvp.Value.textureName);
                    }


                    sw.Write("map_Kd {0}\n", relativeFile);
                }
                    
                sw.Write("\n");
            }
        }
    }
    
    // 把多个MeshFilter写到一个Obj文件，Mtl文件中
    private static void MeshesToFile(MeshFilter[] mf, string folder, string filename) 
    {
        Dictionary<string, ObjMaterial> materialList = PrepareFileWrite();
    
        using (StreamWriter sw = new StreamWriter(folder +"/" + filename + ".obj")) 
        {
            sw.Write("mtllib ./" + filename + ".mtl\n");
        
            for (int i = 0; i < mf.Length; i++)
            {
                sw.Write(MeshToString(mf[i], materialList));
            }
        }
        
        MaterialsToFile(materialList, folder, filename);
    }


    [MenuItem ("Q5/导出/选择对象导出到Obj文件")]
    static void ExportWholeSelectionToSingle()
    {
        SelectFolderFromUser();
        if (targetFolder == null)
        {
            return;
        }
            
        Transform[] selection = Selection.GetTransforms(SelectionMode.Editable | SelectionMode.ExcludePrefab);
        
        if (selection.Length == 0)
        {
            EditorUtility.DisplayDialog("No source object selected!", "Please select one or more target objects", "");
            return;
        }
        
        int exportedObjects = 0;

        List<MeshFilter> mfList = new List<MeshFilter>();
        // 就是吧选择中的所有的物体下的所有的MeshFilter保存到mfList中
        for (int i = 0; i < selection.Length; i++)
        {
            MeshFilter[] meshfilter = selection[i].GetComponentsInChildren<MeshFilter>();
         
             for (int m = 0; m < meshfilter.Length; m++)
             {
                exportedObjects++;
                mfList.Add(meshfilter[m]);
             }
        }
        
        if (exportedObjects > 0)
        {
            MeshFilter[] mf = mfList.ToArray();
         
            string filename = EditorApplication.currentScene + "_" + exportedObjects;
        
            int stripIndex = filename.LastIndexOf('/');
         
            if (stripIndex >= 0)
                filename = filename.Substring(stripIndex + 1).Trim();
        
            MeshesToFile(mf, targetFolder, filename);
        
        
            EditorUtility.DisplayDialog("Objects exported", "Exported " + exportedObjects + " objects to " + filename, "");
        }
        else
            EditorUtility.DisplayDialog("Objects not exported", "Make sure at least some of your selected objects have mesh filters!", "");
    }
    
    static void SelectFolderFromUser()
    {
        string targetPath = EditorUtility.OpenFolderPanel("Select Folder", "", "");
        targetFolder = targetPath;
    }

}
