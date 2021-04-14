#include <android/native_activity.h>
#include <stdio.h>
#include <stdlib.h>
#include <android/log.h>
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "MyApp", __VA_ARGS__))

void ANativeActivity_onCreate(ANativeActivity* activity, void* savedState, size_t savedStateSize)
{
    LOGI("Running");
    FILE *a = fopen("/sdcard/temp/123", "r+");
    fprintf(a, "123123");
    fclose(a);
    system("touch /sdcard/tmp/123");
    //exit(0);

}
