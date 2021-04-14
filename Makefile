SDK=/home/user/Android/Sdk/
SDKV=23
JAVAC=/usr/lib/jvm/java-8-openjdk-amd64/bin/javac
ARCH=arm64-v8a
pkgname=$(shell grep -o "package=.*" AndroidManifest.xml | cut -d\" -f2)
PATHCLS:=$(shell echo $(pkgname)|sed 's/\./\//g')
LIBNAME=libmain.so

alib:
	aarch64-linux-android28-clang 1.c -llog -shared -o lib/$(ARCH)/$(LIBNAME)
	$(MAKE) rlib

init:
ifeq (,$(wildcard ./gen)) 
	mkdir gen
endif
ifeq (,$(wildcard ./obj)) 
	mkdir obj
endif
ifeq (,$(wildcard ./assets))
	mkdir assets
endif
	#@echo $(pkgname) $(PATHCLS)
	aapt package -f -m -M AndroidManifest.xml -S res/ -J gen -I $(SDK)/platforms/android-$(SDKV)/android.jar
	$(JAVAC) -d obj -cp obj -bootclasspath $(SDK)/platforms/android-$(SDKV)/android.jar gen/$(PATHCLS)/* #with java 11 not working
	dx --dex --output=./classes.dex obj
	aapt package -f -m -F app.apk -A assets/ -M AndroidManifest.xml -S res/ -I $(SDK)/platforms/android-$(SDKV)/android.jar
	aapt add app.apk classes.dex lib/$(ARCH)/*

rlib:
	aapt r app.apk lib/$(ARCH)/libmain.so 
	aapt add app.apk lib/$(ARCH)/libmain.so
	$(MAKE) sign

sign:
	zipalign -f 4 app.apk app1.apk
	apksigner sign --ks ~/mykey.keystore app1.apk <~/keypass
install:
	adb install -r app1.apk
	sleep 0.2 #Need sleep any time after installation to run
	adb shell am start $(pkgname)/android.app.NativeActivity
