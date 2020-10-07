// 全角数字、空白を半角にする js

var readline = require('readline');
var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', function(line){
  const arr = line.split(',');
  if (arr.length >= 2) {
    arr[1] = arr[1].replace(/[Ａ-Ｚａ-ｚ０-９！-～]/g, (s) => String.fromCharCode(s.charCodeAt(0) - 0xFEE0))
      .replace(/　+/g, ' ');
  }
  console.log(arr.join(','));
})
