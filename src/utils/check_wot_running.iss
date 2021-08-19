// © Kotyarko_O, 2020 \\

[CustomMessages]
en.runningApplicationFound=Running "World of Tanks" application found.%nIt is recommended that you allow Setup to automatically close these application.
ru.runningApplicationFound=ќбнаружено запущенное приложение "World of Tanks".%nѕеред продолжением требуетс€ закрыть все экземпл€ры приложени€.

[Code]
Function CheckForGameRun(): Boolean;
var
 ResultCode: Integer;
begin
 Result := False;
 if CMDCheckParams(CMD_NoCheckForRun) then begin
  Result := True;
  Exit;
 end;
 if (FindWindowByWindowName('World of Tanks (Online Game)') <> 0) or (FindWindowByWindowName('WoT Client') <> 0) then begin
  if MsgBox(CustomMessage('runningApplicationFound'), mbError, MB_YESNO or MB_DEFBUTTON1) = IDYES then begin
   Exec(ExpandConstant('{cmd}'), '/C TASKKILL /F /IM "WorldOfTanks.exe" /IM "WoTLauncher.exe"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
   case ResultCode of
    0: Result := True;
    128: Result := True;
   end;
  end;
 end else
  Result := True;
end;

<event('InitializeUninstall')>
Function _CheckForWot__InitializeUninstall(): Boolean;
begin
 Result := CheckForGameRun;
end;

<event('PrepareToInstall')>
function _CheckForWot__PrepareToInstall(var NeedsRestart: Boolean): String;
begin
 if not CheckForGameRun then
   Result := CustomMessage('AccessDenied');
end;
