.PHONY: lib
SDK=/home/user/Android/Sdk/
SDKV=23
JAVAC=ecj #/usr/lib/jvm/java-8-openjdk-amd64/bin/javac
ARCH=armeabi-v7a
pkgname=$(shell grep -o "package=.*" AndroidManifest.xml | cut -d\" -f2)
PATHCLS:=$(shell echo $(pkgname)|sed 's/\./\//g')
LIBNAME=libmain.so

alib:
	clang++ 1.cpp -llog -g -shared -o lib/$(ARCH)/$(LIBNAME)
	$(MAKE) rlib

lib: 3lib
	clang++ 2.cpp -llog -g -shared -Wl, -rpath /data/data/com.termux/files/home/ -l3 -L. -o 2.so
3lib:
	clang++ 3.cpp -llog -g -shared -o lib3.so

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
	aapt package -f -m -M AndroidManifest.xml -S res/ -J gen 
	$(JAVAC) -d obj -cp obj -bootclasspath $(SDK)/platforms/android-$(SDKV)/android.jar gen/$(PATHCLS)/* #with java 11 not working
	dx --dex --output=./classes.dex obj
	aapt package -f -m -F app.apk -A assets/ -M AndroidManifest.xml -S res/ #-I $(SDK)/platforms/android-$(SDKV)/android.jar
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
