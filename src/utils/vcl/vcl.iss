#define VCL "Windows10Dark"

[Files]
Source: "src\utils\vcl\VCLStylesInno.dll"; Flags: dontcopy
Source: "src\utils\vcl\{#VCL}.vsf"; Flags: dontcopy

[Code]
Procedure LoadVCLStyle(VClStyleFile: String); external 'LoadVCLStyleW@files:VCLStylesInno.dll stdcall';
Procedure UnLoadVCLStyles(); external 'UnLoadVCLStyles@files:VCLStylesInno.dll stdcall';

<event('InitializeSetup')>
Function InitializeVCL(): Boolean;
begin
 ExtractTemporaryFile('{#VCL}.vsf');
 LoadVCLStyle(ExpandConstant('{tmp}\{#VCL}.vsf'));
 Result := True;
end;
