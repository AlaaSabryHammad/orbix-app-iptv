; Orbix for Windows — installer (Inno Setup 6 or later).
; Built by tool/windows/build_installer.ps1, which passes AppVersion and
; SourceDir; compiling this file by hand uses the defaults below.

#define AppName "Orbix"
#define AppExe "Orbix.exe"
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\prod\runner\Release"
#endif

[Setup]
; Never change AppId: upgrades and the uninstaller find Orbix by it.
AppId={{40122170-DE24-4C57-B08B-E6ECC27D7BD1}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Orbix
AppPublisherURL=https://orbix.handaza.cloud
AppSupportURL=https://orbix.handaza.cloud
VersionInfoVersion={#AppVersion}
; Per-user install, no administrator prompt (%LOCALAPPDATA%\Programs\Orbix);
; the first page offers "install for all users" instead.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
; Close a running Orbix before replacing its files (mutex from main.cpp).
AppMutex=Local\app.orbix.player
CloseApplications=yes
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
OutputDir=..\..\dist
OutputBaseFilename=Orbix-Setup-{#AppVersion}-x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Arabic is an unofficial Inno Setup translation: used when it's installed.
#if FileExists(AddBackslash(CompilerPath) + "Languages\Arabic.isl")
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
#endif

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[InstallDelete]
; An upgrade must not keep assets the new version dropped.
Type: filesandordirs; Name: "{app}\data\flutter_assets"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

; Accounts, favorites and progress (%APPDATA%\Orbix) stay on uninstall, like
; other Windows apps, so a reinstall picks up where the user left off.
