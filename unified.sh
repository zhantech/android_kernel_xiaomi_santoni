#!/bin/bash
rm -rf out
mkdir out
git clone https://github.com/Bikram557/AnyKernel3 --depth=1 anykernel
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --depth=1 gcc
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 --depth=1 gcc32
git clone https://github.com/Bikram557/Clang-11.0.x --depth=1 clang

export KBUILD_JOBS="$((`grep -c '^processor' /proc/cpuinfo`))"
export BOT_API_TOKEN=1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM
export chat_id=-1001151761414
export KBUILD_BUILD_USER=Bikram_M
export KBUILD_BUILD_HOST=SolarisCI
export TZ="Asia/Dhaka";
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Release type
if [ $BRANCH == "treble" ]; then
        export TYPE=Treble
elif [ $BRANCH == "nontreble" ]; then
        export TYPE=nontreble
elif [ $BRANCH == "pie" ]; then
        export TYPE=pie
else
export TYPE=Treble

fi

curl -s -X POST https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendMessage -d text="Buckle up bois $TYPE build has started" -d chat_id=-1001151761414 -d parse_mode=HTML

export YOLO="$(date -u +%m%d-%H)"
export ZIPNAME=$TYPE.zip
 export USE_CCACHE=0


# Set COMPILER
#export KBUILD_COMPILER_STRING="Clang Version 10.0.6"
export ARCH=arm64 && export SUBARCH=arm64

# compilation
START=$(date +"%s")
make O=out ARCH=arm64 santoni_defconfig
make -j8 O=out ARCH=arm64 CC="$(pwd)/clang/bin/clang" CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE="$(pwd)/gcc/bin/aarch64-linux-android-" CROSS_COMPILE_ARM32="$(pwd)/gcc32/bin/arm-linux-androideabi-"
END=$(date +"%s")
DIFF=$((END - START))

# prepare zip
if [ -f $(pwd)/out/arch/arm64/boot/Image.gz-dtb ]
	then
# Post to CI channel
curl -s -X POST https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendMessage -d text="Branch: <code>$(git rev-parse --abbrev-ref HEAD)</code>
Latest Commit: <code>$(git log --pretty=format:'%h : %s' -1)</code>
<i>Build compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</i>" -d chat_id=-1001151761414 -d parse_mode=HTML
#curl -s -X POST https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendMessage -d text="Flash now else bun" -d chat_id=-1001151761414 -d parse_mode=HTML

cp $(pwd)/out/arch/arm64/boot/Image.gz-dtb $(pwd)/anykernel
        cd anykernel
        zip -r9 SolarisKernel-Clang-$TYPE-$YOLO.zip * -x README.md SolarisKernel-Clang-$TYPE.zip

        curl -F chat_id="-1001151761414"  \
                    -F caption="sha1sum: $(sha1sum SolarisKernel*.zip | awk '{ print $1 }')" \
                    -F document=@"$(pwd)/SolarisKernel-Clang-$TYPE-$YOLO.zip" \
                    https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendDocument

        rm -rf SolarisKernel-Clang-$TYPE-$YOLO.zip  && rm -rf Image.gz-dtb
    curl -s -X POST "https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendSticker" \
        -d sticker="CAACAgUAAxkBAAIQD18HdH59ziwRPLLqkE6K4o0wAkVzAALXAANDYpglp90qhKKJtuUaBA" \
        -d chat_id="-1001151761414"
cd ..

else
        curl -s -X POST https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendMessage -d text="OMG Build error @Bikram_M bish phix wenn??" -d chat_id=-1001151761414 -d parse_mode=HTML
        curl -s -X POST "https://api.telegram.org/bot1105001387:AAEb1sgfaKcP1Hd4-9yDBTNZNxfzFnp05pM/sendSticker" \
        -d sticker="CAACAgUAAxkBAAIQD18HdH59ziwRPLLqkE6K4o0wAkVzAALXAANDYpglp90qhKKJtuUaBA" \
        -d chat_id="-1001151761414"
#    exit 1

fi

