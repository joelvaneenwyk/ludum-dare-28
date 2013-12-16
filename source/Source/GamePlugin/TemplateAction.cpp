// TKBMS v1.0 -----------------------------------------------------
//
// PLATFORM       : ALL 
// PRODUCT        : VISION 
// VISIBILITY     : PUBLIC
//
// ------------------------------------------------------TKBMS v1.0


//  A basic action that just prints something to the console
//

#include "GamePluginPCH.h"
#include <Vision/Runtime/Engine/System/Vision.hpp>
#include "TemplateAction.h"


//  Register the action with a module - this always has to be in the .cpp file
//  The string "MyAction" is the name of the cammand to be used in the console
V_IMPLEMENT_ACTION( "MyAction", MyAction_cl, VAction,&g_myComponentModule, NULL )

//============================================================================================================
//============================================    A C T I O N   ==============================================
//============================================================================================================

MyAction_cl::MyAction_cl(){}
  
MyAction_cl::~MyAction_cl(){}
 
//------------------------------------------------------------------------------------------------------------
//  This function will be called when the action command is entered into the console
//------------------------------------------------------------------------------------------------------------
VBool MyAction_cl::Do( const class VArgList &argList )
{    
  //  add you code here to be called by typing 'myAction' into the console
  //  [...]

  Print ( "========================================" );
  Print ( "========== This is an action! ==========" );
  Print ( "========================================" );

  //float fCount  = 1234.223344;
  //int iCount  = 9876;

  Vision::Message.Add( "You have triggered an Action!" );
  //Vision::Message.Add("Float: %f", fCount );
  //Vision::Message.Add(0,"Int: %i", iCount );
  return TRUE;
}
//------------------------------------------------------------------------------------------------------------
