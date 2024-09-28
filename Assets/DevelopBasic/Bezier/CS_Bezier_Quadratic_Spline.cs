using System;
using UnityEngine;

public class CS_Bezier_Quadratic_Spline : MonoBehaviour {
	public float RatioSphereRadius = .2f;
	public float Ratio = 0;
	public Vector3[] points;
	public int CurveCount{
		get{return points.Length - 2;}
	}
	public void Reset(){
		points = new Vector3[] {
				new Vector3(0f,0f,0f),
				new Vector3(1f,0f,0f),
				new Vector3(2f,0f,0f)
		};
	}
	public int ControlPointCount{
		get{return points.Length;}
	}
	public Vector3 GetControlPoint(int index){
		return points[index];
	}

	public Vector3 GetVirtualPoint(Vector3 p0, Vector3 p1){
		return (p0+p1)/2.0f;
	}
	public void SetPointCount(int count){
		Array.Resize(ref points, count);
	}
	public void SetControlPoint(int index, Vector3 point){
		points[index] = point;
	}
	public void AddPoint(){
		Vector3 point = points[points.Length - 1];
		Array.Resize(ref points, points.Length + 1);
		point.x += 1f;
		points[points.Length - 1] = point;
	}
	public void AddPoint(int i){
		if(i==points.Length-1){AddPoint(); return;}
		Vector3[] temp = points;
		Array.Resize(ref points, points.Length + 1);
		points[i+1] = (temp[i] + temp[i+1])/2;
		for(int index=i+1;index<temp.Length;index++){
			points[index+1] = temp[index];
		}
	}
	public void AddPoint(Vector3 pos){
		Vector3 point = pos;
		Array.Resize(ref points, points.Length + 1);
		points[points.Length - 1] = point;
	}
	public void DeletePoint(){
		Array.Resize(ref points, points.Length - 1);
	}
	public void DeletePoint(int i){
		if(i>=points.Length) return;
		if(i==points.Length-1){DeletePoint(); return;}
		Vector3[] temp = points;
		for(int index=i;index<points.Length-1;index++){
			points[index] = temp[index+1];
		}
		DeletePoint();
	}
	public void ResizePoint(int length){
		Array.Resize(ref points, length);		
	}

	public Vector3 GetPoint(float t){
		int i;
		if(t>=1){
			t=1f;
			i=points.Length-3;
		}
		else{
			t = Mathf.Clamp01(t) * CurveCount;
			i = Mathf.FloorToInt(t);
			t -= i;
		}
		Vector3 p0 = (points[i]+points[i+1])/2f;
		Vector3 p1 = points[i+1];
		Vector3 p2 = (points[i+1]+points[i+2])/2;

		if(i==0){
			p0 = points[i];
		}
		if(i==points.Length-3){
			p2 = points[i+2];
		}
		return transform.TransformPoint(Bezier.GetPoint(p0,p1,p2,t));
	}
	public Vector3 GetVelocity(float t){
		int i;
		if(t>=1){
			t=1f;
			i=points.Length-3;
		}
		else{
			t = Mathf.Clamp01(t) * CurveCount;
			i = Mathf.FloorToInt(t);
			t -= i;
		}
		Vector3 p0 = (points[i]+points[i+1])/2f;
		Vector3 p1 = points[i+1];
		Vector3 p2 = (points[i+1]+points[i+2])/2;

		if(i==0){
			p0 = points[i];
		}
		if(i==points.Length-3){
			p2 = points[i+2];
		}
		return transform.TransformPoint(Bezier.GetFirstDerivative(p0, p1, p2, t))-
				transform.position;
	}
	public Vector3 GetDirection(float t){
		return GetVelocity(t).normalized;
	}
	public void SetPoint(int index, Vector3 pos){
		points[index] = pos;
	}
}
