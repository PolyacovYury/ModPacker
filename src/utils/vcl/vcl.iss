#define VCL "Windows10Dark"

[Files]
Source: "src\utils\vcl\VCLStylesInno.dll"; Flags: ignoreversion nocompression dontcopy
Source: "src\utils\vcl\{#VCL}.vsf"; Flags: ignoreversion nocompression dontcopy

[Code]
Procedure LoadVCLStyle(VClStyleFile: String); external 'LoadVCLStyleW@files:VCLStylesInno.dll stdcall';
Procedure UnLoadVCLStyles(); external 'UnLoadVCLStyles@files:VCLStylesInno.dll stdcall';

<event('InitializeWizard')>
procedure InitializeVCL();
begin
 ExtractTemporaryFile('{#VCL}.vsf');
 LoadVCLStyle(ExpandConstant('{tmp}\{#VCL}.vsf'));
end;

<event('DeinitializeSetup')>
procedure DeinitializeVCL();
begin
 UnLoadVCLStyles();
end;
