// TKBMS v1.0 -----------------------------------------------------
//
// PLATFORM       : ALL 
// PRODUCT        : VISION 
// VISIBILITY     : PUBLIC
//
// ------------------------------------------------------TKBMS v1.0


//  This class show how to use the vForge "play the Game" mode

#ifndef PLUGINMANAGER_H_INCLUDED
#define PLUGINMANAGER_H_INCLUDED

#include "GamePluginModule.h"

class MyGameManager : public IVisCallbackHandler_cl
{
public:
  virtual void OnHandleCallback(IVisCallbackDataObject_cl *pData) HKV_OVERRIDE;

  // called when plugin is loaded/unloaded
  void OneTimeInit();
  void OneTimeDeInit();

  // switch to play-the-game mode. When not in vForge, this is default
  void SetPlayTheGame(bool bStatus);

  // access one global instance of the Game manager
  static MyGameManager& GlobalManager() {return g_GameManager;}

private:
  bool m_bPlayingTheGame;
  static MyGameManager g_GameManager;
};


#endif // PLUGINMANAGER_H_INCLUDED
