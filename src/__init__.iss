#include "setup.iss"
#include "languages.iss"
#include "utils\__init__.iss"
[Code]
Procedure InitializeWizard();
begin
 if not CMDCheckParams('/NOCHECKFORMUTEX') then
  CreateMutex('{#AppMutex}');
end;
