[Setup]
AppId="{{#AppId}"
AppName={cm:AppName}
AppVersion={#AppVersion}
AppVerName={cm:AppName} {cm:ForWOT,{#GameVersion}}
AppPublisher={#AppPublisher}
VersionInfoVersion={#GameVersion}
DefaultGroupName={#SetupSetting("AppName")}

//====={ Ссылки }=====\\
AppPublisherURL={#AppURL}
AppSupportURL=""
AppUpdatesURL=""

//====={ Картинки }=====\\
SetupIconFile=data\img\icon.ico
UninstallDisplayIcon="{uninstallexe}"

//====={ Отключение страниц }=====\\
DisableWelcomePage=yes
DisableProgramGroupPage=yes
DisableReadyPage=no
DisableDirPage=no
DirExistsWarning=no
DisableFinishedPage=yes

//====={ Папка создания и название }=====\\
OutputDir=build
OutputBaseFilename="{#InstallerName}"
UninstallFilesDir="{app}\{#UninstallDirName}"
DefaultDirName="{autopf}\World_of_Tanks"
AppendDefaultDirName=no
VersionInfoProductName=""
VersionInfoDescription=""

//====={ Сжатие }=====\\
InternalCompressLevel=ultra64
Compression=lzma2/ultra64
SolidCompression=true

//====={ Разное }=====\\
PrivilegesRequired=lowest
CreateUninstallRegKey=yes

[Code]
Const
 CMD_NoSearchGameFiles = '/NOSEARCHGAMEFILES';
 CMD_NoCheckForMutex = '/NOCHECKFORMUTEX';
 CMD_NoCheckForRun = '/NOCHECKFORRUN';

// This block is necessary, otherwise the installer does not restore components upon reinstall
[Types]
Name: "custom"; Description: "i"; Flags: iscustom
