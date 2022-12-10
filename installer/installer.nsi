; The name of the installer
Name "LightningBot"

; To change from default installer icon:
Icon "LightningBot.ico"

; The setup filename
OutFile "ui.exe"

; The default installation directory
InstallDir $PROGRAMFILES\LightningBot

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\LightningBot" "Install_Dir"

RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "LightningBot (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there (you can add more File lines too)
  File *.dll
  File *.exe
  File /r data\*.*
  ; Wildcards are allowed:
  ; File *.dll
  ; To add a folder named MYFOLDER and all files in it recursively, use this EXACT syntax:
  ; File /r MYFOLDER\*.*
  ; See: https://nsis.sourceforge.io/Reference/File
  ; MAKE SURE YOU PUT ALL THE FILES HERE IN THE UNINSTALLER TOO
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\LightningBot "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LightningBot" "DisplayName" "LightningBot"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LightningBot" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LightningBot" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LightningBot" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\LightningBot"
  CreateShortcut "$SMPROGRAMS\LightningBot\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\LightningBot\LightningBot.lnk" "$INSTDIR\lightningui.exe" "" "$INSTDIR\lightningui.exe" 0
  
SectionEnd

; Desktop shortcuts
Section "Desktop Shortcuts"


  CreateShortcut "$DESKTOP\LightningBot.lnk" "$INSTDIR\lightningui.exe" "" "$INSTDIR\lightningui.exe" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LightningBot"
  DeleteRegKey HKLM SOFTWARE\LightningBot

  ; Remove files and uninstaller
  ; MAKE SURE NOT TO USE A WILDCARD. IF A
  ; USER CHOOSES A STUPID INSTALL DIRECTORY,
  ; YOU'LL WIPE OUT OTHER FILES TOO
  Delete $INSTDIR\lightningui.exe
  Delete $INSTDIR\flutter_acrylic_plugin.dll
  Delete $INSTDIR\flutter_windows.dll
  Delete $INSTDIR\screen_retriever_plugin.dll
  Delete $INSTDIR\window_manager_plugin.dll
  Delete $INSTDIR\window_size_plugin.dll

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\LightningBot\*.*"

  ; Remove directories used (only deletes empty dirs)
  RMDir "$SMPROGRAMS\LightningBot"
  RMDir /r "$INSTDIR\data"
  RMDir "$INSTDIR"

SectionEnd