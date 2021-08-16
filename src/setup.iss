[Setup]
AppId="{{#AppId}"
AppName={cm:AppName}
AppVersion={#AppVersion}
AppVerName={cm:AppName} {cm:ForWOT,{#GameVersion}}
AppPublisher={#AppPublisher}
VersionInfoVersion={#GameVersion}
DefaultGroupName={#SetupSetting("AppName")}

//====={ ������ }=====\\
AppPublisherURL={#AppURL}
AppSupportURL=""
AppUpdatesURL=""

//====={ �������� }=====\\
SetupIconFile=data\img\icon.ico
UninstallDisplayIcon="{uninstallexe}"

//====={ ���������� ������� }=====\\
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableDirPage=no
DirExistsWarning=no

//====={ ����� �������� � �������� }=====\\
OutputDir=build
OutputBaseFilename="{#InstallerName}"
UninstallFilesDir="{app}\{#UninstallDirName}"
DefaultDirName={pf}\World_of_Tanks
AppendDefaultDirName=no

//====={ ������ }=====\\
InternalCompressLevel=ultra64
Compression=lzma2/ultra64
SolidCompression=true

//====={ ������ }=====\\
PrivilegesRequired=lowest
CreateUninstallRegKey=yes
