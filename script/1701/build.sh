#/bin/bash

cd $(dirname $0)
cd ../../tmp

mkdir -p sdk
rm -rf sdk/*
mkdir -p bin
rm -rf bin/*
cd sdk
cp ../sdk_download.txt .
aria2c -i sdk_download.txt -j 1

mkdir ../package
git clone git@github.com:CHN-beta/xmurp-ua.git ../package/xmurp-ua

cat ../sdk_list.txt | while read line
do
	{
		sdk=$(echo $line | awk '{print $3}')
		tar -xf $sdk
	} &
	sleep 3
done
wait

# 逐个编译，复制
cat ../sdk_list.txt | while read line
do
	sub1=$(echo $line | awk '{print $1}')
	sub2=$(echo $line | awk '{print $2}')
	sdk=$(echo $line | awk '{print $3}')
	url=$(echo $line | awk '{print $4}')
	cd ${sdk%.tar*}
	cp -r ../../package/xmurp-ua package/xmurp-ua
	make defconfig

	ARCH=$(ls build_dir)
	ARCH=${ARCH#*-}
	ARCH=${ARCH%%_*}

	CROSS_COMPILE=$(pwd)/staging_dir/$(ls staging_dir | grep toolchain)/bin/$ARCH-openwrt-linux-

	make package/xmurp-ua/compile ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE V=sc
	mkdir -p ../../bin/$sub1$sub2
	cp bin/targets/*/*/packages/kmod-xmurp-ua_*.ipk ../../bin/$sub1$sub2
	cd ..
done

