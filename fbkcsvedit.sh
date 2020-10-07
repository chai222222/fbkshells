#!/bin/bash
#
# csvを必要なデータでフィルタする
# csvを必要なカラムを編集する
#

awk -F"," -v ORS='\r\n' -v RS='\r\n' '
function setArr(str, arr,   narr) {
  split(str, narr, ",");
  for (e in narr) arr[narr[e]] = 1;
}
BEGIN {
  fName = "商品名称";
  fMidCode = "中分類コード";
  fSmallCode = "小分類コード";
  fVerySmallCode = "細分類コード";
  setArr("12", filterStrMid);
  setArr("1304,1107,1502", filterStrSmall);
  setArr("111401,110497,111901,150101,150111,150121,150123,150141,150161,150163,150151,150153,150171,150181,150191,150193,150195,150197,199701", filterStrVerySmall);
}
NR == 1 {
  for (i=1; i<=NF; i++) {
    colIdx[$i] = i;
  }
}
NR > 1 && ($colIdx[fMidCode] in filterStrMid || $colIdx[fSmallCode] in filterStrSmall || $colIdx[fVerySmallCode] in filterStrVerySmall) {
  next;
}
{
  print;
}
'
