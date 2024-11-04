#!/bin/bash
#
# 指定された キャッシュファイルを、パラメータにより置き換える。
#
# replace_cache_json.sh [-s SEP] キャッシュファイル "キー[SEP]置き換え前文字列(正規表現)[SEP]置き換え後文字列"...
#

COMMAND="$0"
CMD=${COMMAND##*/}

usage() {
  [[ "$1" != "" ]] && echo -e "$1\n"
  echo "usage: $CMD [-s SEP] キャッシュファイル 'キー[SEP]置き換え前文字列(正規表現)[SEP]置き換え後文字列'..."
  echo 'SEPデフォルト ":"'
  exit 1
}

type jq > /dev/null 2>&1
[[ $? != 0 ]] && usage "jq がインストールされていません。"

SEP=":"
[[ $# > 1 && $1 = "-s" ]] && SEP=$2 && shift 2
[[ $# < 2 ]] && usage
CACHE=$1 ; shift

declare -A CONTAINS
REP=
while [[ $# > 0 ]]
do
  IFS=$SEP eval 'arr=($1)'
  len=${#arr[@]}
  [[ $len != 3 ]] && usage "置き換え定義が区切り文字で区切られて３フィールドになっていません[$1][SEP=$SEP]"
  CONTAINS[${arr[0]}]="${CONTAINS[${arr[0]}]}|${arr[1]}"
  REP="$REP| .${arr[0]} |= sub(\"${arr[1]}\"; \"${arr[2]}\") "
  shift
done

SEL=
for CONTAIN in "${!CONTAINS[@]}"
do
  if [[ "${#SEL}" == 0 ]]; then
    SEL="| select("
  else
    SEL="$SEL or "
  fi
  SEL="$SEL(.${CONTAIN} | test(\"${CONTAINS[$CONTAIN]#|}\"))"
done
SEL="$SEL)"

SEL_JSON="`basename $CACHE .json `_select.json"
MOD_JSON="`basename $SEL_JSON .json `_mod.json"

set -x

jq ".[] $SEL | [.]" $CACHE > $SEL_JSON
jq ".[] $REP | [.]" $SEL_JSON > $MOD_JSON

diff --width 200 -y $SEL_JSON $MOD_JSON | egrep 'id|code|\|'

#echo "SEL=$SEL"
#echo "REP=$REP"
#echo "SEL_JSON=$SEL_JSON"
#echo "MOD_JSON=$MOD_JSON"

#jq '.[] | select(.title | contains("ポッカS")) | [ . ]' cache.json > pocca_s.json
#jq '.[] | .title |= sub("ポッカS"; "ポッカサッポロ") | [ . ]' pocca_s.json > pocca_sapporo.json
#cat sample.json | jq '.[]|if(.user|test("(hoge|fuga)")) then .team="A" elif(.user|test("(foo|bar)")) then .team="B" else . end'

