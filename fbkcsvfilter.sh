#!/bin/bash
#
# csvを必要なデータでフィルタする
# "-r" オプションにて、フィルタ対象を逆転させる
#

MODE=1 # プラス1はそのままフィルタする
if [[ "$1" == "-r" ]]; then
  MODE=-1 # マイナス1はフィルタを反転する
fi

awk -F"," -v mode=$MODE -v BINMODE=3 -v ORS='\r\n' -v RS='\r\n' '
function setArr(str, arr,   narr) {
  split(str, narr, ",");
  for (e in narr) arr[narr[e]] = 1;
}
BEGIN {
  fMidCode = "中分類コード";
  fSmallCode = "小分類コード";
  fVerySmallCode = "細分類コード";
  setArr("", filterStrMid);
  setArr("1116,1118,1903,1902", filterStrSmall);
  setArr("110117,110119,110207,110401,110403,110405,110415,110497,111111,111207,111301,111303,111305,111501,111503,111509,111511,111597,130137,130139,140401,140407", filterStrVerySmall);
}
NR == 1 {
  for (i=1; i<=NF; i++) {
    colIdx[$i] = i;
  }
}
NR > 1 {
  exist = ($colIdx[fMidCode] in filterStrMid || $colIdx[fSmallCode] in filterStrSmall || $colIdx[fVerySmallCode] in filterStrVerySmall) ? 1 : -1;
  if (exist * mode > 0) next;
}
{
  print;
}
'

