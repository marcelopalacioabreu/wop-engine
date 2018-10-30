; Auto-generated by EclipseNSIS Script Wizard (1/4)
; ...and fine tuned by smiley :) (3/4)
; 01.03.2007 19:02:52
RequestExecutionLevel admin

; Included files
!include Sections.nsh
!include MUI.nsh
!insertmacro MUI_RESERVEFILE_LANGDLL
!define MUI_ICON "WoP.ico"
!define MUI_UNICON "UnWoP.ico"

; Installer attributes
Name "WoP Map Pack #1"
OutFile 'worldofpadman_mappack1.exe'

CRCCheck on
XPStyle on
ShowInstDetails hide
InstallDirRegKey HKLM ${REGKEY} Path
ShowUninstDetails hide

; Defines
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION "1.1"
!define COMPANY "Padworld Entertainment"
!define URL "http://www.worldofpadman.com"

; MUI defines
!define MUI_ABORTWARNING
!define MUI_WELCOMEFINISHPAGE_BITMAP "index.bmp"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_CUSTOMFUNCTION_GUIINIT "CustomGUIInit"
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_RUN "$INSTDIR\wop.exe"
!define MUI_FINISHPAGE_LINK "World of Padman Website"
!define MUI_FINISHPAGE_LINK_LOCATION  "http://www.worldofpadman.com"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_LANGDLL_REGISTRY_ROOT HKLM
!define MUI_LANGDLL_REGISTRY_KEY "SOFTWARE\World of Padman"
!define MUI_LANGDLL_REGISTRY_VALUENAME "InstallerLanguage"

; Reserved Files
ReserveFile "${NSISDIR}\Plugins\AdvSplash.dll"
ReserveFile "${NSISDIR}\Plugins\BGImage.dll"

; Variables
Var StartMenuGroup

; Installer pages
!insertmacro MUI_PAGE_WELCOME
#!insertmacro MUI_PAGE_LICENSE $(MUILicense)
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Installer languages
!insertmacro MUI_LANGUAGE English
!insertmacro MUI_LANGUAGE German

;Language strings
  LicenseLangString MUILicense ${LANG_ENGLISH} "wop-files\XTRAS\copyright_en.txt"
  LangString ^DESC_Section1 ${LANG_ENGLISH} "The $(^Name) featuring PadCastle, PadCrash and PadGallery"
  LangString ^DESC_aborttext ${LANG_ENGLISH} "I can�t find the path to your World of Padman installation"
  LangString ^DESC_dirtext ${LANG_ENGLISH} "This needs to be the path to your World of Padman installation!$\nPlease find it yourself when asked ;)"
  LangString ^DESC_readme ${LANG_ENGLISH} "index_en"
  LangString ^DESC_uninst ${LANG_ENGLISH} "The WoP Map Pack #1 is now uninstalled.$\nPlease note: you will be unable to play on 'pure' servers running these maps!"

  LicenseLangString MUILicense ${LANG_GERMAN} "wop-files\XTRAS\copyright_de.txt"
  LangString ^DESC_Section1 ${LANG_GERMAN} "Das $(^Name) mit den Maps PadCastle, PadCrash und PadGallery"
  LangString ^DESC_aborttext ${LANG_GERMAN} "Ich kann Deine World of Padman Installation nicht finden$\nBitte gib den Pfad selbst an, wenn danach verlangt wird ;)"
  LangString ^DESC_dirtext ${LANG_GERMAN} "Dies muss der Pfad zu Deiner World of Padman Installation sein"
  LangString ^DESC_readme ${LANG_GERMAN} "index_de"
  LangString ^DESC_uninst ${LANG_GERMAN} "Das WoP Map Pack #1 wurde deinstalliert.$\nBitte beachte: Du kannst nicht mehr auf 'pure' servern spielen, die diese Maps installiert haben!"

DirText $(^DESC_dirtext)


