//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("WinRtkBaseConfigure.res");
USEFORM("Main.cpp", fmMain);
USERC("iso3166.rc");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->CreateForm(__classid(TfmMain), &fmMain);
                 Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        return 0;
}
//---------------------------------------------------------------------------
