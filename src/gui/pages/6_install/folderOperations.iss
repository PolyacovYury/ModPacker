// © Kotyarko_O, 2020 \\

[CustomMessages]
en.instStatusLabelTextProfileClearing=Clearing game client profile...
ru.instStatusLabelTextProfileClearing=Очистка папки профиля игрового клиента...

[Code]
<event('CurStepChanged')>
Procedure ClientFolderOperations(InstallStep: TSetupStep);
var
 ResultCode: Integer;
 WoTAppData, WoTAppDataBackup: String;
begin
 if InstallStep = ssInstall then
 try
  if CheckBoxGetChecked(CBCleanProfile) then begin
   WoTAppData := ExpandConstant('{userappdata}\Wargaming.net\WorldOfTanks\');
   WoTAppDataBackup := ExpandConstant('{userappdata}\Wargaming.net\WorldOfTanks_backup');

   InstComponentLabel.Caption := CustomMessage('instStatusLabelTextProfileClearing');
   WizardForm.FilenameLabel.Caption := WoTAppData;

   if DirExists(WoTAppDataBackup) then
    DelTree(WoTAppDataBackup, True, True, True);
   ForceDirectories(WoTAppDataBackup);
   Exec(ExpandConstant('{cmd}'), '/C XCOPY "' + WoTAppData + '*.*" "' + WoTAppDataBackup + '\" /S /F /Y', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

   DelTree(WoTAppData + 'account_caches', True, True, True);
   DelTree(WoTAppData + 'battle_results', True, True, True);
   DelTree(WoTAppData + 'clan_cache', True, True, True);
   DelTree(WoTAppData + 'custom_data', True, True, True);
   DelTree(WoTAppData + 'dossier_cache', True, True, True);
   DelTree(WoTAppData + 'messenger_cache', True, True, True);
   DelTree(WoTAppData + 'pmod', True, True, True);
   DelTree(WoTAppData + 'profile', True, True, True);
   DelTree(WoTAppData + 'storage_cache', True, True, True);
   DelTree(WoTAppData + 'tutorial_cache', True, True, True);
   DelTree(WoTAppData + 'veh_cmp_cache', True, True, True);
   DelTree(WoTAppData + 'web_cache', True, True, True);
   DelTree(WoTAppData + 'wgfm', True, True, True);
  end;
  SaveStringToFile(ExpandConstant('{app}\res_mods\{#GameVersion}\readme.txt'), 'This folder is used for World of Tanks modifiers (mods).', False);
  SaveStringToFile(ExpandConstant('{app}\mods\{#GameVersion}\readme.txt'), 'This folder is used for packaged World of Tanks modifiers (*.wotmods).', False);
 except
  MsgBox('{#__FILE__}: {#__LINE__}' + #13#10 + GetExceptionMessage(), mbCriticalError, MB_OK);
 end;
end;