Function .onInit
    ReadRegStr $INSTDIR HKLM "SOFTWARE\World of Padman" "Path" 
    StrCmp $INSTDIR "" 0 NoAbort
      MessageBox MB_OK $(^DESC_aborttext)
    NoAbort:

    InitPluginsDir
    File /oname=$PLUGINSDIR\insttmp1.bmp "egal01.bmp"
    File /oname=$PLUGINSDIR\spltmp.bmp "setup1.bmp"

    Push $R1
    advsplash::show 1500 1000 1000 -1 "$PLUGINSDIR\spltmp"
    Pop $R1
    Pop $R1
    !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function CustomGUIInit
    Push $R1
    Push $R2
    BgImage::SetReturn /NOUNLOAD on
    BgImage::SetBg /NOUNLOAD /GRADIENT 0 0 0 0 0 0
    Pop $R1
    Strcmp $R1 success 0 error
    System::call "user32::GetSystemMetrics(i 0)i.R1"
    System::call "user32::GetSystemMetrics(i 1)i.R2"
    IntOp $R1 $R1 - 1024
    IntOp $R1 $R1 / 2
    IntOp $R2 $R2 - 768
    IntOp $R2 $R2 / 2
    BGImage::AddImage /NOUNLOAD $PLUGINSDIR\insttmp1.bmp $R1 $R2
    CreateFont $R1 "Verdana" 26 700 /ITALIC
    BGImage::AddText /NOUNLOAD "$(^Name)" $R1 255 255 255 16 8 900 100
    Pop $R1
    Strcmp $R1 success 0 error
    BGImage::Redraw /NOUNLOAD
    Goto done
error:
    MessageBox MB_OK|MB_ICONSTOP $R1
done:
    Pop $R2
    Pop $R1
FunctionEnd


; Installer sections
Section "$(^Name)" Section1

SectionIn RO
    SetOverwrite on

    SetOutPath $INSTDIR\wop
    File wop-files\wop\wop_padpack.pk3
    File wop-files\wop\server-wop_padpack.cfg

    SetOutPath $INSTDIR\xtras
    File wop-files\XTRAS\PadPack.txt
 
  SetShellVarContext all

    SetOutPath $INSTDIR
    CreateDirectory "$SMPROGRAMS\PadWorld Entertainment\$(^Name)"
    CreateShortCut "$SMPROGRAMS\PadWorld Entertainment\$(^Name)\Play the Wop PadPack.lnk" "$INSTDIR\wop.exe" "+exec server-wop_padpack.cfg" "$INSTDIR\wop.exe" 0
    CreateShortCut "$SMPROGRAMS\PadWorld Entertainment\$(^Name)\Start a LAN Server with the PadPack.lnk" "$INSTDIR\wop.exe" "+set dedicated 1 +exec server-wop_padpack.cfg" "$INSTDIR\wop.exe" 0
    CreateShortCut "$SMPROGRAMS\PadWorld Entertainment\$(^Name)\WoP PadPack ReadMe.lnk" "$INSTDIR\XTRAS\PadPack.txt" "" "" 0
    CreateShortCut "$SMPROGRAMS\PadWorld Entertainment\$(^Name)\UnWoP Map Pack 1.lnk" "$INSTDIR\UnWoPMap1.exe" "" "$INSTDIR\XTRAS\UnWoP.ico" 0

 
  WriteRegStr HKLM "${REGKEY}\Components" Main 1

SectionEnd


Section -post

    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    WriteUninstaller $INSTDIR\UnWoPMap1.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\UnWoPMap1.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\UnWoPMap1.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(^DESC_Section1)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
    next${UNSECTION_ID}:
        !insertmacro UnselectSection "${UNSECTION_ID}"
    done${UNSECTION_ID}:
        Pop $R0
!macroend

; Uninstaller sections

Section /o un.Main UNSEC0000
  SetShellVarContext all
    Delete "$SMPROGRAMS\PadWorld Entertainment\$(^Name)\*.*"
    RmDir "$SMPROGRAMS\PadWorld Entertainment\$(^Name)"
    Delete "$INSTDIR\XTRAS\PadPack.txt"
    Delete "$INSTDIR\wop\wop_padpack.pk3"
    Delete "$INSTDIR\wop\server-wop_padpack.cfg"
    Delete "$INSTDIR\UnWoPMap1.exe"
SectionEnd

Section un.post UNSEC0001
    DeleteRegValue HKLM "${REGKEY}\Components" Main
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
SectionEnd

; Uninstaller functions
Function un.onInit
    !insertmacro MUI_UNGETLANGUAGE
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    ReadRegStr $StartMenuGroup HKLM "${REGKEY}" StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    MessageBox MB_ICONINFORMATION|MB_OK $(^DESC_uninst)
FunctionEnd