; Installateur Windows de Ma Cave (lot 10), pour Inno Setup 6.3 ou plus récent
; (7 compris : rien de ce qui a changé en version 7 n'est utilisé ici).
; Construit par tool\paquet_windows.ps1, qui passe la version :
;   ISCC /DAppVersion=1.0.0 windows\packaging\MaCave.iss
; Résultat : build\diffusion\MaCave-<version>-windows-setup.exe (nom fixé par
; docs\guide_installation.md).
;
; Installation pour l'utilisateur seul, sans droits d'administrateur, au même
; endroit que tool\installer_windows.ps1 (%LOCALAPPDATA%\Programs\Ma Cave,
; raccourci « Ma Cave » du menu Démarrer) : l'un remplace l'autre.
; Les DONNÉES (%APPDATA%\fr.bouthon\cave, Documents\Cave) ne sont jamais
; touchées, ni par l'installation ni par la désinstallation.

#ifndef AppVersion
  #error Passer la version : ISCC /DAppVersion=1.0.0 MaCave.iss
#endif

[Setup]
; Identifiant de l'appli pour Windows : NE JAMAIS LE CHANGER (sinon une
; mise à jour s'installerait comme une seconde appli).
AppId={{1AB11BBB-F8F0-4D33-AE34-BB45721F1095}
AppName=Ma Cave
AppVersion={#AppVersion}
AppVerName=Ma Cave {#AppVersion}
AppPublisher=Maxence Pithon
AppPublisherURL=https://github.com/Max-horion/MaCave
AppSupportURL=https://github.com/Max-horion/MaCave/issues
AppCopyright=© 2026 Maxence Pithon — GPL v3 ou ultérieure
VersionInfoVersion={#AppVersion}
VersionInfoDescription=Installateur de Ma Cave
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\Ma Cave
DisableDirPage=yes
DefaultGroupName=Ma Cave
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\cave.exe
UninstallDisplayName=Ma Cave
; Ferme Ma Cave si elle est ouverte (elle fait alors sa sauvegarde de
; fermeture) avant de remplacer ses fichiers.
CloseApplications=yes
RestartApplications=no
OutputDir=..\..\build\diffusion
OutputBaseFilename=MaCave-{#AppVersion}-windows-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer une icône sur le Bureau"; Flags: unchecked

[Files]
; L'appli entière compilée par « flutter build windows --release ».
; Les fichiers d'une version précédente sont retirés d'abord (une
; bibliothèque supprimée ne doit pas rester).
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
Type: filesandordirs; Name: "{app}\data"
Type: files; Name: "{app}\*.dll"

[Icons]
Name: "{userprograms}\Ma Cave"; Filename: "{app}\cave.exe"; Comment: "Gérer les bouteilles de sa cave personnelle"
Name: "{userdesktop}\Ma Cave"; Filename: "{app}\cave.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\cave.exe"; Description: "Lancer Ma Cave"; Flags: nowait postinstall skipifsilent
