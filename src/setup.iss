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
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableDirPage=no
DirExistsWarning=no

//====={ Папка создания и название }=====\\
OutputDir=build
OutputBaseFilename="{#InstallerName}"
UninstallFilesDir="{app}\{#UninstallDirName}"
DefaultDirName={pf}\World_of_Tanks
AppendDefaultDirName=no

//====={ Сжатие }=====\\
InternalCompressLevel=ultra64
Compression=lzma2/ultra64
SolidCompression=true

//====={ Разное }=====\\
PrivilegesRequired=lowest
CreateUninstallRegKey=yes
