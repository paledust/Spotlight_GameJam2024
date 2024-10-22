using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SafeZoneProbe : MonoBehaviour
{
    [SerializeField] private float reportCycle = 10;
    [SerializeField] private float detectRadius = 50;
    private float reportTimer;
    private readonly Vector3[] CAST_DIR =new Vector3[26]{
        new Vector3(1,1,1),  new Vector3(1,1,0),   new Vector3(1,1,-1),
        new Vector3(1,0,1),  new Vector3(1,0,0),   new Vector3(1,0,-1),
        new Vector3(1,-1,1), new Vector3(1,-1,0),  new Vector3(1,-1,-1),
        new Vector3(0,1,1),  new Vector3(0,1,0),   new Vector3(0,1,-1),
        new Vector3(0,0,1),                        new Vector3(0,0,-1),
        new Vector3(0,-1,1), new Vector3(0,-1,0),  new Vector3(0,-1,-1),
        new Vector3(-1,1,1), new Vector3(-1,1,0),  new Vector3(-1,1,-1),
        new Vector3(-1,0,1), new Vector3(-1,0,0),  new Vector3(-1,0,-1),
        new Vector3(-1,-1,1),new Vector3(-1,-1,0), new Vector3(-1,-1,-1),
    };
    void Update(){
        reportTimer += Time.deltaTime;
        if(reportTimer >= reportCycle){
            reportTimer = 0;

            var colliders = Physics.OverlapSphere(transform.position, detectRadius, Service.TerrainLayer);
            if(colliders==null || colliders.Length == 0){
                EventHandler.Call_OnReportPos(transform.position, transform.rotation, null);
            }
            else{
                RaycastHit hit;
                var dir = new List<Vector3>();
                for(int i=0; i<CAST_DIR.Length; i++){
                    Physics.Raycast(transform.position, CAST_DIR[i], out hit, detectRadius, Service.TerrainLayer);
                    dir.Add(hit.point-transform.position);
                }
                EventHandler.Call_OnReportPos(transform.position, transform.rotation, dir.ToArray());
            }
        }
    }
    void OnDrawGizmosSelected(){
        Color drawCol = Color.green;
        drawCol.a = 0.2f;
        Gizmos.color = drawCol;
        Gizmos.DrawSphere(transform.position, detectRadius);
        Gizmos.DrawWireSphere(transform.position, detectRadius);
    }
}