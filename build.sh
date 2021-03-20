echo -e "\nStarting compilation...\n"

# ENV
CONFIG=santoni_treble_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
export KBUILD_BUILD_USER="ZHANtech™"
export KBUILD_BUILD_HOST="gatotkaca"
export PATH="$HOME/toolchain/proton/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/toolchain/proton/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$($HOME/toolchain/proton/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=out

# Functions
clang_build () {
    make -j$(nproc --all) O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
			  AS="llvm-as" \
			  OBJCOPY="llvm-objcopy" \
			  OBJDUMP="llvm-objdump" \
                          CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=aarch64-linux-gnu- \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi- 
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
echo -e "\nCompiling $ZIPNAME\n"
clang_build
if [ -f "$out/arch/arm64/boot/Image.gz-dtb" ]; then
 echo -e "\nKernel compiled succesfully! Zipping up...\n"
 ZIPNAME="GatotKaca•Kernel•Treble•Santoni-$(date '+%Y%m%d-%H%M').zip"
 if [ ! -d AnyKernel3 ]; then
  git clone -q https://github.com/zhantech/AnyKernel3.git -b santoni
 fi;
 mv -f $out/arch/arm64/boot/Image.gz-dtb AnyKernel3
 cd AnyKernel3
 zip -r9 "$HOME/$ZIPNAME" *
 cd ..
 rm -rf AnyKernel3
 echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
 echo -e "Zip: $ZIPNAME\n"
 rm -rf $out
else
 echo -e "\nCompilation failed!\n"
fi;
