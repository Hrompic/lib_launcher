#include <android/native_activity.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <android/log.h>
#include <jni.h>
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "MyApp", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "MyApp", __VA_ARGS__))

typedef void (*activityOnCreatePointer)(ANativeActivity*, void*, size_t);

void ANativeActivity_onCreate(ANativeActivity* activity, void* savedState, size_t savedStateSize)
{
    JNIEnv *lJNIEnv = activity->env;
    jclass envclass = lJNIEnv->FindClass("android/os/Environment");

    jmethodID mStdir = lJNIEnv->GetStaticMethodID(envclass, "getExternalStorageDirectory", "()Ljava/io/File;");
//    jfieldID dirDown = lJNIEnv->GetFieldID(envclass, "DIRECTORY_DOWNLOADS", "Ljava/lang/String;");
//    jstring strDir = static_cast<jstring>(lJNIEnv->GetObjectField(envclass, dirDown));
    jobject fileobj = lJNIEnv->CallStaticObjectMethod(envclass , mStdir);
    
    jclass filecls = lJNIEnv->FindClass("java/io/File");

    jmethodID MethodGetPath = lJNIEnv->GetMethodID(filecls, "getPath", "()Ljava/lang/String;");
    jstring str = (jstring)lJNIEnv->CallObjectMethod(fileobj, MethodGetPath);

    const char* dirPath = lJNIEnv->GetStringUTFChars(str, NULL);
    LOGI("%s", dirPath);
    lJNIEnv->ReleaseStringUTFChars(str, dirPath);

    LOGI("Running");
    FILE *a = fopen("/storage/emulated/0/temp/123", "w");
    fprintf(a, "123123");
    fclose(a);
    //void *lib = dlopen("/storage/emulated/0/temp/2.so", RTLD_NOW | RTLD_GLOBAL);
/*    void *l = dlopen("/data/data/com.termux/files/home/lib3.so", RTLD_NOW | RTLD_GLOBAL);
    if(!l)
    {
        LOGE("dlopen(\"%s\"): %s", "lib3.so", dlerror());
    }*/
    void *lib = dlopen("/data/data/com.termux/files/home/2.so", RTLD_NOW | RTLD_GLOBAL);
    if(!lib)
    {
        LOGE("dlopen(\"%s\"): %s", "2.so", dlerror());
    }
   activityOnCreatePointer ANativeActivity_onCreate = (activityOnCreatePointer)dlsym(lib, "ANativeActivity_onCreate");
     if (!ANativeActivity_onCreate)
     {
         LOGE("Undefined symbol ANativeActivity_onCreate");
         exit(1);
     }
    ANativeActivity_onCreate(activity, savedState, savedStateSize);
    //exit(0);

}
