using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectOffset : MonoBehaviour {
    public float offset;
    private Vector3 _oldPos;
	// Use this for initialization
	void Start () {
        _oldPos = transform.position;

    }
	
	// Update is called once per frame
	void Update () {
        Camera topCam = Camera.main;
        Debug.Assert(Camera.main, string.Format("不存在 Camera.main"));
        for(int i = 0; i < Camera.allCamerasCount; i++)
        {
            Camera cam = Camera.allCameras[i];
            if(cam != null &&　topCam.depth < cam.depth && cam.tag != "UICamera")
            {
                topCam = cam;
            }
        }

        Vector3 dir = topCam.transform.position - transform.position;
        dir = Vector3.Normalize(dir);
        transform.position = _oldPos + dir * offset;
        transform.LookAt(topCam.transform);
	}
}
