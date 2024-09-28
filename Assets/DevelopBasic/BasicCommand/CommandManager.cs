using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CommandManager<T> : MonoBehaviour where T:MonoBehaviour
{
    [SerializeField] protected T context;
    protected List<Command<T>> commandList;
    void Awake(){commandList = new List<Command<T>>();}
    void Update()
    {
        for(int i=commandList.Count - 1; i>=0; i--){
            var command = commandList[i];

            if(command.IsPending) command.SetStatus(CommandStatus.Working);
            if(command.IsDone) HandleCompletion(command, i);
            else {
                command.CommandUpdate(context);
                if(command.IsDone) HandleCompletion(command, i);
            }
        }
    }
    public void ActivateAutoPilot(){
        this.enabled = true;
    }
    public void DeactivateAutoPilot(){
        this.enabled = false;
        AbortCommands();
    }
    public void AbortCommands(){
        for(int i=commandList.Count-1; i>=0; i--){
            commandList[i].SetStatus(CommandStatus.Aborted);
            HandleCompletion(commandList[i], i);
        }
        commandList.Clear();
    }
    void HandleCompletion(Command<T> command, int commandIndex){
        commandList.RemoveAt(commandIndex);
        var nextCommand = command.GetNextCommand();
        if(nextCommand != null && command.IsSuccess){
            AddCommand(nextCommand);
        }
        command.SetStatus(CommandStatus.Detached);
    }
    public void AddCommand(Command<T> command){
        commandList.Add(command);
        command.SetStatus(CommandStatus.Pending);
    }
}
