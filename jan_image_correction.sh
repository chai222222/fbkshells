#!/bin/bash
#
# 指定された "jangetter -g" 出力フォルダのイメージを補正した新しいディレクトリを作成する。
#
#

COMMAND="$0"
CMD=${COMMAND##*/}
NIMG_SUF="jpeg"

IMGS1=/tmp/${CMD}_1
IMGS2=/tmp/${CMD}_2
IMGS3=/tmp/${CMD}_3.sed

usage() {
  [[ "$1" != "" ]] && echo -e "$1\n"
  echo "usage: $CMD directories..."
  exit 1
}

# 対象ディレクトリのデータをチェックします。
checkDir() {
  local dir="$1"
  [[ ! -f "$dir/data.json" ]] && usage "$dir/data.jsonが存在しません"
  [[ ! -f "$dir/index.html" ]] && usage "$dir/index.htmlが存在しません"
  ! grep -q '<style type="text/css">' "$dir/index.html" && usage "$dir/index.htmlが古いフォーマットになっています"
  sed -n '/"picture"/s@^.*: "\([^"]*\)".*$@'$dir'/\1@p' "$dir/data.json" > $IMGS1
  # JPEG以外か高さが幅を超えるものを抽出
  identify `cat $IMGS1` | gawk '
  {
    split($3, wh, "x");
    if ($2 != "JPEG" || wh[1] - wh[2] < 0) print $1;
  }
  ' > $IMGS2
  cmp -s $IMGS1 $IMGS2
  echo $?
}

# 対象ディレクトリからデータ変換します・
correctionDir() {
  local src="$1"
  local dst="${1}_edited"
  local idres wh
  rm -fr $IMGS3 $dst
  mkdir -p $dst
  # images
  for IMAGE in `cat $IMGS1`
  do
    local img=${IMAGE##*/} # basename
    grep -q $IMAGE $IMGS2
    if [[ $? == 0 ]]; then
      # 要変換
      echo "edit: $img"
      idres=(`identify $IMAGE`)
      wh=(${idres[2]//x/ })
      local nimg="${img%.*}.$NIMG_SUF"
      local sz=$((wh[0] < wh[1] ? wh[1] : wh[0]))
      echo convert $IMAGE -gravity center -extent "${sz}x${sz}" "$dst/$nimg"
      convert $IMAGE -gravity center -extent "${sz}x${sz}" "$dst/$nimg"
      [[ $? != 0 ]] && usage "convert失敗: convert $IMAGE -gravity center -extent ${sz}x${sz} $dst/$nimg"
      echo "s/$img/$nimg/" >> $IMGS3
    else
      # 変換不要
      echo "skip: $img"
      cp -p "$src/$img" "$dst/$img"
    fi
  done
  # data.json
  echo "edit: data.json"
  sed -f $IMGS3 "$src/data.json" > "$dst/data.json"
  # index.html, index2.html作成
  echo "edit: index.html"
  sed -f $IMGS3 "$src/index.html" > "$dst/index.html"
  echo "create: index2.html"
  sed -f $IMGS3 \
    -e 's/img style="width: 100px; height: 100px;"/img/' \
    -e '/^    }/a \    img {\n      border: solid 1px;\n    }' \
    "$src/index.html" > "$dst/index2.html"
  echo "Done. $dst に補正後のデータが作成されました。"
}

type identify > /dev/null 2>&1
[[ $? != 0 ]] && usage "ImageMagick がインストールされていません。"

[[ $# < 1 ]] && usage

for DIR in $*
do
  CHK=`checkDir $DIR`
  if [[ $CHK != 0 ]]; then
    correctionDir $DIR
  else
    echo "$DIR は補正対象がないため処理を行いません。"
  fi
done