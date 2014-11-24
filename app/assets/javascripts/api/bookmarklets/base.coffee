html = document.getElementsByTagName('html')[0]

iframe = document.createElement('iframe')
iframe.id = "planit-iframe"
iframe.style.width = '100%'
iframe.style.zIndex = '10000'
iframe.style.position = 'absolute'
iframe.style.border = 'none'

iframe.src = "HOSTNAME/api/v1/bookmarklets/view?user_id=USER_ID&url=#{window.location.href}"
html.insertBefore(iframe, html.firstChild)