#!/bin/bash
#
# csvを jangetter 出力 json っぽく変換する
#

awk -F"," -v BINMODE=3 -v datetime=`date +"%Y%m%d_%H%M%S"` -v ORS='\r\n' -v RS='\r\n' '
function kv(k, v) {
  gsub("\"", "\\\"", v);
  return " \"" k "\": \"" v "\""; 
}
function kvstr(k, colKey) {
  return kv(k, colIdx[colKey] ? $colIdx[colKey] : "");
}
function optstr(  opts) {
  opts = "";
  for (e in fOpt) {
    if (colIdx[fOpt[e]]) opts = opts (length(opts) == 0 ? "{ " : ",{ ") kv("name", fOpt[e]) ", " kvstr("value", fOpt[e]) " }";
  }
  if (length(opts) == 0) return "";
  return ", \"optional_attribute\": [ " opts " ]";
}
BEGIN {
  fJanCode = "商品コード";
  fName = "商品名称";
  fCategpry = "カテゴリ";
  split("小分類,JICFS分類名", fOpt, ",");
  

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
  print pre "{ " kvstr("jan", fJanCode) "," kvstr("title", fName) "," kvstr("category", fCategpry) optstr() "}";
}
END {
  print "] }";
}
'
