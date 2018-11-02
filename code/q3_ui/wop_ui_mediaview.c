/*****************************************************************************
 *        This file is part of the World of Padman (WoP) source code.        *
 *                                                                           *
 *      WoP is based on the ioquake3 fork of the Quake III Arena source.     *
 *                 Copyright (C) 1999-2005 Id Software, Inc.                 *
 *                                                                           *
 *                         Notable contributions by:                         *
 *                                                                           *
 *          #@ (Raute), cyrri, Herby, PaulR, brain, Thilo, smiley            *
 *                                                                           *
 *           https://github.com/PadWorld-Entertainment/wop-engine            *
 *****************************************************************************/

/*
=======================================================================

  WoP Media View Menu
  by #@

  this should display picture(comics), videos, ... (not in use)

=======================================================================
*/

#include "wop_ui_local.h"

#define MAX_EXECONCLOSE 512

const char *mediatype_strs[] = {
		":",
		"picture:",
		"video:",
		NULL
};

typedef enum{
	MT_UNKNOWN = 0,
	MT_PICTURE,
	MT_VIDEO,
} mediatype_e;

typedef struct{
	menuframework_s menu;
	mediatype_e     mediatype;
	int             CINhandle;
	menubitmap_s    comicPic;
	menubitmap_s    closeButton;
	char            execOnClose[MAX_EXECONCLOSE];
} mediaview_menu_t;

static mediaview_menu_t s_mediaview_menu;

//TODO: trap_CIN_StopCinematic when leaving the menu!!! ... and restart music playback -.-

/**
  The mediaRef should be something like:
  "comic:comics/story1/myPage2.jpg"
  "video:videos/wopIntro.roq"
  ...

  first version should work for comic and video
*/
static const char *EMPTY_MEDIAFILEPATH_STRING = "";

/*
=================
MediaView_OnClose
=================
*/
static void (void){
	if(s_mediaview_menu.mediatype == MT_VIDEO){
		trap_CIN_StopCinematic(s_mediaview_menu.CINhandle);
		Music_TriggerRestart();
		uis.musicbool = qfalse;
	}

	if(s_mediaview_menu.execOnClose[0]){
		trap_Cmd_ExecuteText(EXEC_APPEND, va("%s\n", s_mediaview_menu.execOnClose));
	}
}

/*
=================
MediaView_MenuDraw
=================
*/
static void (void){
	Menu_Draw(&s_mediaview_menu.menu);

	switch(s_mediaview_menu.mediatype){
		case MT_PICTURE:
			break;
		case MT_VIDEO:{
			e_status cinStatus;
			cinStatus = trap_CIN_RunCinematic(s_mediaview_menu.CINhandle);
			DrawLine(0, 0, 20, 20, 1,
			         colorBlack); //note: DrawCinematic is no render-cmd, because of that it will probably be drawn before the previously done 2D-drawings are really drawn (using my Advanced2D, leads to a scene-randering, which seems to make sure that all 2D things are drawn)
			trap_CIN_DrawCinematic(s_mediaview_menu.CINhandle);

			if(cinStatus != FMV_PLAY){
				//TODO? auto pop menu?
				//				UI_DrawStringNS(320,240,"THE END",UI_CENTER,20,colorWhite);
				MediaView_OnClose();
				UI_PopMenu();
			}
		}

			break;
		default:
			UI_DrawStringNS(320, 240, "error while loading media menu (check console output)", UI_CENTER, 20, colorWhite);
			break;
	}
}

/*
=================
MediaView_MenuKey
=================
*/
static sfxHandle_t (int key){

	if(key == K_MOUSE2 || key == K_ESCAPE){
		MediaView_OnClose();
	}

	return Menu_DefaultKey(&s_mediaview_menu.menu, key);
}

/*
=================
MediaView_CloseAction
=================
*/
static void (void *ptr, int event){
	if(event == QM_ACTIVATED){
		MediaView_OnClose();
		UI_PopMenu();
	}
}


