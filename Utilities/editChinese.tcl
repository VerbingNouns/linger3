#!/bin/sh
# the next line restarts using wish \
exec wish "$0" -- "$@"

set Encoding big5

#-- cim: Chinese input manager
proc cim {w args} {
  array set opt {-font {Courier 12}}
  array set opt $args
  global cim_to
  set cim_to $opt(-to)
  set f $opt(-font)
  frame $w
  entry $w.entry    -width 7            -font $f -textvar cim_entry
  label $w.favorite -width 3 -bg yellow -font $f -textvar cim_favorite
  label $w.menu     -width 30           -font $f -textvar cim_menu
  pack $w.entry $w.favorite -side left
  pack $w.menu -fill x -expand 1
  bind $w.entry <Up> "cim_scroll $w.menu -10;break"
  bind $w.entry <Down> "cim_scroll $w.menu  10;break"
  bind $w.entry <KeyRelease> [list cim_handle $w.menu %A]
  bind $w.entry <Escape> {focus $cim_to}
  bind $w.entry <Return> {$cim_to insert insert \n}
  after 100 [list bind $cim_to  <Escape> [list focus $w.entry]]
  set ::cim_menu "Welcome to taiku 0.1!"
  focus $w.entry
  set w
}

proc cim_handle {w key} {
  global cim_entry cim_favorite cim_menu cim_to cim_startgb cim_tbl cim_fav
  if {![regexp {[a-zü0-9.\b ]} $key]} {
    if {$key != "\x0D"} {$cim_to insert insert $key}
    set cim_favorite ""
    return
  } elseif {$key==" "} {
    $cim_to insert insert $cim_favorite
    set cim_entry ""; set cim_menu ""; set cim_favorite ""
    return
  } elseif {[regexp {[0-9]} $key]} {
    if {!$key} {incr key 10}
    set char [string index $cim_menu [expr {$key*3-2}]]
    $cim_to insert insert $char
    if {![info exist cim_fav([string range $cim_entry 0 end-1])]} {
      set cim_fav([string range $cim_entry 0 end-1]) [uc2dgb $char]
    }
    set cim_entry ""; set cim_menu ""; set cim_favorite ""
    return
  }
  if [info exist cim_tbl($cim_entry)] {cim_showMenu $w $cim_tbl($cim_entry)}
  set trimmed [string trim $cim_entry]
  if [info exist cim_fav($trimmed)] {
    set cim_favorite [dgb2uc $cim_fav($trimmed)]
  } else {
    set cim_favorite [string index $cim_menu 1]
  }
}

proc cim_showMenu {w {from -}} {
  global cim_menu cim_startgb
  if {$from!="-"} {set cim_startgb $from}
  set from $cim_startgb
  set cim_menu ""
  for {set i 1} {$i<=10} {incr i} {
    if {$from%100>94} {incr from 6}
    append cim_menu "[expr $i%10][dgb2uc $from] "
    incr from
  }
  append cim_menu $cim_startgb
}

proc cim_scroll {w amount} {
  global cim_startgb
  incr cim_startgb $amount
  cim_showMenu $w
}

proc dgb2uc dlist {
  global Encoding
  set res ""
  foreach d $dlist {
    set b1 [format %c [expr {$d/100+160}]]
    set b2 [format %c [expr {$d%100+160}]]
    append res [encoding convertfrom $Encoding $b1$b2]
  }
  set res
}
 
