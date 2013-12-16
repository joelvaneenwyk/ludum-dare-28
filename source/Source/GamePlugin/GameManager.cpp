// TKBMS v1.0 -----------------------------------------------------
//
// PLATFORM       : ALL 
// PRODUCT        : VISION 
// VISIBILITY     : PUBLIC
//
// ------------------------------------------------------TKBMS v1.0

#include "GamePluginPCH.h"
#include "GameManager.h"

// one global static instance
MyGameManager MyGameManager::g_GameManager;

void MyGameManager::OneTimeInit()
{
  m_bPlayingTheGame = false;

  // the game manager should listen to the following callbacks:
  Vision::Callbacks.OnEditorModeChanged += this;
  Vision::Callbacks.OnBeforeSceneLoaded += this;
  Vision::Callbacks.OnAfterSceneLoaded += this;
  Vision::Callbacks.OnUpdateSceneBegin += this;
  Vision::Callbacks.OnWorldDeInit += this;
}

void MyGameManager::OneTimeDeInit()
{
  Vision::Callbacks.OnEditorModeChanged -= this;
  Vision::Callbacks.OnBeforeSceneLoaded -= this;
  Vision::Callbacks.OnAfterSceneLoaded -= this;
  Vision::Callbacks.OnUpdateSceneBegin -= this;
  Vision::Callbacks.OnWorldDeInit -= this;
}



void MyGameManager::OnHandleCallback(IVisCallbackDataObject_cl *pData)
{

  if (pData->m_pSender==&Vision::Callbacks.OnUpdateSceneBegin)
  {
      //This callback will be triggered at the beginning of every frame
      //You can add your own per frame logic here
      // [...]
      if (m_bPlayingTheGame)
      {
        Vision::Message.Print(1, 200, 100, "The game is running");
      }
      return;
  }

  if (pData->m_pSender==&Vision::Callbacks.OnEditorModeChanged)
  {
    // when vForge switches back from EDITORMODE_PLAYING_IN_GAME, turn off our play the game mode
    if (((VisEditorModeChangedDataObject_cl *)pData)->m_eNewMode != VisEditorManager_cl::EDITORMODE_PLAYING_IN_GAME)
      SetPlayTheGame(false);
    return;
  }

  if (pData->m_pSender==&Vision::Callbacks.OnBeforeSceneLoaded)
  {
    //here you can add you specific code before the scene is loaded
    return;
  }

  if (pData->m_pSender==&Vision::Callbacks.OnAfterSceneLoaded)
  {
    //gets triggered when the play-the-game vForge is started or outside vForge after loading the scene
    if (Vision::Editor.IsPlayingTheGame()) 
      SetPlayTheGame(true);
    return;
  }

  if (pData->m_pSender==&Vision::Callbacks.OnWorldDeInit) 
  {
     // this is important when running outside vForge
    SetPlayTheGame(false);
    return;
  }
}


// switch to play-the-game mode
void MyGameManager::SetPlayTheGame(bool bStatus)
{
  if (m_bPlayingTheGame==bStatus)
    return;

  m_bPlayingTheGame = bStatus;

  if (m_bPlayingTheGame)
  {
     // Play the game mode is started
     Vision::Message.Add(1, "Play the game mode has been started");
  } 
  else
  {
    //the play the game mode has been stopped.
    //clean up all your game specific instances, like e.g. particle effects
    //VisParticleGroupManager_cl::GlobalManager().Instances().Purge();
  }
}
