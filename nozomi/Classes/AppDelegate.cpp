#define COCOS2D_DEBUG 1

#include "cocos2d.h"
#include "CCEGLView.h"
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"

#include "cocos2d_ext.h"

using namespace CocosDenshion;

USING_NS_CC;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

    // turn on display FPS
    pDirector->setDisplayStats(true);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);

    CCFileUtils *fileUtil = CCFileUtils::sharedFileUtils();
    CCLog("CCFileUtils initial %x", fileUtil);
    CCLog("Init App Delegate");
    

    // register lua engine
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    //pEngine->addSearchPath("assets");
    //需要实际路径 因为zip 打开的是 整个apk文件 其中lua文件在assets中
    CCString* pstrFileContent = CCString::createWithContentsOfFile("assets/main.lua");
    if (pstrFileContent)
    {
        pEngine->executeString(pstrFileContent->getCString());
    }
#else
	std::string path = CCFileUtils::sharedFileUtils()->fullPathFromRelativePath("main.lua");
    pEngine->addSearchPath(path.substr(0, path.find_last_of("/")).c_str());
    pEngine->executeScriptFile(path.c_str());
#endif
    //脚本自动检测更新
    //updateFiles();
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();

    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();

    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}


static AssetsManager *pAssetsManager = NULL;
void AppDelegate::updateFiles() {
	pathToSave = CCFileUtils::sharedFileUtils()->getWriteablePath();
    cout << "pathToSave "<< pathToSave << endl;
    if(pAssetsManager == NULL) {
        //CCLOG("pathToSave %s", pathToSave);

		pAssetsManager = new AssetsManager("http://localhost/test1.zip", "http://localhost/version");
	}
    //没有脚本更新 或者下载失败
    bool suc = false;
    if(pAssetsManager->checkUpdate()) {
        if(pAssetsManager->update()) {
		    suc = true;
            CCLOG("suc runLua file ");
		}
    } 
    loadScript();
	if(!suc){
        //如何将cache 目录加入到 路径搜索目录中呢？？
        /*
		CCArray *searchPath = CCFileUtils::sharedFileUtils()->getSearchPath();
		
		searchPath->addObject(CCString::create(pathToSave));
		CCFileUtils::sharedFileUtils()->setSearchPath(searchPath);
        
		cout << "search Path length " << searchPath->count() << endl;
		for(int i = 0; i < searchPath->count(); i++) {
			CCString *path = (CCString*)searchPath->objectAtIndex(i);
			cout << " searchPath " << path->getCString() << endl;
		}
		CCArray *searchRes = CCFileUtils::sharedFileUtils()->getSearchResolutionsOrder();
        cout << "search resolution " << searchRes->count() << endl;

		for(int i = 0; i < searchRes->count(); i++) {
			CCString *path = (CCString *)searchRes->objectAtIndex(i);
			cout << "search Res " << path->getCString() << endl;
		}
        */


	}
}

void AppDelegate::loadScript() {
    CCLuaEngine *pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

    pEngine->addSearchPath(pathToSave.c_str());
    string runLua = pathToSave+"main.lua";
    cout << "run lua file " << runLua << endl;
    pEngine->executeScriptFile(runLua.c_str());
}