using System.ComponentModel;
using UnityEngine;
using UnityEngine.Timeline;

[DisplayName("Note Mark"),CustomStyle("NoteMarker")]
public class NoteMark : Marker
{
    [TextArea(0,30)]
    public string Note;
}