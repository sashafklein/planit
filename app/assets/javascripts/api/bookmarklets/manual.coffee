((e, a, g, h, f, c, b, d) ->
  if not (f = e.jQuery) or g > f.fn.jquery or h(f)
    c = a.createElement("script")
    c.type = "text/javascript"
    c.src = "http://ajax.googleapis.com/ajax/libs/jquery/" + g + "/jquery.min.js"
    c.onload = c.onreadystatechange = ->
      if not b and (not (d = @readyState) or d is "loaded" or d is "complete")
        h (f = e.jQuery).noConflict(1), b = 1
        f(c).remove()
      return

    document.body.appendChild( c )
  return
) window, document, "1.3.2", ($, L) ->

  path = window.location.href

  IMG_PATH = 'http://localhost:3000/assets/'
  r_STYLES = '
  #planit_dropdown { 
    visibility:hidden;
    position:fixed;
    height: 75px;
    width: 100%; 
    top: 0px;
    left: 0px;
    background: #fff;
    -webkit-box-shadow:0px 0px 10px rgba(0,0,0,0.4);
    -moz-box-shadow:0px 0px 10px rgba(0,0,0,0.4);
    -o-box-shadow:0px 0px 10px rgba(0,0,0,0.4);
    box-shadow:0px 0px 10px rgba(0,0,0,0.4);
    z-index:2147483644;
    font-family: open sans, avenir, calibri !important;
    -webkit-transition: top 3s ease-in-out;
    -moz-transition: top 3s ease-in-out;
    -o-transition: top 3s ease-in-out;
    transition: top 3s ease-in-out;
  }
  #planit_close_btn { 
    width: 15px;
    height: 15px;
    background: #ccc;
    position: fixed;
    top: 8px;
    right: 3px;
    border: #ddd solid 1px;
    border-bottom: #999 solid 1px;
    font-size: 10px;
    line-height: 13px;
    text-align: center;
    -webkit-border-radius: 2px;
    -moz-border-radius: 2px;
    -o-border-radius: 2px;
    border-radius: 2px;
    cursor: pointer;
  }
  #planit_topper { 
    width: 100%;
    height: 5px;
    background: #152678;
  }
  #planit_wrapper { 
    margin: 0 auto;
    min-width: 200px;
    max-width: 1060px;
    padding: 0 10px;
    height: 70px;
    overflow: hidden;
  }
  #planit_logo { 
    height: 70px;
    float: left;
  }
  #planit_logo img { 
    margin: 10px 0;
  }
  #planit_logo_name { 
    height: 70px;
    margin-left: 10px;
    float: left;
  }
  #planit_dropdown_title { 
    height: 70px;
    margin-left: 10px;
    float: left;
    line-height: 70px;
    font-size: 21px;
    color: rgba(248,56,96,1);
  }
  #planit_logo_name img { 
    margin: 10px 0;
  }
  #planit_inputs { 
    height: 70px;
    float:right;
    line-height: 70px;
  }
  .planit_input { 
    padding: 5px 8px;
    border:1px solid #a4a4a4;
    border-bottom: 1px solid #fff;
    -webkit-border-radius: 3px;
    -moz-border-radius: 3px;
    -o-border-radius: 3px;
    border-radius: 3px;
    -webkit-box-shadow: 0px 1px 0px #a4a4a4;
    -moz-box-shadow: 0px 1px 0px #a4a4a4;
    -o-box-shadow: 0px 1px 0px #a4a4a4;
    box-shadow: 0px 1px 0px #a4a4a4;
    display: inline-block;
    font-size: 12px !important;
    font-family: open sans;
    color:black !important;
    margin: 0;
  }
  .planit_input.saved_add_note { 
    width: 150px;
    float: left;
    padding: 3px 5px;
  }
  .planit_button { 
    display: inline;
    padding: 5px 8px;
    -webkit-border-radius: 4px;
    -moz-border-radius: 4px;
    -o-border-radius: 4px;
    border-radius: 4px;
    text-align:center !important;
    font-size: 12px !important;
    font-weight:bold !important;
    text-decoration: none !important;
    -moz-transform:translate3d(0px,0px,0px);
    -o-transform:translate3d(0px,0px,0px);
    -webkit-transform:translate3d(0px,0px,0px);
    -ms-transform:translate3d(0px,0px,0px);
    transform:translate3d(0px,0px,0px);
    cursor: pointer;
  }
  .planit_button.neon { 
    color: #efd1d5 !important;
    -webkit-box-shadow: 0px 1px 0px #942633;
    -moz-box-shadow: 0px 1px 0px #942633;
    -o-box-shadow: 0px 1px 0px #942633;
    box-shadow: 0px 1px 0px #942633;
    background: rgb(238,66,86);
    background: -moz-linear-gradient(top, rgba(238,66,86,1) 0%, rgba(212,56,96,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(238,66,86,1)), color-stop(100%,rgba(212,56,96,1)));
    background: -webkit-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%);
    background: -o-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%);
    background: -ms-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%);
    background: linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%);
    border:1px solid #f58793;
    border-bottom: 1px solid #761826;
  }
  .planit_button.neon.enabled:hover { 
    background: rgb(248,56,96);
    background: -moz-linear-gradient(top, rgba(248,56,96,1) 0%, rgba(238,66,86,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(248,56,96,1)), color-stop(100%,rgba(238,66,86,1)));
    background: -webkit-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%);
    background: -o-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%);
    background: -ms-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%);
    background: linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%);
    border:1px solid #ffb0b9;
    border-bottom: 1px solid #761826;
  }
  .planit_button.neon.enabled:active { 
    background: rgb(208,46,66);
    background: -moz-linear-gradient(top, rgba(208,46,66,1) 0%, rgba(218,56,76,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(208,46,66,1)), color-stop(100%,rgba(218,56,76,1)));
    background: -webkit-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%);
    background: -o-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%);
    background: -ms-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%);
    background: linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%);
    border:1px solid #d13245;
    border-bottom: 1px solid #541119;
  }
  .planit_button.neon.enabled { 
    color: #fff !important;    
  }
  .planit_button.blue { 
    color: #98a4de !important;
    -webkit-box-shadow: 0px 1px 0px #050b28;
    -moz-box-shadow: 0px 1px 0px #050b28;
    -o-box-shadow: 0px 1px 0px #050b28;
    box-shadow: 0px 1px 0px #050b28;
    background: rgb(28,48,147);
    background: -moz-linear-gradient(top, rgba(28,48,147,1) 0%, rgba(14,30,113,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(28,48,147,1)), color-stop(100%,rgba(14,30,113,1)));
    background: -webkit-linear-gradient(top, rgba(28,48,147,1) 0%,rgba(14,30,113,1) 100%);
    background: -o-linear-gradient(top, rgba(28,48,147,1) 0%,rgba(14,30,113,1) 100%);
    background: -ms-linear-gradient(top, rgba(28,48,147,1) 0%,rgba(14,30,113,1) 100%);
    background: linear-gradient(top, rgba(28,48,147,1) 0%,rgba(14,30,113,1) 100%);
    border:1px solid #4659b6;
    border-bottom: 1px solid #050b28;
  }
  .planit_button.blue.enabled:hover { 
    background: rgb(40,60,165);
    background: -moz-linear-gradient(top, rgba(40,60,165,1) 0%, rgba(28,48,147,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(40,60,165,1)), color-stop(100%,rgba(28,48,147,1)));
    background: -webkit-linear-gradient(top, rgba(40,60,165,1) 0%,rgba(28,48,147,1) 100%);
    background: -o-linear-gradient(top, rgba(40,60,165,1) 0%,rgba(28,48,147,1) 100%);
    background: -ms-linear-gradient(top, rgba(40,60,165,1) 0%,rgba(28,48,147,1) 100%);
    background: linear-gradient(top, rgba(40,60,165,1) 0%,rgba(28,48,147,1) 100%);
    border:1px solid #98a4de;
    border-bottom: 1px solid #222e6e;
  }
  .planit_button.blue.enabled:active { 
    background: rgb(12,35,130);
    background: -moz-linear-gradient(top, rgba(12,35,130,1) 0%, rgba(15,30,140,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(12,35,130,1)), color-stop(100%,rgba(15,30,140,1)));
    background: -webkit-linear-gradient(top, rgba(12,35,130,1) 0%,rgba(15,30,140,1) 100%);
    background: -o-linear-gradient(top, rgba(12,35,130,1) 0%,rgba(15,30,140,1) 100%);
    background: -ms-linear-gradient(top, rgba(12,35,130,1) 0%,rgba(15,30,140,1) 100%);
    background: linear-gradient(top, rgba(12,35,130,1) 0%,rgba(15,30,140,1) 100%);
    border:1px solid #3d51b4;
    border-bottom: 1px solid #0e1641;
  }
  .planit_button.blue.enabled { 
    color: #fff !important;    
  }
  .planit_button.white { 
    color: #aaa !important;
    -webkit-box-shadow: 0px 1px 0px #777;
    -moz-box-shadow: 0px 1px 0px #777;
    -o-box-shadow: 0px 1px 0px #777;
    box-shadow: 0px 1px 0px #777;
    background: rgb(230,230,230);
    background: -moz-linear-gradient(top, rgba(230,230,230,1) 0%, rgba(220,220,220,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(230,230,230,1)), color-stop(100%,rgba(220,220,220,1)));
    background: -webkit-linear-gradient(top, rgba(230,230,230,1) 0%,rgba(220,220,220,1) 100%);
    background: -o-linear-gradient(top, rgba(230,230,230,1) 0%,rgba(220,220,220,1) 100%);
    background: -ms-linear-gradient(top, rgba(230,230,230,1) 0%,rgba(220,220,220,1) 100%);
    background: linear-gradient(top, rgba(230,230,230,1) 0%,rgba(220,220,220,1) 100%);
    border:1px solid #ffffff;
    border-bottom: 1px solid #999999;
  }
  .planit_button.white.enabled:hover { 
    background: rgb(248,56,96);
    background: -moz-linear-gradient(top, rgba(250,250,250,1) 0%, rgba(230,230,230,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(250,250,250,1)), color-stop(100%,rgba(230,230,230,1)));
    background: -webkit-linear-gradient(top, rgba(250,250,250,1) 0%,rgba(230,230,230,1) 100%);
    background: -o-linear-gradient(top, rgba(250,250,250,1) 0%,rgba(230,230,230,1) 100%);
    background: -ms-linear-gradient(top, rgba(250,250,250,1) 0%,rgba(230,230,230,1) 100%);
    background: linear-gradient(top, rgba(250,250,250,1) 0%,rgba(230,230,230,1) 100%);
    border:1px solid #ffffff;
    border-bottom: 1px solid #aaaaaa;
  }
  .planit_button.white.enabled:active { 
    background: rgb(208,46,66);
    background: -moz-linear-gradient(top, rgba(210,210,210,1) 0%, rgba(220,220,220,1) 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(210,210,210,1)), color-stop(100%,rgba(220,220,220,1)));
    background: -webkit-linear-gradient(top, rgba(210,210,210,1) 0%,rgba(220,220,220,1) 100%);
    background: -o-linear-gradient(top, rgba(210,210,210,1) 0%,rgba(220,220,220,1) 100%);
    background: -ms-linear-gradient(top, rgba(210,210,210,1) 0%,rgba(220,220,220,1) 100%);
    background: linear-gradient(top, rgba(210,210,210,1) 0%,rgba(220,220,220,1) 100%);
    border:1px solid #ccc;
    border-bottom: 1px solid #999;
  }
  .planit_button.white.enabled { 
    color: #000 !important;    
  }
  .planit_button.right {
    position: absolute;
    right: 10px;
  }
  .planit_button.left {
  }

  .centered {
    margin: auto 0;
  }

  #planit_saved_msg { 
    font-family: open sans, avenir, calibri !important;
    visibility: visible;
    position: fixed;
    top: 22px;
    right: 25px;
    padding: 10px;
    text-align: center;
    font-size: 12px;
    line-height: 13px;
    background: rgba(248,56,96,1);
    border-bottom: #a30 solid 1px;
    -webkit-border-radius: 4px;
    -moz-border-radius: 4px;
    -o-border-radius: 4px;
    border-radius: 4px;
    overflow: hidden;
    z-index: 2147483646;
    color: #fff;
    -webkit-transition: top 3s ease-in-out;
    -moz-transition: top 3s ease-in-out;
    -o-transition: top 3s ease-in-out;
    transition: top 3s ease-in-out;
    -webkit-box-shadow:0px 20px 20px rgba(0,0,0,0.4);
    -moz-box-shadow:0px 20px 20px rgba(0,0,0,0.4);
    -o-box-shadow:0px 20px 20px rgba(0,0,0,0.4);
    box-shadow:0px 20px 20px rgba(0,0,0,0.4);
  }
  #planit_saved_msg img {
    border: 0;
  }
  .planit_saved_demo_title {
    font-weight: bold;
    text-align: center;
    width: 180px;
    color: #000;
    margin: 0px;
    border: 0px;
    padding: 8px 0;
  }
  .planit_saved_demo_details {
    text-align: left;
    padding: 0;
    width: 180px;
    color: #000;
    background: #fff;
    margin: 0px;
    border: 0px;
  }
  .planit_saved_demo_title:hover {
    background: #ccc;
    cursor: text;
  }
  .planit_saved_demo_details:hover {
    background: #ccc;
    cursor: text;
  }
  .planit_saved_link { 
    text-decoration: none;
    color: #fff !important;
  }
  #planit_saved_logo { 
    height: 38px;
    margin: -5px 0 0 0;
    position: fixed;
    top: 12px;
    right: 18px;
    z-index: 2147483647;
  }
  #planit_saved_logo img { 
    border: 0;
  }
  #planit_saved_demo {
    display: block;
    margin: 10px 0 0 0;
    background-color: #fff;
    border: 1px solid #c4c7ca;
    border-bottom-color: #b7babe;
    padding: 0.75em 0.75em 0.9em;
    position: relative;
    text-align: left;
    -webkit-border-radius: 0.25em;
    -moz-border-radius: 0.25em;
    border-radius: 0.25em;
    -webkit-box-shadow: #ecedee 0 -0.1875em 0 inset,rgba(0,0,0,0.04) 0 0.11111em 0;
    -moz-box-shadow: #ecedee 0 -0.1875em 0 inset,rgba(0,0,0,0.04) 0 0.11111em 0;
    box-shadow: #ecedee 0 -0.1875em 0 inset,rgba(0,0,0,0.04) 0 0.11111em 0;
  }
  #planit_saved_add_note { 
    margin: 10px 0 10px 0;
    width: 180px;
  }
  .add_another {
    visibility:visible;
    position:fixed;
    height: 70px;
    width: 100%; 
    top: 5px;
    left: 0px;
    z-index:2147483645;
    font-family: open sans, avenir, calibri !important;
    -webkit-transition: top 3s ease-in-out;
    -moz-transition: top 3s ease-in-out;
    -o-transition: top 3s ease-in-out;
    transition: top 3s ease-in-out;
    background: rgb(255,255,255);
    background: rgba(255,255,255,0.9);
    text-align: center;
    line-height: 70px;
  }
  .add_another_button_wrap { 
    height: 70px;
    margin-left: 52px;
    float: left;
  }
  .add_another_arrow { 
    height: 70px;
    margin-right: 145px;
    float: right;
  }
  .breakline {}
  .img_container {
    width: 180px;
    height: 120px;
    margin: 0;
    overflow: hidden; 
  }

  '

  IFNOLOCALE = ', City State & Country'

  # MANUAL ADD DROP DOWN
  s_HTML = '
  <div id="planit_dropdown">
  <div id="planit_close_btn">x</div>
  <div id="planit_topper"></div>  
  <div id="planit_wrapper">
    <div id="planit_logo">
      <img src="' + IMG_PATH + 'logo_only_black.png" width="42" height="50">
    </div>
    <div id="planit_logo_name">
      <img src="' + IMG_PATH + 'logo_name_only_black.png" width="86" height="50">
    </div>
    <div id="planit_dropdown_title">
      Keeper
    </div>
    <div id="planit_inputs">
      <form id="planit_form">
        <input class="planit_input" id="planit_name" placeholder="Desitination Name">
        <input class="planit_input" id="planit_address" placeholder="Address' + IFNOLOCALE + '">
        <input class="planit_input" id="planit_notes" placeholder="Add Notes">
        <a target="_blank" class="planit_button neon disabled" id="planit_click_save">SAVE</a>
      </form>
    </div>
  </div>
  </div>
  '

  # ADD ANOTHER OVERLAY
  t_HTML = '
  <div class="add_another">
    <div id="planit_wrapper">
      <div class="add_another_arrow">
        ->
      </div>
      <div class="add_another_button_wrap">
        <a target="_blank" class="planit_button blue enabled" id="planit_click_add_another">ADD ANOTHER ITEM ON THIS PAGE</a>
      </div>
    </div>
  </div>
  '

  # SAVED POPUP
  u_HTML = '
    <div id="planit_saved_logo">
      <img src="' + IMG_PATH + 'logo_only_black.png" width="32" height="38">
    </div>
    <div id="planit_saved_msg">
      Saved to <a href="#" class="planit_saved_link">your <strong>planit</strong></a>!
      <form id="planit_saved_form">
      <div id="planit_saved_demo">
        <div class="img_container"><img src="https://irs3.4sqi.net/img/general/180x120/6026_ruM6F73gjApA1zufxgbscViPgkbrP5HaYi_L8gti6hY.jpg" width="180" height="120"></div>
        <div class="breakline"><input class="planit_saved_demo_title" id="planit_name" value="Dwelltime"></div>
        <div class="breakline"><input class="planit_saved_demo_details" id="planit_address" value="364 Broadway, Cambridge, MA 02139"></div>
      </div>
      <div id="planit_saved_add_note">
        <input class="planit_input saved_add_note" id="planit_name" placeholder="Note-to-Self?">
        <a target="_blank" class="planit_button white right disabled" id="planit_add_note">ADD</a>
      </div>
      </form>
    </div>
  '

  v = ''
  z = document.createElement("div")
  z.innerHTML = "<style id=\"PLANIT_STYLE\">" + r_STYLES + "</style>" + s_HTML
  document.body.appendChild( z )
  z_NEWLAYER = document.getElementById("planit_dropdown")
  z_NEWLAYER.style.visibility = "visible" 
  z_CLOSE = document.getElementById("planit_close_btn")
  z_CLOSE.onclick = ->
    z_NEWLAYER.parentNode.removeChild z_NEWLAYER  if z_NEWLAYER
  z_SAVEBTN = document.getElementById("planit_click_save")
  z_SAVEBTN.onclick = ->
    z2 = document.createElement("div")
    z2.innerHTML = t_HTML
    document.body.appendChild( z2 )
    z3 = document.createElement("div")
    z3.innerHTML = u_HTML
    document.body.appendChild( z3 )
    # z_NEWLAYER.parentNode.removeChild z_NEWLAYER  if z_NEWLAYER
    z_MSGLAYER = document.getElementById("planit_saved_msg")
    z_MSGLOGO = document.getElementById("planit_saved_logo")
    # z_MSGLAYER.onclick = ->
    #   z_MSGLAYER.parentNode.removeChild z_MSGLAYER  if z_MSGLAYER    
    #   z_MSGLOGO.parentNode.removeChild z_MSGLOGO  if z_MSGLOGO    
    # setTimeout (->
    #   z_MSGLAYER.parentNode.removeChild z_MSGLAYER  if z_MSGLAYER    
    #   z_MSGLOGO.parentNode.removeChild z_MSGLOGO  if z_MSGLOGO    
    # ), 5000
  # setTimeout (->
  #   z_NEWLAYER.style.visibility = "hidden"
  # ), 5050
    # disappear = true
    # DISAPPEARING_ACT = ->
    #   if disappear
    #     setTimeout (->
    #       z_NEWLAYER.style.visibility = "hidden"
    #     ), 5050
