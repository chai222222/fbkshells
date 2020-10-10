#!/bin/bash
#
# csvを jangetter 出力 json っぽく変換する
#

awk -F"," -v BINMODE=3 -v datetime=`date +"%Y%m%d_%H%M%S"` -v ORS='\r\n' -v RS='\r\n' '
function kvstr(k, v) {
  gsub("\"", "\\\"", v);
  return " \"" k "\": \"" v "\""; 
}
BEGIN {
  fJanCode = "商品コード";
  fName = "商品名称";
  fLargeName = "大分類名称";
  fMidName = "中分類名称";
  fSmallName = "小分類名称";
  fVerySmallName = "細分類名称";
  out = 0;
}
NR == 1 {
  for (i=1; i<=NF; i++) {
    colIdx[$i] = i;
  }
  print "{  \"title\": \"企業様より" datetime "\", \"rows\": [";
}
NR > 1 {
  pre = out++ > 0 ? ", " : "";
  print pre "{ " kvstr("jan", $colIdx[fJanCode]) "," kvstr("title", $colIdx[fName]) "," kvstr("category", $colIdx[fLargeName] $colIdx[fMidName] $colIdx[fSmallName] $colIdx[fVerySmallName]) "}";
}
END {
  print "] }";
}
'
