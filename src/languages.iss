//====={ Выбор языка }=====\\
[Files]
Source: {#file "data\lang\ru\info_before.rtf"}; DestDir: "data\lang\ru\"; DestName: "info_before.rtf"; Flags: dontcopy;
;Source: "data\lang\ru\info_before.rtf"; DestDir: "data\lang\ru\"; Flags: dontcopy;
Source: {#file "data\lang\en\info_before.rtf"}; DestDir: "data\lang\en\"; DestName: "info_before.rtf"; Flags: dontcopy;
;Source: "data\lang\en\info_before.rtf"; DestDir: "data\lang\en\"; Flags: dontcopy;
Source: {#file "data\lang\ru\license.rtf"}; DestDir: "data\lang\ru\"; DestName: "license.rtf"; Flags: dontcopy;
;Source: "data\lang\ru\license.rtf"; DestDir: "data\lang\ru\"; Flags: dontcopy;
Source: {#file "data\lang\en\license.rtf"}; DestDir: "data\lang\en\"; DestName: "license.rtf"; Flags: dontcopy;
;Source: "data\lang\en\license.rtf"; DestDir: "data\lang\en\"; Flags: dontcopy;

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl,data\lang\ru\main.isl";
Name: "en"; MessagesFile: "compiler:Default.isl,data\lang\en\main.isl";
