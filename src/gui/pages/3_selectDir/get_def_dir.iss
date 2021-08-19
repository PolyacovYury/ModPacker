#define UninstallReg "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + AppId + "_is1"
#define UninstallPathReg "Inno Setup: App Path"

[CustomMessages]
en.UninstallOld=Previous mod pack version detected that needs to be removed.%nYour mod choices will be preserved.%n%nPress OK to run uninstaller.
ru.UninstallOld=Обнаружена предыдущая версия модпака. Она будет удалена.%nПредыдущий набор выбранных модов будет восстановлен.%n%nНажмите OK, чтобы запустить деинсталлятор.

[Code]
function StripAndCheckExists(path: string; defaulted: Boolean): string;
var
  I: Integer;
begin
  Result := '';
  path := Trim(path);
  if defaulted then
    Result := path;
  I := Pos('\worldoftanks.exe', AnsiLowercase(path));
  if Boolean(I) then
    Result := Copy(path, 1, I);
  StringChangeEx(Result, '"', '', True);
  if not DirExists(Result) then
    Result := '';
end;

function GetDefDirName(Param: string): string;
var
  DefDir: String;
  UninsResult: Integer;
  S: string;
begin
  S := '';
  Result := ExpandConstant('{param:DIR|}');
  if Result <> '' then begin
    DefDir := Result;
    Exit;
  end;
  if RegQueryStringValue(HKLM, '{#UninstallReg}', '{#UninstallPathReg}', S) or
     RegQueryStringValue(HKCU, '{#UninstallReg}', '{#UninstallPathReg}', S) then begin
    Result := StripAndCheckExists(S, True);
    if Result = '' then begin // WoT folder was deleted entirely
      RegDeleteKeyIncludingSubkeys(HKLM, '{#UninstallReg}');
      RegDeleteKeyIncludingSubkeys(HKCU, '{#UninstallReg}');
    end else begin
      if MsgBox(CustomMessage('UninstallOld'), mbError, MB_OK) = IDOK then
        if RegQueryStringValue(HKLM, '{#UninstallReg}', 'UninstallString', S) or
           RegQueryStringValue(HKCU, '{#UninstallReg}', 'UninstallString', S) then
          Exec('>', S, '', SW_SHOW, ewWaitUntilTerminated, UninsResult);
    end;
  end;
  if Result = '' then
    Result := ExpandConstant('{autopf}\') + 'World_of_Tanks';
  DefDir := Result;
end;
