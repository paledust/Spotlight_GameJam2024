using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CS_Bezier_Quadratic_Spline))]
public class CS_BezierQuadraticSplineInspector : Editor {
	private bool ShowRatio = true;
	private bool Fold;
	private CS_Bezier_Quadratic_Spline spline;
	private Transform handleTransform;
	private Quaternion handleRotation;
	private const int STEPS_PER_CURVE = 10;
	private const float directionScale = .5f;
	private bool AllowPointDrag=false;
	private void OnSceneGUI(){
		spline = target as CS_Bezier_Quadratic_Spline;
		handleTransform = spline.transform;
		handleRotation = Tools.pivotRotation == PivotRotation.Local?
						handleTransform.rotation : Quaternion.identity;
		
		for(int i = 0; i<spline.ControlPointCount-2;i++){
			Vector3 p0 = ShowPoint(i);
			Vector3 p1 = ShowPoint(i+1);
			Vector3 p2 = ShowPoint(i+2);

			Handles.color = Color.red;
			Handles.DrawLine(p0,p1);
			Handles.DrawLine(p1,p2);

		}
		DrawQuadraticSpline(Color.white);
		if(ShowRatio)
			DrawRatioPointOnCurve(Color.cyan);
		ShowDirections();
	}
	public override void OnInspectorGUI(){
		spline = target as CS_Bezier_Quadratic_Spline;

		ShowRatio = GUILayout.Toggle(ShowRatio, "Show Ratio Point");
		spline.Ratio = EditorGUILayout.Slider(spline.Ratio,0,1);
		spline.RatioSphereRadius = EditorGUILayout.FloatField("Ratio Point Radius", spline.RatioSphereRadius);
		SceneView.RepaintAll();

		GUILayout.Label("Operation");
		AllowPointDrag = GUILayout.Toggle(AllowPointDrag,"Allow Point Drag");

		GUILayout.BeginHorizontal();
			if(GUILayout.Button("Add Point at End")){
				Undo.RecordObject(spline, "Add Point");
				spline.AddPoint();
				EditorUtility.SetDirty(spline);
			}
		GUILayout.EndHorizontal();
		if(GUILayout.Button("Delete Point at End")){
			if(spline.points.Length <= 3) return;
			Undo.RecordObject(spline, "Delete Point");
			spline.DeletePoint();
			EditorUtility.SetDirty(spline);
		}

		Fold = EditorGUILayout.Foldout(Fold, "Points");
		if(Fold){
			for(int i=0;i<spline.points.Length;i++){
				GUILayout.BeginHorizontal();
					EditorGUI.BeginChangeCheck();
	
					Vector3 point = EditorGUILayout.Vector3Field("point "+i,spline.points[i]);
					if(EditorGUI.EndChangeCheck()){
						Undo.RecordObject(spline, "Move Point");
						spline.points[i] = point;
						EditorUtility.SetDirty(spline);
					}
						if(GUILayout.Button("+")){
							Undo.RecordObject(spline, "Add Point");
							spline.AddPoint(i);
							EditorUtility.SetDirty(spline);	
						}
						if(GUILayout.Button("-")){
							if(spline.points.Length <= 3) return;
							Undo.RecordObject(spline, "Delete Point");
							spline.DeletePoint(i);
							EditorUtility.SetDirty(spline);
						}
				GUILayout.EndHorizontal();
			}
		}
	}

	private void ShowDirections(){
		Handles.color = Color.green;
		Vector3 point = spline.GetPoint(0f);
		int totalSegment = (STEPS_PER_CURVE*spline.CurveCount);
		Handles.DrawLine(point, point + spline.GetDirection(0f) * directionScale);
		for(int i = 1; i <= totalSegment; i++){
			point = spline.GetPoint(i/(float)totalSegment);
			Handles.DrawLine(point, point + spline.GetDirection(i/(float)totalSegment)*directionScale);
		}
	}
	private Vector3 ShowPoint(int index){
		Vector3 point = handleTransform.TransformPoint(spline.points[index]);
		if(!AllowPointDrag) return point;
		EditorGUI.BeginChangeCheck();
		point = Handles.DoPositionHandle(point, handleRotation);
		if(EditorGUI.EndChangeCheck()){
			Undo.RecordObject(spline, "Move Point Handle");
			spline.points[index] = handleTransform.InverseTransformPoint(point);
			EditorUtility.SetDirty(spline);
		}
		return point;
	}
	private void DrawQuadraticSpline(Color color){
		Vector3 lineStart = spline.GetPoint(0);
		int totalSegment = (STEPS_PER_CURVE*spline.CurveCount);
		for(int i = 1; i<=totalSegment;i++){
			Vector3 lineEnd = spline.GetPoint(i/(float)totalSegment);
			Handles.color = Color.white;
			Handles.DrawLine(lineStart,lineEnd);
			lineStart = lineEnd;
		}
	}
	private void DrawRatioPointOnCurve(Color color){
		Vector3 pos = spline.GetPoint(spline.Ratio);
		Handles.color = color;
		Handles.SphereHandleCap(0, pos, Quaternion.identity,spline.RatioSphereRadius,EventType.Repaint);
	}
}
