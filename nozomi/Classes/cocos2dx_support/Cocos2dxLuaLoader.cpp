/****************************************************************************
Copyright (c) 2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "Cocos2dxLuaLoader.h"
#include <string>

using namespace cocos2d;

extern "C"
{
    //替换路径里面的 . 为 xxx/xxx.lua
    int loader_Android(lua_State *L)
    {
        std::string filename(luaL_checkstring(L, 1));
        //filename.append(".lua");
        std::string fullName = "assets/"+filename;
        int position = fullName.find(".");
        while(position != std::string::npos) {
            fullName.replace(position, 1, "/");
            position = fullName.find(".", position+1);
        }
        fullName.append(".lua");
        CCLog("loader_Android file %s", fullName.c_str());
        CCString* pFileContent = CCString::createWithContentsOfFile(fullName.c_str());


        if (pFileContent)
        {
            if (luaL_loadstring(L, pFileContent->getCString()) != 0)
            {
                luaL_error(L, "error loading module %s from file %s :\n\t%s",
                    lua_tostring(L, 1), filename.c_str(), lua_tostring(L, -1));
            }
        }
        else
        {
            CCLog("can not get file data of %s", filename.c_str());
        }

        return 1;
    }
}