proc uc2dgb uc {
  global Encoding
  set res ""
  foreach i [split [encoding convertto $Encoding $uc] ""] {
    scan $i %c byte
    append res [format %02d [expr {$byte-160}]]
  }
  set res
}
# Starting positions of Pinyin syllables in GB2312-80
array set cim_tbl {
  a 1601 ai 1603 an 1618 ang 1625 ao 1628
  b 1637 bai 1655 ban 1663 bang 1678 bao 1690 be 1713 ben 1728 beng 1732
  bi 1738 bian 1762 biao 1774 bie 1778 bin 1782 bing 1787 bo 1803 bu 1822
  c 1833 cai 1834 can 1844 cang 1852 cao 1857 ce 1862 ceng 1867 ch 1869 chai 1881
  chan 1884 chang 1893 chao 1912 che 1921 chen 1927 cheng 1937 chi 1952 cho 1968
  chou 1973 chu 1985 chuan 2008 chuang 2015 chui 2021 chun 2026 chuo 2033 ci 2035
  cong 2047 cou 2053 cu 2054 cuan 2058 cui 2061 cun 2069 cuo 2072
  d 2078 dai 2084 dan 2102 dang 2117 dao 2122 de 2134 deng 2137 di 2144 dian 2163
  diao 2179 die 2188 ding 2201 diu 2210 do 2211 dou 2221 du 2228 duan 2243 dui 2249
  dun 2253 duo 2262 e 2274 en 2287 er 2288
  f 2302 fan 2310 fang 2327 fei 2338 fen 2350 feng 2365 fo 2380 fou 2381 fu 2382
  g 2433 gan 2441 gang 2452 gao 2461 ge 2471 gei 2488 gen 2489 geng 2491 go 2504 gou 2519
  gu 2528 gua 2546 guai 2552 guan 2555 guang 2566 gui 2569 gun 2585 guo 2588
  h 2594 hai 2601 han 2608 hang 2628 hao 2630 he 2639 hei 2657 hen 2659
  heng 2663 hong 2668 hou 2677 hu 2684 hua 2708 huai 2717 huan 2722
  huang 2736 hui 2750 hun 2771 huo 2778
  j 2787 jia 2846 jian 2863 jiang 2909 jiao 2922 jie 2950 jin 2977
  jing 3005 jiong 3028 jiu 3030 ju 3047 juan 3072 jue 3085 jun 3089
  k 3106 kai 3110 kan 3115 kang 3121 kao 3128 ke 3132 ken 3147 ko 3113
  kou 3157 ku 3161 kua 3169 kuai 3173 kuan 3177 kuang 3179 kui 3187 kun 3204 kuo 3208
  l 3212 lai 3219 lan 3221 lang 3237 lao 3244 le 3253 leng 3266
  li 3269 lia 3309 liang 3324 liao 3335 lie 3348 lin 3353 ling 3364 liu 3379
  lo 3390 lou 3405 lu 3411 lü 3432 lua 3445 lun 3453 luo 3460
  m 3472 mai 3481 man 3487 mang 3502 mao 3508 me 3520 men 3537 meng 3540
  mi 3548 mian 3562 miao 3571 mie 3580 min 3581 ming 3587 mo 3594 mou 3617
  mu 3620 n 3635 nai 3641 nan 3647 nao 3652 ne 3656 neng 3660 ni 3661 nian 3672
  niang 3679 niao 3681 nie 3683 nin 3690 ning 3691 niu 3703 no 3707 nu 3711
  nü 3714 nuan 3715 nuo 3721 o 3722
  p 3730 pai 3736 pan 3742 pang 3750 pao 3756 pe 3762 pei 3771 peng 3773 pi 3787
  pian 3810 piao 3814 pin 3820 ping 3825 po 3834 pu 3843
  q 3858 qia 3901 qian 3903 qiang 3925 qiao 3933 qie 3948 qin 3953 qing 3964
  qiong 3978 qiu 3979 qu 3987 quan 4006 que 4017 qun 4025
  r 4027 rang 4031 rao 4036 re 4039 ren 4041 reng 4051 ri 4053 ro 4056 rou 4064
  ru 4067 ruan 4077 rui 4080 ruo 4084
  s 4086 sai 4089 san 4093 sang 4103 sao 4106 se 4110 sen 4113 sh 4115 shan 4127
  shang 4142 shao 4150 she 4163 shen 4173 sheng 4189 shi 4206 shou 4253 shu 4263
  shua 4302 shuan 4308 shuang 4310 shui 4313 shun 4318 shuo 4321 si 4325 song 4341
  sou 4349 su 4351 suan 4365 sui 4368 sun 4378 suo 4385
  t 4390 tai 4405 tan 4414 tang 4432 tao 4445 te 4456 teng 4457 ti 4461 tian 4476
  tiao 4484 tie 4489 ting 4492 to 4508 tou 4521 tu 4525 tuan 4536 tui 4538 tun 4544 tuo 4547
  w 4558 wai 4564 wan 4567 wang 4584 we 4594 wen 4633 weng 4643 wo 4646 wu 4655
  x 4684 xia 4725 xian 4738 xiang 4764 xiao 4784 xie 4808 xin 4829
  xing 4839 xiong 4854 xiu 4861 xu 4870 xuan 4889 xue 4905 xun 4911
  y 4925 yan 4941 yang 4974 yao 4991 ye 5012 yi 5027 yin 5080 ying 5102 yo 5120 you 5136
  yu 5156 yuan 5206 yue 5227 yun 5237
  z 5251 zai 5252 zan 5259 zang 5263 zao 5266 ze 5280 zen 5285 zeng 5286
  zh 5290 zhai 5310 zhan 5319 zhang 5333 zhao 5348 zhe 5358 zhen 5368
  zheng 5384 zhi 5405 zho 5448 zhou 5459 zhu 5473 zhua 5505 zhuan 5508
  zhuang 5514 zhui 5521  zhun 5508 zhuo 5509 zi 5540 zong 5555 zou 5562
  zu 5566 zua 5574 zui 5576 zun 5580 zuo 5582
}

