alert("X")
// (window, document, "1.3.2", function($, L) {
//   var IMG_PATH, path, r_STYLES, s_HTML, t_HMTL, v, z, z_CLOSE, z_MSGLAYER, z_NEWLAYER;
//   path = window.location.href;
//   IMG_PATH = 'http://localhost:3000/assets/';
//   r_STYLES = '#planit_dropdown { visibility:hidden; position:fixed; height: 75px; width: 100%; top: 0px; left: 0px; background: #fff; -webkit-box-shadow:0px 0px 10px rgba(0,0,0,0.4); -moz-box-shadow:0px 0px 10px rgba(0,0,0,0.4); -o-box-shadow:0px 0px 10px rgba(0,0,0,0.4); box-shadow:0px 0px 10px rgba(0,0,0,0.4); z-index:2147483646; font-family: open sans !important; -webkit-transition: top 3s ease-in-out; -moz-transition: top 3s ease-in-out; -o-transition: top 3s ease-in-out; transition: top 3s ease-in-out; } #planit_close_btn { width: 15px; height: 15px; background: #ccc; position: fixed; top: 8px; right: 3px; border: #ddd solid 1px; border-bottom: #999 solid 1px; font-size: 10px; line-height: 13px; text-align: center; -webkit-border-radius: 2px; -moz-border-radius: 2px; -o-border-radius: 2px; border-radius: 2px; cursor: pointer; } #planit_topper { width: 100%; height: 5px; background: #152678; } #planit_wrapper { margin: 0 auto; min-width: 200px; max-width: 1060px; padding: 0 10px; height: 70px; overflow: hidden; } #planit_logo { height: 70px; float: left; } #planit_logo img { margin: 10px 0; } #planit_logo_name { height: 70px; margin-left: 10px; float: left; } #planit_logo_name img { margin: 10px 0; } #planit_saved_msg { visibility: hidden; position: fixed; top: 22px; right: 45%; padding: 10px; font-size: 12px; line-height: 13px; background: #eeeeee; -webkit-border-radius: 4px; -moz-border-radius: 4px; -o-border-radius: 4px; border-radius: 4px; overflow: hidden; z-index: 2147483647; color: #000000; -webkit-transition: top 3s ease-in-out; -moz-transition: top 3s ease-in-out; -o-transition: top 3s ease-in-out; transition: top 3s ease-in-out; } #planit_saved_msg a { text-decoration: none; color: #000000 !important; } #planit_inputs { height: 70px; float:right; line-height: 70px; } .planit_input { padding: 5px 8px; border:1px solid #a4a4a4; display: inline-block; font-size: 12px !important; font-family: open sans; color:black !important; } .planit_button { padding: 5px 8px; border:1px solid #a4a4a4; border-bottom: 1px solid #761826; -webkit-box-shadow: 0px 1px 0px white; -moz-box-shadow: 0px 1px 0px white; -o-box-shadow: 0px 1px 0px white; box-shadow: 0px 1px 0px white; -webkit-border-radius: 4px; -moz-border-radius: 4px; -o-border-radius: 4px; border-radius: 4px; text-align:center !important; font-size: 12px !important; color: white !important; font-weight:bold !important; background: rgb(238,66,86); background: -moz-linear-gradient(top, rgba(238,66,86,1) 0%, rgba(212,56,96,1) 100%); background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(238,66,86,1)), color-stop(100%,rgba(212,56,96,1))); background: -webkit-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%); background: -o-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%); background: -ms-linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%); background: linear-gradient(top, rgba(238,66,86,1) 0%,rgba(212,56,96,1) 100%); text-decoration: none !important; -moz-transform:translate3d(0px,0px,0px); -o-transform:translate3d(0px,0px,0px); -webkit-transform:translate3d(0px,0px,0px); -ms-transform:translate3d(0px,0px,0px); transform:translate3d(0px,0px,0px); cursor: pointer; } .planit_button:hover { background: rgb(248,56,96); background: -moz-linear-gradient(top, rgba(248,56,96,1) 0%, rgba(238,66,86,1) 100%); background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(248,56,96,1)), color-stop(100%,rgba(238,66,86,1))); background: -webkit-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%); background: -o-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%); background: -ms-linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%); background: linear-gradient(top, rgba(248,56,96,1) 0%,rgba(238,66,86,1) 100%); } .planit_button:active { background: rgb(208,46,66); background: -moz-linear-gradient(top, rgba(208,46,66,1) 0%, rgba(218,56,76,1) 100%); background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(208,46,66,1)), color-stop(100%,rgba(218,56,76,1))); background: -webkit-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%); background: -o-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%); background: -ms-linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%); background: linear-gradient(top, rgba(208,46,66,1) 0%,rgba(218,56,76,1) 100%); }';
//   s_HTML = '<div id="planit_dropdown"> <div id="planit_close_btn">x</div> <div id="planit_topper"></div> <div id="planit_wrapper"> <div id="planit_logo"> <img src="' + IMG_PATH + 'logo_only_black.png" width="42" height="50"> </div> <div id="planit_logo_name"> <img src="' + IMG_PATH + 'logo_name_only_black.png" width="86" height="50"> </div> <div id="planit_saved_msg"> Saved to <a href="#">your <strong>planit</strong></a>! </div> <div id="planit_inputs"> <form id="planit_form"> <input class="planit_input" id="planit_notes" placeholder="Add Notes"> <a target="_blank" class="planit_button" id="planit_click_save">SAVE</a> </form> </div> </div> </div>';
//   t_HMTL = '<div class="more_popdown" style="top: 55px; left: -25px;"> <div class="arrow"></div> <ul><li class="all selected" val="all"><a href="#">All Items</a></li><li class="articles" val="articles"><a href="#">Articles</a></li><li class="videos" val="videos"><a href="#">Videos</a></li><li class="images last" val="images"><a href="#">Images</a></li> </ul> </div>';
//   v = '';
//   z = document.createElement("div");
//   z.innerHTML = "<style id=\"PLANIT_STYLE\">" + r_STYLES + "</style>" + s_HTML;
//   document.body.appendChild(z);
//   z_NEWLAYER = document.getElementById("planit_dropdown");
//   z_NEWLAYER.style.visibility = "visible";
//   z_MSGLAYER = document.getElementById("planit_saved_msg");
//   z_CLOSE = document.getElementById("planit_close_btn");
//   z_CLOSE.onclick = function() {
//     if (z_NEWLAYER) {
//       return z_NEWLAYER.parentNode.removeChild(z_NEWLAYER);
//     }
//   };
//   setTimeout((function() {
//     return z_MSGLAYER.style.visibility = "visible";
//   }), 300);
//   setTimeout((function() {
//     return z_MSGLAYER.style.visibility = "hidden";
//   }), 5000);
//   return setTimeout((function() {
//     return z_NEWLAYER.style.visibility = "hidden";
//   }), 5050);
// });
