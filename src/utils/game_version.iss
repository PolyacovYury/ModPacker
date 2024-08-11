[Code]
Var
 SelectedWOTPath, SelectedWOTVersion: String;
 IsWizardInitStarted: Boolean;

Function GameVersion(Param: String): String;
var
 WOTPath, Realm: String;
begin
 Result := SelectedWOTVersion;
 if IsWizardInitStarted and FileExists(WizardDirValue() + '\version.xml') then
  WOTPath := WizardDirValue()
 else
  WOTPath := ActiveLanguage();
 if SelectedWOTPath = WOTPath then
  Exit;
 SelectedWOTPath := WOTPath;
 if FileExists(WOTPath + '\version.xml') then begin
  XMLFileReadValue(WOTPath + '\version.xml', 'version.xml\meta\realm', Realm);
  Realm := AnsiLowercase(Realm);
 end else
  Realm := ActiveLanguage();
 if Realm = 'ru' then
  Result := '{#GameVersionRu}'
 else
  Result := '{#GameVersion}';
 SelectedWOTVersion := Result;
end;

<event('InitializeWizard')>
Procedure InitializeWizardStartsAboutHere();
begin
 IsWizardInitStarted := True;
end;
