[Code]
Const
 CMD_NoSearchGameFiles = '/NOSEARCHGAMEFILES';
 CMD_NoCheckForMutex = '/NOCHECKFORMUTEX';
 CMD_NoCheckForRun = '/NOCHECKFORRUN';

// https://stackoverflow.com/a/35435534
function CMDCheckParams(const Value: string): Boolean;
var
  I: Integer;  
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), Value) = 0 then begin
      Result := True;
      Exit;
    end;
end;
