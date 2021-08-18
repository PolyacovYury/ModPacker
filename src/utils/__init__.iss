#include "check_cmd_param.iss"
#include "check_wot_running.iss"
#include "elevate.iss"
#include "files_exist.iss"
#include "botva2\botva2.iss"
[Code]
<event('DeinitializeSetup')>
procedure _botva2__DeinitializeSetup();
begin
 gdipShutdown();
end;
#include "xml.iss"
#include "vcl\vcl.iss"
[Code]
<event('DeinitializeSetup')>
procedure _vcl__DeinitializeSetup();
begin
 UnLoadVCLStyles();
end;
