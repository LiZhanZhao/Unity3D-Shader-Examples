// Alan Zucconi
// www.alanzucconi.com
using UnityEngine;
using System.Collections;

public class Heatmap : MonoBehaviour
{

    public Vector3[] positions;
    public float[] radiuses;
    public float[] intensities;

    public Material material;

    public int count = 50;

    void Start ()
    {
        positions = new Vector3[count];
        radiuses = new float[count];
        intensities= new float[count];

        for (int i = 0; i < positions.Length; i++)
        {
            positions[i] = new Vector2(Random.Range(-0.4f, +0.4f), Random.Range(-0.4f, +0.4f));
            radiuses[i] = Random.Range(0f, 0.25f);
            intensities[i] = Random.Range(-0.25f, 1f);
        }
    }

    void Update()
    {
        material.SetInt("_Points_Length", positions.Length);
        for (int i = 0; i < positions.Length; i++)
        {
            positions[i] += new Vector3(Random.Range(-0.1f,+0.1f), Random.Range(-0.1f, +0.1f)) * Time.deltaTime ;
            material.SetVector("_Points" + i.ToString(), positions[i]);

            Vector2 properties = new Vector2(radiuses[i], intensities[i]);
            material.SetVector("_Properties" + i.ToString(), properties);
        }
    }
}