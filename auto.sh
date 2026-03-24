#!/bin/sh
## 本地仓库设置
SSTATE_LOCAL_PATH="/home/vivado/project/petalinux-2022.1"

case $1 in
        zynq)
                ARCH="arm"
                ;;
        zynqmp)
                ARCH="aarch64"
                ;;
        ,*)
                echo "Usage: $0 zynq/zynqmp"
                exit
esac

echo "ARCH=$ARCH"

if [ $ARCH == "" ]; then
  exit
fi

#删除带有指定关键字的行
delete_line_with_special_word ()
{
  if [[ $# -lt 2 ]]; then
	return
  fi
  FILE=$1
  WORD=$2

  sed -i "/${WORD}/d" ${FILE}
}
#文件内容追加
append_line_into_file ()
{
  if [[ $# -lt 2 ]]; then
	return
  fi
  FILE=$1
  LINE=$2
  echo do
  echo $LINE >> $FILE
}
CONFIG="./project-spec/configs/config"
cp $CONFIG $CONFIG.old

## 本地包
delete_line_with_special_word   $CONFIG  CONFIG_YOCTO_NETWORK_SSTATE_FEEDS
append_line_into_file           $CONFIG  "# CONFIG_YOCTO_NETWORK_SSTATE_FEEDS is not set"
delete_line_with_special_word   $CONFIG  CONFIG_YOCTO_BB_NO_NETWORK
append_line_into_file           $CONFIG  "CONFIG_YOCTO_BB_NO_NETWORK=y"
delete_line_with_special_word   $CONFIG  CONFIG_PRE_MIRROR_URL
append_line_into_file           $CONFIG  "CONFIG_PRE_MIRROR_URL=\"file://${SSTATE_LOCAL_PATH}/downloads\""
delete_line_with_special_word   $CONFIG  CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL
append_line_into_file           $CONFIG  "CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=\"${SSTATE_LOCAL_PATH}/${ARCH}\""

## | 目录      | 平台        |
## | --------- | ----------- |
## | aarch64   | ZynqMP      |
## | arm       | Zynq        |
## | mb-full   | MB AXI      |
## | mb-lite   | MB AXI lite |
## | downloads | 全平台  |
