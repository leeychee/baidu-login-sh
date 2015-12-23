#!/bin/bash

function bdlogin() {
	if [[ -z $BAIDU_USERNAME ]] || [[ -z $BAIDU_PASSWORD ]] || [[ -z $BAIDU_TPL ]];then
		echo "请配置环境变量: BAIDU_USERNAME, BAIDU_PASSWORD, BAIDU_TPL"
		echo "BAIDU_TPL 可以为 'bddoctor', 'netdisk'"
		return 1
	fi
	username=$BAIDU_USERNAME
	password=$BAIDU_PASSWORD
	# 百度医生
	if [[ $BAIDU_TPL == 'bddoctor' ]]; then
		tpl='bddoctor'
		url='http://yi.baidu.com/pc'
		url_jump='http://yi.baidu.com/v3Jump.html'
	# 百度网盘
	elif [[ $BAIDU_TPL == 'netdisk' ]]; then
		tpl='netdisk'
		subpro='netdisk_web'
		url='http://pan.baidu.com/#list/path=%2F'
		url_jump='http://pan.baidu.com/res/static/thirdparty/pass_v3_jump.html'
	else
		tpl='mn'
		url='https://www.baidu.com/'
		url_jump='https://www.baidu.com/cache/user/html/v3Jump.html'
	fi
	[[ $_DEBUG == "on" ]] && echo $username $password $tpl

	baidu_cookie=$(mktemp) # ~/.baidu/cookie
	# baidu_cookie='/tmp/cookie'

	# 首次登录获取 BAIDUID
	curl -s -c $baidu_cookie 'http://www.baidu.com/' > /dev/null
	[[ $_DEBUG == "on" ]] && cat $baidu_cookie

	# 模拟打开页面
	curl -s -b $baidu_cookie -c $baidu_cookie "$url" 1>/dev/null 2>&1
	[[ $_DEBUG == "on" ]] && cat $baidu_cookie

	# 获取应用的 token
	token=$(curl -s -b $baidu_cookie -c $baidu_cookie "https://passport.baidu.com/v2/api/?getapi&tpl=$tpl" | grep _token | grep -o "'[^']*'" | tr -d "\'");
	[[ $_DEBUG == "on" ]] && echo -e "\nTOKEN=$token"; 
	[[ $_DEBUG == "on" ]] && cat $baidu_cookie;

	# 登录
	ppui_logintime=$(date +%s%N | awk '{print substr($0, 0, 6)}')
	tt=$(date +%s%N | awk '{print substr($0, 0, 14)}')

	err_no=$(curl -s -b $baidu_cookie -c $baidu_cookie 'https://passport.baidu.com/v2/api/?login'  \
	-H "Origin: $(echo url | egrep -o 'https?://[^/]*')"  \
	-H 'Host: passport.baidu.com' \
	-H 'Pragma: no-cache' \
	-H 'Accept-Encoding: gzip, deflate'  \
	-H 'Accept-Language: zh-CN,zh;q=0.8'  \
	-H 'Upgrade-Insecure-Requests: 1'  \
	-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.35 Safari/537.36'  \
	-H 'Content-Type: application/x-www-form-urlencoded'  \
	-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'  \
	-H 'Cache-Control: max-age=0'  \
	-H "Referer: $url"  \
	-H 'Connection: keep-alive' \
	--data "staticpage=$url_jump& \
	charset=UTF-8& \
	token=$token& \
	tpl=$tpl& \
	subpro=$subpro& \
	apiver=v3& \
	tt=$tt& \
	codestring=& \
	safeflg=0& \
	u=$url& \
	isPhone=false& \
	detect=1& \
	gid=$(uuid | tr [a-z] [A-Z])& \
	quick_user=0& \
	logintype=basicLogin& \
	logLoginType=pc_loginBasic& \
	idc=& \
	loginmerge=true& \
	splogin=rate& \
	username=$username& \
	password=$password& \
	verifycode=& \
	mem_pass=on& \
	ppui_logintime=$ppui_logintime& \
	countrycode=& \
	callback=parent.bd__pcbs__7vinwr" \
	--compressed | grep -o 'err.*=[0-9]*' | grep -o [0-9]*)
	[[ $_DEBUG == "on" ]] && cat $baidu_cookie

	if [[ $err_no == 0 ]];then
		export BAIDU_COOKIE=$baidu_cookie
		[[ $_DEBUG == "on" ]] && echo '登录成功，请使用 curl -b $BAIDU_COOKIE url'
		return 0
	else
		[[ $_DEBUG == "on" ]] && echo "登录失败,err_no=$err_no"
		return $err_no 
	fi
}

# Test
[[ -z $BAIDU_USERNAME ]] && BAIDU_USERNAME="Username"
[[ -z $BAIDU_PASSWORD ]] && BAIDU_PASSWORD="Password"
[[ -z $BAIDU_TPL ]] && BAIDU_TPL=mn
bdlogin
