; DeskTabs installer (Inno Setup 6)
; Builds a per-user wizard installer: no admin rights, installs to
; %LOCALAPPDATA%\DeskTabs by default, optional autostart, proper entry in
; "Apps & features", and it never touches the user's own files on update.
;
; Build:  ISCC.exe /DAppVersion=1.1.2 /DSourceDir="..\dist\v112\DeskTabs-v1.1.2" installer\DeskTabs.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\dist\package"
#endif

#define AppName "DeskTabs"
#define AppPublisher "Henning Pähtz"
#define AppUrl "https://github.com/paehtz/DeskTabs"
#define AppExe "DeskTabs.exe"

[Setup]
AppId={{8B5D6C21-3E4A-4F1B-9C77-1D2E3F4A5B6C}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppUrl}
AppSupportURL={#AppUrl}/issues
AppUpdatesURL={#AppUrl}/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={localappdata}\DeskTabs
DefaultGroupName=DeskTabs
DisableProgramGroupPage=yes
DisableDirPage=no
AllowNoIcons=yes
PrivilegesRequired=lowest
OutputDir=..\dist\installer
OutputBaseFilename=DeskTabs-Setup-v{#AppVersion}
SetupIconFile=..\DeskTabs.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
LicenseFile=..\LICENSE
CloseApplications=yes
CloseApplicationsFilter=DeskTabs.exe
RestartApplications=no

[Languages]
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
de.AutoStart=DeskTabs mit Windows starten
de.LaunchAfter=DeskTabs jetzt starten
de.KeepData=Eigene Einstellungen, Symbole und Zeit-Logs behalten?
de.KeepDataMsg=Sollen Ihre Einstellungen, geladenen Symbole und Zeit-Logs erhalten bleiben?%n%nJa: die Dateien bleiben im Ordner liegen.%nNein: der Ordner wird vollständig entfernt.
en.AutoStart=Start DeskTabs with Windows
en.LaunchAfter=Start DeskTabs now
en.KeepData=Keep your settings, icons and time logs?
en.KeepDataMsg=Do you want to keep your settings, downloaded icons and time logs?%n%nYes: the files stay in the folder.%nNo: the folder is removed completely.

[Tasks]
Name: "autostart"; Description: "{cm:AutoStart}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Programmdateien - Nutzerdaten (settings.ini, icons\, timelog\) stehen
; bewusst NICHT hier, damit ein Update sie nicht anfasst.
Source: "{#SourceDir}\DeskTabs.exe";                DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\VirtualDesktopAccessor.dll";  DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\lang\*";                      DestDir: "{app}\lang"; Flags: ignoreversion recursesubdirs
Source: "{#SourceDir}\data\*";                      DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs
Source: "{#SourceDir}\README.md";                   DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\README.de.md";                DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\LICENSE";                     DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\LICENSE-AutoHotkey.txt";      DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\THIRD-PARTY-LICENSES.md";     DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\DeskTabs"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,DeskTabs}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\DeskTabs"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{userstartup}\DeskTabs"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: autostart

[Run]
Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Description: "{cm:LaunchAfter}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; laufende Instanz beenden, damit die Dateien nicht gesperrt sind
Filename: "{sys}\taskkill.exe"; Parameters: "/F /IM DeskTabs.exe"; Flags: runhidden; RunOnceId: "StopDeskTabs"

[Code]
// Beim Deinstallieren fragen, ob die eigenen Dateien des Nutzers bleiben sollen.
// Standard ist "behalten" - wer neu installiert, findet seine Tabs wie gewohnt vor.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Dir: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    Dir := ExpandConstant('{app}');
    if DirExists(Dir) then
    begin
      if MsgBox(ExpandConstant('{cm:KeepDataMsg}'), mbConfirmation, MB_YESNO) = IDNO then
        DelTree(Dir, True, True, True);
    end;
  end;
end;
