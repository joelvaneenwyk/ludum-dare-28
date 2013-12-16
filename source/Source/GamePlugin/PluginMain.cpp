// TKBMS v1.0 -----------------------------------------------------
//
// PLATFORM       : ALL 
// PRODUCT        : VISION 
// VISIBILITY     : PUBLIC
//
// ------------------------------------------------------TKBMS v1.0


//  Basic Plugin Framework to house your own components
//

#include "GamePluginPCH.h"
#include "myComponent.h"
#include "GameManager.h"

#include <Common/Base/KeyCode.h>

// use plugins if supported
VIMPORT IVisPlugin_cl* GetEnginePlugin_vFmodEnginePlugin();
#if defined( HAVOK_PHYSICS_2012_KEYCODE )
VIMPORT IVisPlugin_cl* GetEnginePlugin_vHavok();
#endif
#if defined( HAVOK_AI_KEYCODE )
VIMPORT IVisPlugin_cl* GetEnginePlugin_vHavokAi();
#endif
#if defined( HAVOK_BEHAVIOR_KEYCODE )
VIMPORT IVisPlugin_cl* GetEnginePlugin_vHavokBehavior();
#endif

//============================================================================================================
//  Set up the Plugin Class
//============================================================================================================
class myPlugin_cl : public IVisPlugin_cl
{
public:

  void OnInitEnginePlugin();    
  void OnDeInitEnginePlugin();  

  const char *GetPluginName()
  {
    return "GamePlugin";  // must match DLL name
  }
};

//  global plugin instance
myPlugin_cl g_myComponents;

//--------------------------------------------------------------------------------------------
//  create a global instance of a VModule class
//  note: g_myComponentModule is defined in stdfx.h
//--------------------------------------------------------------------------------------------
DECLARE_THIS_MODULE(g_myComponentModule, MAKE_VERSION(1,0),
                    "Sample Plugin", 
                    "Havok",
                    "A sample plugin for entities", &g_myComponents);


//--------------------------------------------------------------------------------------------
//  Use this to get and initialize the plugin when you link statically
//--------------------------------------------------------------------------------------------
VEXPORT IVisPlugin_cl* GetEnginePlugin_GamePlugin(){  return &g_myComponents; }


#if (defined _DLL) || (defined _WINDLL)

  //  The engine uses this to get and initialize the plugin dynamically
  VEXPORT IVisPlugin_cl* GetEnginePlugin(){return GetEnginePlugin_GamePlugin();}

#endif // _DLL or _WINDLL


//============================================================================================================
//  Initialize our plugin.
//============================================================================================================
//  Called when the plugin is loaded
//  We add our component initialize data here
void myPlugin_cl::OnInitEnginePlugin()
{
  hkvLog::Info("MyPlugin:OnInitEnginePlugin()");
  Vision::RegisterModule(&g_myComponentModule);

  
// load plugins if supported
#if defined( HAVOK_PHYSICS_2012_KEYCODE )
  VISION_PLUGIN_ENSURE_LOADED(vHavok);
#endif
#if defined( HAVOK_AI_KEYCODE )
  VISION_PLUGIN_ENSURE_LOADED(vHavokAi);
#endif
#if defined( HAVOK_BEHAVIOR_KEYCODE )
  VISION_PLUGIN_ENSURE_LOADED(vHavokBehavior);
#endif
  
  VISION_PLUGIN_ENSURE_LOADED(vFmodEnginePlugin);

  // In some cases the compiler optimizes away the full class from the plugin since it seems to be dead code. 
  // One workaround to prevent this is to add the following helper macro into the plugin initialization code:
  FORCE_LINKDYNCLASS( MyComponent );

  // [...]

  // Start our component managers and game manager here....
  MyGameManager::GlobalManager().OneTimeInit();
  MyComponent_ComponentManager::GlobalManager().OneTimeInit();
  // [...]

  //---------------------------------------------------------------------------------------------------------
  // register the action module with the vision engine action manager
  // only after that will the action become available in the console.
  //---------------------------------------------------------------------------------------------------------
  VActionManager * pManager = Vision::GetActionManager ();
  pManager->RegisterModule ( &g_myComponentModule );

  // Set to true to open the console at startup and print some data to the display
  Vision::GetConsoleManager()->Show( false );
  pManager->Print( "Welcome to the console!" );
  pManager->Print( "This module is called '%s'", g_myComponentModule.GetName() );
  pManager->Print( "Type in 'help' for a list of all actions" );
  pManager->Print( "Type in 'myAction' to test this projects demo action" );
}

// Called before the plugin is unloaded
void myPlugin_cl::OnDeInitEnginePlugin()
{
  hkvLog::Info("MyPlugin:OnDeInitEnginePlugin()");
    
  // Close our component managers here....
  MyComponent_ComponentManager::GlobalManager().OneTimeDeInit();
  MyGameManager::GlobalManager().OneTimeDeInit();
  //  [...]
  
  // de-register component from action manager
  VActionManager * pManager = Vision::GetActionManager ();
  pManager->UnregisterModule( &g_myComponentModule );

  // de-register our module when the plugin is de-initialized
  Vision::UnregisterModule(&g_myComponentModule);
}
