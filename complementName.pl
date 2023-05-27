#!/usr/bin/perl
#
# csvファイルの特定カラムを正規化する
#
# 以下前提条件
# ・取引先名は 4 カラム目固定
# ・ちゃんとしたcvs2には対応しない。
#

use utf8;
use open IO => ":utf8";
use open ':std' => ":utf8";
#use Lingua::JA::Regular::Unicode qw/hiragana2katakana katakana2hiragana/;


$targetColumn = 3;      # ４カラム目
$/ = "\r\n";            # 改行は全て CRLF
my %normalize;          # 正規化名称

#
# 正規化関数群
#

# 空白除去
sub _rmSpaces { $_[0] =~ s/\s+//g; }

# 全角記号除去
sub _rmHalfSymbols { $_[0] =~ s/[!-\/:-@[-`{-~]+//g; }

# 全角記号除去(うーん、わからん)
sub _rmMultiSymbols { $_[0] =~ s/[！”＃＄％＆’（）＝～｜‘｛＋＊｝＜＞？＿－＾￥＠「；：」、。・]+//g; }


# カタカナ→平仮名(ヴは除く)
sub _katakana2Hiragana { $_[0] =~ tr/ァ-ン/ぁ-ん/; }

# 平仮名→カタカナ(ヴは除く)
sub _hiragana2Katakana { $_[0] =~ tr/ぁ-ん/ァ-ン/; }

sub _join {
  my(@funcs) = @_;
  return sub {
    foreach my $func (@funcs) {
      $func->($_[0]);
    }
  };
}

my(@normalizationFuncs) = (
  \&_rmSpaces,
  \&_rmMultiSymbols,
  \&_rmHalfSymbols,
  \&_katakana2Hiragana,
  \&_hiragana2Katakana,
  _join(\&_rmSpaces, \&_rmMultiSymbols, \&_rmHalfSymbols),
);

#
# 引数の文字列を正規化する
#
sub normalization {
  my($word) = @_;
  return $word if $normalize{$word}; # 正規化されたものなので何もしない
  foreach my $func (@normalizationFuncs) {
    my($nWord) = $word;
    $func->($nWord);
    return $nWord if ($nWord ne $word && $normalize{$nWord}); # 正規化できた!
  }
  warn "$word が正規化できませんでした";
  return $word;
}

#
# 引数のファイルに "edit_" をつけたファイルに変換した結果を出力する
#
sub csvIO {
  my($csv) = @_;
  my($wcsv) = $csv;
  $wcsv =~ s@(.*/|^)@edit_$1@;
  print "$wcsv\n";
  open(CSV, $csv) or die "$csv ファイル[R]が開けません";
  open(CSVW, ">$wcsv") or die "$wcsv ファイル[W]が開けません";
  while (my $line = <CSV>) {
    my(@cols) = split(',', $line);
    $cols[$targetColumn] = normalization($cols[$targetColumn]) if $#cols > $targetColumn;
    my($nline) = join(',', @cols);
    print CSVW "$nline";
  }
  close(CSV);
  close(CSVW);
}

my @csvs = @ARGV;
my $normalizeFile = shift @csvs;
die "第一ファイルが指定されていません" unless $normalizeFile;
die "csvファイルが指定されていません" if $#csvs < 0;

#
# 第一引数の正規化名称ファイル取り込む
#
open(F, $normalizeFile) or die "$normalizeFile がひらけません";
while (<F>) {
  chomp;
  $normalize{$_}++;
}
close(F);
# 重複チェック
foreach my $name (keys(%normalize)) {
  warn "$name が重複しています" if $normalize{$name} > 1;
}

# ファイル処理
while ($_ = shift @csvs) {
  csvIO($_);
}


