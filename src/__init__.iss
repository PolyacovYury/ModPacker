#include "setup.iss"
#include "languages.iss"
#include "utils\__init__.iss"
[Code]
Procedure InitializeWizard();
begin
 if not CMDCheckParams(CMD_NoCheckForMutex) then
  CreateMutex('{#AppMutex}');
 BringToFrontAndRestore;
end;
#include "gui\__init__.iss"
