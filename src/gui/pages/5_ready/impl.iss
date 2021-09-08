// © Kotyarko_O, 2020 \\

[CustomMessages]
en.ReadyMemoNoComponents=No components selected.
ru.ReadyMemoNoComponents=Компоненты не выбраны.
en.UninstallOld=Previous mod pack version detected that needs to be removed.%n%nPress OK to run uninstaller.
ru.UninstallOld=Обнаружена предыдущая версия модпака. Она будет удалена.%n%nНажмите OK, чтобы запустить деинсталлятор.

[Code]
Const
 TAB = '   ';
 LINE = #13#10;

Function CheckListBoxToReadyMemo(const CheckListBox: TNewCheckListBox): String;
var
 I, J: Integer;
begin
 Result := '';
 with CheckListBox do
  if Items.Count > 0 then begin
   for I := 0 to Items.Count - 1 do
    if Checked[I] then begin
     if ItemLevel[I] > 0 then
      for J := 0 to ItemLevel[I] - 1 do
       Result := Result + TAB
     else
      Result := Result + ' ';
     Result := Result + '- ' + ItemCaption[I] + LINE;
    end;
  end;
end;

Function GetReadyMemoFormat(): String;
begin
 if CheckBoxGetChecked(CBCleanProfile) then
  Result := Result + SetupMessage(msgReadyMemoTasks) + LINE + TAB + CheckBoxGetText(CBCleanProfile) + LINE;

 Result := Result + SetupMessage(msgReadyMemoDir) + LINE + TAB + WizardDirValue() + LINE + LINE;
 if WizardForm.NextButton.Enabled then
  Result := Result + SetupMessage(msgReadyMemoComponents) + LINE + CheckListBoxToReadyMemo(WizardForm.ComponentsList)
 else
  Result := Result + CustomMessage('ReadyMemoNoComponents') + LINE;
end;

<event('CurUninstallStepChanged')>
procedure PreparingUninstallStepChanged(UninstallStep: TUninstallStep);
var
 FileName: String;
begin
 if UninstallStep = usUninstall then begin
  FileName := ExpandConstant('{app}\{#UninstallDirName}.tmp');
  SaveStringToFile(FileName, 'temp', False);
 end else if UninstallStep = usDone then begin
  FileName := ExpandConstant('{app}\{#UninstallDirName}.tmp');
  DeleteFile(FileName);
 end;
end;

Procedure PreparingActions();
var
 DefDir: string;
 S, S1: string;
 Extracted: Boolean;
 ResultCode: Integer;
begin
 Exec('taskkill', '/IM WorldOfTanks.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
 S := '';
 if RegQueryStringValue(HKLM, '{#UninstallReg}', '{#UninstallPathReg}', S) or
    RegQueryStringValue(HKCU, '{#UninstallReg}', '{#UninstallPathReg}', S) then begin
  DefDir := StripAndCheckExists(S, True);
  if DefDir = '' then begin // WoT folder was deleted entirely
   RegDeleteKeyIncludingSubkeys(HKLM, '{#UninstallReg}');
   RegDeleteKeyIncludingSubkeys(HKCU, '{#UninstallReg}');
  end else if MsgBox(CustomMessage('UninstallOld'), mbError, MB_OK) = IDOK then
   if RegQueryStringValue(HKLM, '{#UninstallReg}', 'QuietUninstallString', S) or
      RegQueryStringValue(HKCU, '{#UninstallReg}', 'QuietUninstallString', S) then begin
    Extracted := RegQueryStringValue(HKLM, '{#UninstallReg}', 'InstallLocation', S1) or
      RegQueryStringValue(HKCU, '{#UninstallReg}', 'InstallLocation', S1);
    Exec('>', S, '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    if Extracted then begin
     repeat
      Sleep(500);
     until not (
       FileExists(AddBackslash(S1) + '{#UninstallDirName}.tmp')
       and DirExists(AddBackslash(S1) + '{#UninstallDirName}'));
    end;
   end;
 end;
end;
