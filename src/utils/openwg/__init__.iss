#define OPENWGUTILS_DIR_SRC    "src/utils/openwg"
#define OPENWGUTILS_DIR_UNINST UninstallDirName
#include "openwg.utils.iss"

[Code]

<event('CurUninstallStepChanged')>
Procedure UninstallDeinitOpenWG(CurUninstallStep: TUninstallStep);
begin
 if CurUninstallStep <> usUninstall then Exit;
 OPENWG_DllUnload();
 OPENWG_DllDelete();
end;
