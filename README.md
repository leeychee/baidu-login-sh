使用 bash 登录百度 baidu
==============================================

# 使用

通过配置环境变量来配置需要登录的用户名(BAIDU_USERNAME)和密码(BAIDU_PASSWORD)，并
调用 bdlogin 函数进行登录。如果成功，将得到 err_no=0。

如果登录成功，在后续的使用过程中使用 curl -b $BAIDU_COOKIE -c $BAIDU_COOKIE $url
即可。

可以通过配置 `_DEBUG="on"` 的环境变量，打印 Cookie 信息

```
BAIDU_USERNAME="Username"
BAIDU_PASSWORD="password"
source ./login.sh

```

# 问题

目前不完善，经常会提示 257，要求输入验证码。

碰到的几个错误代码

| err_no         | 解释                              |
| -------------- | --------------------------------- |
| 0              | 登录成功                          |
| 4              | 密码错误                          |
| 257            | 需要验证码                        |
| 10023          | 缺少 Cookie                       |