/*
=================
LaunchMediaViewMenu
=================
*/
void (const char *mediaRef, const char *execOnClose){
	int        i              = 0;
	const char *mediafilepath = EMPTY_MEDIAFILEPATH_STRING;

	//TODO? pop the menu if the current one is this one? *ponder*

	memset(&s_mediaview_menu, 0, sizeof(mediaview_menu_t));
	s_mediaview_menu.mediatype = MT_UNKNOWN; //note: just to make it clear (I know that memset would also set 0 ;) )

	if(execOnClose && *execOnClose){
		Q_strncpyz(s_mediaview_menu.execOnClose, execOnClose, sizeof(s_mediaview_menu.execOnClose));
	}

	for(i = 0; mediatype_strs[i]; ++i){
		if(i != MT_UNKNOWN){
			int compLen = strlen(mediatype_strs[i]);

			if(!Q_stricmpn(mediaRef, mediatype_strs[i], compLen)){
				s_mediaview_menu.mediatype = i;

				mediafilepath = (mediaRef + compLen);

				if(*mediafilepath == '\0'){
					mediafilepath = EMPTY_MEDIAFILEPATH_STRING;
				}
			}
		}
	}

	s_mediaview_menu.menu.draw       = MediaView_MenuDraw;
	s_mediaview_menu.menu.key        = MediaView_MenuKey;
	s_mediaview_menu.menu.fullscreen = qtrue;

	//FIXME: take another texture for the close button (back doesn't fit so good)
	s_mediaview_menu.closeButton.generic.type     = MTYPE_BITMAP;
	s_mediaview_menu.closeButton.generic.name     = "menu/single/continue/start0";
	s_mediaview_menu.closeButton.generic.flags    = QMF_LEFT_JUSTIFY | QMF_PULSEIFFOCUS;
	s_mediaview_menu.closeButton.generic.callback = MediaView_CloseAction;
	s_mediaview_menu.closeButton.generic.x        = 640 - 40;
	s_mediaview_menu.closeButton.generic.y        = 480 - 40;
	s_mediaview_menu.closeButton.width            = 30;
	s_mediaview_menu.closeButton.height           = 30;
	s_mediaview_menu.closeButton.focuspic         = "menu/single/continue/start1";
	s_mediaview_menu.closeButton.focuspicinstead  = qtrue;

	switch(s_mediaview_menu.mediatype){
		case MT_PICTURE:
			Com_Printf("[mediaview] loading Comic: %s\n", mediafilepath);

			// set menu cursor to a nice location
			uis.cursorx = 320;
			uis.cursory = 240;

			s_mediaview_menu.comicPic.generic.type  = MTYPE_BITMAP;
			s_mediaview_menu.comicPic.generic.name  = mediafilepath;
			s_mediaview_menu.comicPic.generic.flags = QMF_LEFT_JUSTIFY | QMF_SILENT;
			//		s_mediaview_menu.comicPic.generic.callback	= UI_SecretAction;
			s_mediaview_menu.comicPic.generic.x     = 0;
			s_mediaview_menu.comicPic.generic.y     = 0;
			s_mediaview_menu.comicPic.width         = 640;
			s_mediaview_menu.comicPic.height        = 480;
			Menu_AddItem(&s_mediaview_menu.menu, &s_mediaview_menu.comicPic);

			Menu_AddItem(&s_mediaview_menu.menu, &s_mediaview_menu.closeButton);

			break;
		case MT_VIDEO:
			Com_Printf("[mediaview] loading Video: %s\n", mediafilepath);
			s_mediaview_menu.CINhandle          = trap_CIN_PlayCinematic(mediafilepath, 0, 0, 640, 480, /*int bits*/
			                                                             0);// CIN_loop, CIN_hold
			s_mediaview_menu.menu.noMouseCursor = qtrue;
			trap_S_StopBackgroundTrack();
			break;
		default:
			Com_Printf("[mediaview] Couldn't find a known mediatype in the string: %s\n", mediaRef);
			break;
	}

	UI_PushMenu(&s_mediaview_menu.menu);
}
