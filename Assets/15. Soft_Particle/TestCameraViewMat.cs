using UnityEngine;
using System.Collections;

public class TestCameraViewMat : MonoBehaviour {
    public GameObject target;
	// Use this for initialization
	void Start () {
        Camera cam = GetComponent<Camera>();
        Matrix4x4 worldView = cam.worldToCameraMatrix;
        Vector3 viewPos = worldView * target.transform.localPosition;
        //target.GetComponent<MeshRenderer>().material.SetMatrix("_MVP", worldView * cam.projectionMatrix);
        Debug.Log(viewPos);
        Debug.Log(worldView);

        Debug.Log(cam.projectionMatrix);

        Debug.Log("--------------------OpenGL------------------------");
        // OpenGL
        Debug.Log(-(cam.far + cam.near) / (cam.far - cam.near));
        Debug.Log(-2 * cam.far * cam.near / (cam.far - cam.near));

        Debug.Log("--------------------D3D-------------------------");
        // D3D
        Debug.Log((cam.far) / (cam.far - cam.near));
        Debug.Log(cam.far * cam.near / (cam.near - cam.far));
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