#-- Favorites - frequent characters or words that are proposed early
array set cim_fav {
  b 1827
  d 2136
  g 2486 ge 2486 guo 2590
  h 2645
  i 5027
  l 3343
  r 4043
  s 4239
  w 4650
  z 5258 zg {5448 2590} zh 5366
  . 103
}

#-------------------------------------- end of cim
proc htm_print {w} {
  # this works only on Windows 95..ME...
  set filename [file join $::env(TEMP) taiku.html]
  set fp [open $filename w]
  puts $fp [s2html [$w get 1.0 end]]
  close $fp
  exec $::env(COMSPEC) /c start [file nativename $filename] &amp;
}

proc s2html s {
  set res ""
  foreach line [split $s \n] {
    append res <br>
    foreach c [split $line ""] {
      set uc [scan $c %c]
      append res [expr {$uc>127? "&amp;#$uc;" : $c}]
    }
  }
  set res
}

proc openFile {fn w} {
  global Encoding
  if [string length $fn] {
    $w delete 0.0 end
    set f [open $fn]
    fconfigure $f -encoding $Encoding
    while {[gets $f line] != -1} {
      $w insert end $line\n
    }
    #	foreach line [split [read $f] \n] {puts "\[$line\]"; $w insert end $line\n}
    close $f
  }
}

proc file:open {w} {
  openFile [tk_getOpenFile] $w
}

proc file:save {w} {
  global Encoding
  set fn [tk_getSaveFile]
  if [string length $fn] {
    set f [open $fn w]
    fconfigure $f -encoding $Encoding
    puts $f [$w get 1.0 end-1c]
    close $f
  }
}

##################################################################### #
#-------------------------- demo and test
if {[file tail [info script]]==[file tail $argv0]} {
  menu .menu
  . config -menu .menu
  menu .menu.file -tearoff 0
  .menu add cascade -label File -menu .menu.file
  .menu.file add command -label Open... -command {file:open .t}
  .menu.file add command -label Print   -command {htm_print .t}
  .menu.file add command -label Save... -command {file:save .t}
  .menu.file add separator
  .menu.file add command -label Exit -command exit
  pack [cim .cim -to .t] -side bottom -fill x
  pack [text .t  -font {Courier 14 bold}] -fill both -expand 1
  #set taiku [image create photo -file $::tk_library/images/tai-ku.gif]
  #.t image create 1.0 -image $taiku
  raise .
  bind . <Control-r> {exec [info nameofexecutable] $argv0 &amp;; exit}
  bind . <Control-p> {htm_print .t}
  if {$argc > 0} {openFile [lindex $argv 0] .t}
}


