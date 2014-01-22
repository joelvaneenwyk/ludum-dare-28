#include "GameApplicationPCH.h"

#include <Vision/Runtime/Framework/VisionApp/VAppImpl.hpp>
#include <Vision/Runtime/Framework/VisionApp/Modules/VHelp.hpp>

#include <Vision/Runtime/EnginePlugins/Havok/HavokPhysicsEnginePlugin/vHavokPhysicsIncludes.hpp>

#include <Vision/Runtime/Framework/VisionApp/Modules/VLoadingScreen.hpp>

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

class LD28App : public VAppImpl
{
public:
	LD28App()
	{
	}

	virtual ~LD28App()
	{
	}

	virtual void SetupAppConfig(VisAppConfig_cl& config) HKV_OVERRIDE;
	virtual void PreloadPlugins() HKV_OVERRIDE;

	virtual void Init() HKV_OVERRIDE;
	virtual void OnAfterSceneLoaded(bool bLoadingSuccessful);
	virtual bool Run() HKV_OVERRIDE;
	virtual void DeInit() HKV_OVERRIDE;

protected:
	bool AddFileSystems(VArray<VString> *customSearchPaths = NULL);
};

VAPP_IMPLEMENT_SAMPLE(LD28App);

void LD28App::SetupAppConfig(VisAppConfig_cl& config)
{
  // Set custom file system root name ("havok_sdk" by default)
  config.m_sFileSystemRootName = "template_root";

  // Set the initial starting position of our game window and other properties
  // if not in fullscreen. This is only relevant on windows
  config.m_videoConfig.m_iXRes = 1280; // Set the Window size X if not in fullscreen.
  config.m_videoConfig.m_iYRes = 720;  // Set the Window size Y if not in fullscreen.
  config.m_videoConfig.m_iXPos = 50;   // Set the Window position X if not in fullscreen.
  config.m_videoConfig.m_iYPos = 50;   // Set the Window position Y if not in fullscreen.

  // Name to be displayed in the windows title bar.
  config.m_videoConfig.m_szWindowTitle = "One Shot - LD 28";

  config.m_videoConfig.m_bWaitVRetrace = true;

  // Fullscreen mode with current desktop resolution
  
#if defined(WIN32)
  /*
  DEVMODEA deviceMode;
  deviceMode = Vision::Video.GetAdapterMode(config.m_videoConfig.m_iAdapter);
  config.m_videoConfig.m_iXRes = deviceMode.dmPelsWidth;
  config.m_videoConfig.m_iYRes = deviceMode.dmPelsHeight;
  config.m_videoConfig.m_bFullScreen = true;
  */
#endif  
}

void LD28App::PreloadPlugins()
{
	VISION_PLUGIN_ENSURE_LOADED(vHavok);
	VISION_PLUGIN_ENSURE_LOADED(vFmodEnginePlugin);
	AddFileSystems();
}

//---------------------------------------------------------------------------------------------------------
// Init function. Here we trigger loading our scene
//---------------------------------------------------------------------------------------------------------
void LD28App::Init()
{
	VisAppLoadSettings settings("Scenes/main.vscene");
	AddFileSystems(&settings.m_customSearchPaths);
	LoadScene(settings);
}

//---------------------------------------------------------------------------------------------------------
// Gets called after the scene has been loaded
//---------------------------------------------------------------------------------------------------------
void LD28App::OnAfterSceneLoaded(bool bLoadingSuccessful)
{
}

//---------------------------------------------------------------------------------------------------------
// Main Loop of the application until we quit
//---------------------------------------------------------------------------------------------------------
bool LD28App::Run()
{
  return true;
}

void LD28App::DeInit()
{
  // De-Initialization
  // [...]
}

bool LD28App::AddFileSystems(VArray<VString> *customSearchPaths)
{
#if defined(WIN32)
	VStaticString<FS_MAX_PATH> sPackagePath = "/LD28.pcdx9.vArc";
#elif defined(ANDROID)
	VStaticString<FS_MAX_PATH> sPackagePath = "/LD28.android.vArc";
#endif

	VStaticString<FS_MAX_PATH> sProjectPath;

	bool added = false;
	bool pathExists = false;

	VStaticString<FS_MAX_PATH> sRootPath;
	if (VPathHelper::MakeAbsoluteDir("../../../../Assets", sRootPath.AsChar()) != NULL)
	{
		sProjectPath = sRootPath;
		sProjectPath += sPackagePath;

		pathExists = VFileHelper::Exists(sProjectPath);

		if (!pathExists && VPathHelper::MakeAbsoluteDir("", sRootPath.AsChar()) != NULL)
		{
			sProjectPath = sRootPath;
			sProjectPath += sPackagePath;
			pathExists = VFileHelper::Exists(sProjectPath);
		}
	}

	if (pathExists)
	{
		added = Vision::File.AddFileSystem("template_root", sProjectPath, VFileSystemFlags::ADD_SEARCH_PATH);
	}

	VASSERT(added);

	return added;
}