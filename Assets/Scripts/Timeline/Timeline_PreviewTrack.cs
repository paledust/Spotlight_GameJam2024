using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

[RequireComponent(typeof(PlayableDirector))]
public class Timeline_PreviewTrack : MonoBehaviour
{
    [SerializeField] private string previewKeyWord = "preview";
    private PlayableDirector director;
    public void SwitchPreviewTrack(bool isMute){
        director = GetComponent<PlayableDirector>();
        var timelineAsset = (TimelineAsset)director.playableAsset;

        string trackName = string.Empty;
        for( var i = 0; i < timelineAsset.rootTrackCount; i ++)
        {
            var track = timelineAsset.GetRootTrack(i);
            trackName = track.name.ToLower();
            if(trackName.Contains(previewKeyWord)){
                track.muted = isMute;
            }
        }
    }
    void Awake(){
        SwitchPreviewTrack(true);
    }
#if UNITY_EDITOR
    void OnDestroy(){
        SwitchPreviewTrack(false);
    }
#endif
}
