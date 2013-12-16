// TKBMS v1.0 -----------------------------------------------------
//
// PLATFORM       : ALL 
// PRODUCT        : VISION 
// VISIBILITY     : PUBLIC
//
// ------------------------------------------------------TKBMS v1.0


#ifndef H_MYACTION
#define H_MYACTION

#include <Vision/Runtime/Base/Action/VAction.hpp>


//  if one needs access to the module somewhere else, just include this line but never declare multiple times: 
//  only one declare in one .cpp file!
extern VModule g_sampleModule; 

//============================================================================================================
//============================================    A C T I O N   ==============================================
//============================================================================================================
//  all actions are dereived from VAction

class MyAction_cl : public VAction
{
  // required first line 
  V_DECLARE_ACTION(MyAction_cl)
public:
  // construct
  MyAction_cl();

  // destruct
  ~MyAction_cl();

  // this function is the only one you actually have use
  VOVERRIDE VBool Do(const class VArgList &argList);
    
private:    
};

#endif
