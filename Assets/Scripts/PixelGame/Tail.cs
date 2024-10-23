using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tail : MonoBehaviour
{
    private LineRenderer lineRenderer;
    private Queue<Vector3> positions = new Queue<Vector3>();
    private Vector3 lastPos = Vector3.zero;
    [Header("尾气长度")]
    public int lineLength = 25;
    [Header("尾气持续时间")]
    public float tailFadeTime = 0.02f;
    private float curTime = 0f;
    private static readonly float TailLength = 0.05f;
    // Start is called before the first frame update
    void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.startWidth = TailLength;
        lineRenderer.endWidth = TailLength;
    }

    // Update is called once per frame
    void Update()
    {
        curTime += Time.deltaTime;
        if (curTime >= tailFadeTime)
        {
            curTime = 0;
            if (positions.Count > 0)
            {
                positions.Dequeue();
                lineRenderer.positionCount = positions.Count;
                lineRenderer.SetPositions(positions.ToArray());
            }
        }
        DrawLines();
    }
    
    private void DrawLines()
    {
        if (lastPos != Vector3.zero)
        {
            if (Mathf.Abs(transform.position.x - lastPos.x) >= TailLength)
            {
                Vector3 temp = (transform.position.x - lastPos.x) > 0 ? new Vector3(TailLength, 0, 0) : new Vector3(-TailLength, 0, 0);
                Vector3 newPos = lastPos + temp;
                if (positions.Count >= lineLength)
                    positions.Dequeue();
                positions.Enqueue(newPos);
                lineRenderer.positionCount = positions.Count;
                lineRenderer.SetPositions(positions.ToArray());
                lastPos = newPos;
            }
            if (Mathf.Abs(transform.position.y - lastPos.y) >= TailLength)
            {
                Vector3 temp = (transform.position.y - lastPos.y) > 0 ? new Vector3(0, TailLength, 0) : new Vector3(0, -TailLength, 0);
                Vector3 newPos = lastPos + temp;
                if (positions.Count >= lineLength)
                    positions.Dequeue();
                positions.Enqueue(newPos);
                lineRenderer.positionCount = positions.Count;
                lineRenderer.SetPositions(positions.ToArray());
                lastPos = newPos;
            } 
        }
        else
        {
            lastPos = transform.position;
            positions.Enqueue(lastPos);
            lineRenderer.positionCount = positions.Count;
            lineRenderer.SetPositions(positions.ToArray());
        }
    }
}
