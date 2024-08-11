#define UninstallReg "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + AppId + "_is1"
#define UninstallPathReg "Inno Setup: App Path"

#include "utils\__init__.iss"
#include "languages.iss"
#include "setup.iss"
[Code]
Procedure InitializeWizard();
begin
 if not CMDCheckParams(CMD_NoCheckForMutex) then
  CreateMutex('{#AppMutex}');
 BringToFrontAndRestore;
end;
#include "gui\__init__.iss"
