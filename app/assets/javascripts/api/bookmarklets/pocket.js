if(thePKT_BM)thePKT_BM.save();
else{try{if(ISRIL_H){}}catch(e){ISRIL_H=0}try{if(ISRIL_TEST){}}catch(e){ISRIL_TEST=false}try{if(PKT_D){}}catch(e){PKT_D="getpocket.com"}var PKT_BM_OVERLAY=function(a){this.inited=false;
this.saveTagsCallback=a.saveTagsCallback};
PKT_BM_OVERLAY.prototype={create:function(){var a=document.getElementById("PKT_BM_STYLE");

if(a)a.parentNode.removeChild(a);
var b=document.getElementById("PKT_BM_OVERLAY");
if(b)b.parentNode.removeChild(b);
var c=window.innerWidth/screen.availWidth;
if(c<1)c=1;
var d=window.navigator.userAgent;
this.isMobile=d.match(/iPad/i)||d.match(/iPhone/i);
this.isFirefox=d.match(/firefox/i)!=null;
var e=(this.isMobile?60:80)*c;
var f=(this.isMobile?18:20)*c;
var g=this.isMobile?e*.95:e;
var h=this.isMobile?"normal":"bold";
var i=6*c;
var j=17*c;
var k=80*c;
var l=30*c;
var m=30*c;
var n=1*c;
if(n<1)n=1;
var o=19*c;
var p=25*c;
var q=15*c;
this.shadowHeight=20;
var r="     #PKT_BM_OVERLAY     {       visibility:hidden;
        position:fixed;
       top:0px;
        left:0px;
       width:100%;
       height:"+e+"px;
       -webkit-box-shadow:0px 0px "+this.shadowHeight+"px rgba(0,0,0,0.4);
       -moz-box-shadow:0px 0px "+this.shadowHeight+"px rgba(0,0,0,0.4);
        -o-box-shadow:0px 0px "+this.shadowHeight+"px rgba(0,0,0,0.4);
        box-shadow:0px 0px "+this.shadowHeight+"px rgba(0,0,0,0.4);
       z-index:999999999;
        background: rgb(239,239,239);
       background: -moz-linear-gradient(top, rgba(239,239,239,0.98) 0%, rgba(253,253,253,0.98) 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(239,239,239,0.98)), color-stop(100%,rgba(253,253,253,0.98)));
        background: -webkit-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        background: -o-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
       background: -ms-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        background: linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#efefef', endColorstr='#fdfdfd',GradientType=0 );
        border-bottom:1px solid white;
        font-size:"+f+"px !important;
       font-family:HelveticaNeue,Helvetica,Arial !important;
       line-height:"+g+"px !important;
       text-align: left;
       color: #4b4b4b !important;
        -webkit-transform:translate3d(0px,0px,0px);
     }           #PKT_BM_RAINBOWDASH     {       width: 100%;
        height: 6%;
     }           #PKT_BM_RAINBOWDASH div     {       float: left;
        width: 25%;
       height: 100%;
     }           #PKT_BM_OVERLAY_LOGO      {       display: block;
       width: 200px;
       height: 100%;
       text-indent: -789em;
        float: left;
        background: url(http://"+PKT_D+"/i/v3/pocket_logo.png) left center no-repeat;
     }     .PKT_mobile #PKT_BM_OVERLAY_LOGO      {       display: none;
      }     .PKT_desktop #PKT_BM_OVERLAY_LABEL      {       position: absolute;
       top: 0px;
       left: 0px;
        text-align:center;
        width: 100%;
        padding: 0px;
       font-weight: "+h+";
     }           #PKT_BM_OVERLAY_WRAPPER     {       padding-left:7%;
        padding-right: 7%;
        height: 100%;
     }           .PKT_BM_BTN     {       float: right;
       margin-top: 22px;
       margin-left: 20px;
        width: "+k+"px;
       height: "+l+"px;
        line-height: "+m+"px;
       visibility:hidden;
        border:"+n+"px solid #a4a4a4;
       text-shadow: 0px "+n+"px 0px rgba(255, 255, 255, 0.7);
        -webkit-box-shadow: 0px "+n+"px 0px white;
        -moz-box-shadow: 0px "+n+"px 0px white;
       -o-box-shadow: 0px "+n+"px 0px white;
       box-shadow: 0px "+n+"px 0px white;
        -webkit-border-radius: "+i+"px;
       -moz-border-radius: "+i+"px;
        -o-border-radius: "+i+"px;
        border-radius: "+i+"px;
       text-align:center !important;
       font-size:0.7em !important;
       color:black !important;
       font-weight:bold !important;
        background: rgb(250,213,64);
        background: -moz-linear-gradient(top, rgba(250,213,64,1) 0%, rgba(251,182,74,1) 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(250,213,64,1)), color-stop(100%,rgba(251,182,74,1)));
        background: -webkit-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);
        background: -o-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);
       background: -ms-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);
        background: linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fad540', endColorstr='#fbb64a',GradientType=0 );
        text-decoration: none !important;
       -moz-transform:translate3d(0px,0px,0px);
        -o-transform:translate3d(0px,0px,0px);
        -webkit-transform:translate3d(0px,0px,0px);
     }     .PKT_BM_BTN:hover     {       background: rgb(251,182,74);
        background: -moz-linear-gradient(top, rgba(251,182,74,1) 0%, rgba(250,213,64,1) 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(251,182,74,1)), color-stop(100%,rgba(250,213,64,1)));
        background: -webkit-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        background: -o-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
       background: -ms-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        background: linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fbb64a', endColorstr='#fad540',GradientType=0 );
      }     .PKT_BM_BTN.gray      {       background: #f9f9f9;
        background: -moz-linear-gradient(top, #f9f9f9 0%, #ebecec 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f9f9f9), color-stop(100%,#ebecec));
        background: -webkit-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        background: -o-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
       background: -ms-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        background: linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f9f9f9', endColorstr='#ebecec',GradientType=0 );
      }     .PKT_BM_BTN.gray:hover      {       background: #ebecec;
        background: -moz-linear-gradient(top, #ebecec 0%, #f9f9f9 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebecec), color-stop(100%,#f9f9f9));
        background: -webkit-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        background: -o-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
       background: -ms-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        background: linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ebecec', endColorstr='#f9f9f9',GradientType=0 );
      }     .PKT_BM_BTN.green     {       background: #81dbd6;
        background: -moz-linear-gradient(top, #81dbd6 0%, #74c5c1 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));
        background: -webkit-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        background: -o-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
       background: -ms-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        background: linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#81dbd6', endColorstr='#74c5c1',GradientType=0 );
      }     .PKT_BM_BTN.green:hover     {       background: #74c5c1;
        background: -moz-linear-gradient(bottom, #81dbd6 0%, #74c5c1 100%);
       background: -webkit-gradient(linear, left bottom, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));
       background: -webkit-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       background: -o-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
        background: -ms-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       background: linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#74c5c1', endColorstr='#81dbd6',GradientType=0 );
      }     .PKT_BM_BTN div     {       display: block;
     }     #PKT_FORM     {       height: 100%;
       display: block !important;
        visibility: visible !important;
       margin: 0px !important;
       padding: 0px !important;
      }     .PKT_mobile #PKT_FORM{        position: absolute;
       top: 0px;
       right: 0.5em;
       width: 86%;
     }     .PKT_mobile #PKT_BM_BTN{        margin-top: "+j+"px !important;
     }     .PKT_mobile #PKT_BM_VL_BTN{       display: none;
      }     #PKT_BM_OVERLAY_INPUT     {       display: none;
      }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_INPUT     {       position: absolute !important;
        display: block !important;
        top: "+o+"px !important;
        left: 0% !important;
        width: 57%;
       height: "+p+"px !important;
       border: "+n+"px solid #c9c9c9 !important;
       margin: 0px !important;
       padding: 0px 0px 0px 5px !important;
        font-size: "+q+"px !important;
        color: #666666 !important;
        background: white !important;
               /* overrides */       font-family: Arial !important;
        -webkit-box-shadow: none !important;
        -moz-box-shadow: none !important;
       box-shadow: none !important;
        -webkit-border-radius: 0px !important;
        -moz-border-radius: 0px !important;
       border-radius: 0px !important;
      }     .PKT_desktop #PKT_BM_OVERLAY_INPUT      {       float: right;
       margin-top: 24px !important;
        position: static !important;
        width: 300px;
     }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_LABEL     {       display: none;
      }     ";
if(this.browserPrefix()=="O"){
  r+="          .PKT_desktop #PKT_BM_OVERLAY_LABEL          {           z-index: 18000;
         }         #PKT_BM_OVERLAY_WRAPPER         {           position: relative;
         }         #PKT_FORM         {           position: absolute;
           right: 7%;
            z-index: 20000;
         }       "}
         var s='     <div id="PKT_BM_OVERLAY">       <div id="PKT_BM_RAINBOWDASH">         <div style="background-color: #83EDB8;
"></div>          <div style="background-color: #50BCB6;
"></div>          <div style="background-color: #EE4256;
"></div>          <div style="background-color: #FCB64B;
"></div>        </div>        <div id="PKT_BM_OVERLAY_WRAPPER" class="PKT_'+(this.isMobile?"mobile":"desktop")+'">          <a id="PKT_BM_OVERLAY_LOGO" href="http://'+PKT_D+'" target="_blank">Pocket</a>          <div id="PKT_BM_OVERLAY_LABEL"></div>         <form id="PKT_FORM">            <a id="PKT_BM_VL_BTN" class="PKT_BM_BTN" target="_blank" href=""></a>           <a id="PKT_BM_BTN" class="PKT_BM_BTN" target="_blank" href=""></a>            <input type="text" id="PKT_BM_OVERLAY_INPUT" /><input type="submit" value="Submit" name="submit" style="position:absolute !important;
left:-789em !important;
"/>         </form>       </div>      </div>      ';
var t=document.createElement("div");
t.innerHTML='<style id="PKT_BM_STYLE">'+r+"</style>"+s;
document.body.appendChild(t);

try{if(document.location.host.match("twitter."))document.getElementsByClassName("topbar")[0].style.position="absolute"}catch(u){}
var v=this;
setTimeout(function(){v.show()},30);
if(!this.isMobile&&window.addEventListener){this.windowResizeHandler={handleEvent:function(a){v.updateVisibleElements()}};
window.addEventListener("resize",this.windowResizeHandler)}this.updateVisibleElements()},updateVisibleElements:function(){if(this.isMobile)return;
var a=window.innerWidth;
var b=this.isTagsEditorOpen();
var c=document.getElementById("PKT_BM_OVERLAY_LOGO");
c.style.display=a<850&&b?"none":"block";
if(b){var d=document.getElementById("PKT_BM_OVERLAY_INPUT");
var e=650;
var f=850;
if(a<=e){var g=document.getElementById("PKT_BM_BTN");
var h=g.offsetWidth+parseInt(document.defaultView.getComputedStyle(g,null).marginLeft);
var i=a*.85-h-5;
if(this.isFirefox){i=i-20}d.style.width=i+"px"}else if(a>e&&a<=f){var g=document.getElementById("PKT_BM_BTN");
var h=g.offsetWidth+parseInt(document.defaultView.getComputedStyle(g,null).marginLeft);
var j=document.getElementById("PKT_BM_VL_BTN");
var k=j.offsetWidth+parseInt(document.defaultView.getComputedStyle(j,null).marginLeft);
var i=a*.8-h-k-5;
d.style.width=""}else{d.style.width=""}}var j=document.getElementById("PKT_BM_VL_BTN");
j.style.display=a<e&&b?"none":"block"},displayMessage:function(a){this.toggleClass(document.getElementById("PKT_BM_OVERLAY_WRAPPER"),"PKT_SHOW_INPUT",false);
document.getElementById("PKT_BM_OVERLAY_LABEL").innerHTML=a},showButton:function(a,b,c,d){var e=document.getElementById("PKT_BM_BTN");
e.style.visibility=a?"visible":"hidden";
if(a){e.innerHTML=a;
if(!b)e.removeAttribute("href");
else e.href=b;
if(c){e.onclick=function(){c()}}this.toggleClass(e,"gray",d)}},showViewListButton:function(a,b,c){if(this.isMobile)return;
var d=document.getElementById("PKT_BM_VL_BTN");
d.style.visibility=a?"visible":"hidden";
var e=document.getElementById("PKT_BM_BTN");
if(a){d.innerHTML=a;
e.style.right="13%";
if(!b)d.removeAttribute("href");
else d.href=b;
if(c){d.onclick=function(){c()}}this.toggleClass(d,"green",true)}else{if(e.style.removeProperty){e.style.removeProperty("right")}else{e.style.removeAttribute("right")}}},getReadyToHide:function(){var a=this;
clearTimeout(this.hideTO);
this.hideTO=setTimeout(function(){a.hide()},3e3)},cancelPendingHide:function(){clearTimeout(this.hideTO);
this.hideTO=undefined},show:function(){this.hidesOnClick=false;
this.cancelPendingHide();
var a=document.getElementById("PKT_BM_OVERLAY");
a.style[this.browserPrefix()+"Transform"]="translate3d(0px,"+(0-a.offsetHeight-this.shadowHeight)+"px,0px)";
a.style.visibility="visible";
var b=this;
a.onclick=function(){if(b.hidesOnClick)b.hide()};
setTimeout(function(){var c=b.browserPrefix();
a.style[c+"Transition"]="-"+c+"-transform 0.3s ease-out";
a.style[c+"Transform"]="translate3d(0px,0px,0px)"},100)},hide:function(){var a=document.getElementById("PKT_BM_OVERLAY");
a.style[this.browserPrefix()+"Transform"]="translate3d(0px,"+(0-a.offsetHeight-this.shadowHeight)+"px,0px)";
setTimeout(function(){a.style.visibility="hidden";
a.parentNode.removeChild(a)},300);
if(this.windowResizeHandler&&window.removeEventListener){window.removeEventListener("resize",this.windowResizeHandler)}},wasSaved:function(){var a=this;
this.displayMessage("Page Saved!");
this.showButton("Add Tags",null,function(){a.openTagsEditor()},true);
this.showViewListButton("View List","http://"+PKT_D+"/a/?src=bookmarklet");
this.getReadyToHide();
this.updateVisibleElements()},isTagsEditorOpen:function(){return this.isShowingTagsEditor===true},openTagsEditor:function(){this.isShowingTagsEditor=true;
this.cancelPendingHide();
var a=this;
var b=this.isMobile?"Add tags (tag1, tag2)":"Add Tags (separated by commas)";
this.showTextField(b);
var c=function(){if(a.textField.value.length>0)a.showButton("Save",null,function(){a.saveTags()});
else a.showButton("Close",null,function(){a.hide()},true)};
c();
var d=document.getElementById("PKT_FORM");
d.onsubmit=function(){a.saveTags();
return false};
this.textField.onkeyup=c;
this.updateVisibleElements()},saveTags:function(){this.isShowingTagsEditor=true;
var a=[];
var b={};
var c;
var d=this.trim(document.getElementById("PKT_BM_OVERLAY_INPUT").value);
if(d&&d.length){var e=d.split(",");
for(var f=0;
f<e.length;
f++){c=this.trim(e[f]).toLowerCase();
if(c.length&&!b[c]){a.push(c);
b[c]=c}}}if(!a||!a.length){alert("Please enter at least one tag");
return}this.updateVisibleElements();
this.saveTagsCallback(a)},showTextField:function(a){this.toggleClass(document.getElementById("PKT_BM_OVERLAY_WRAPPER"),"PKT_SHOW_INPUT",true);
this.textField=document.getElementById("PKT_BM_OVERLAY_INPUT");
this.textField.placeholder=a;
this.updateVisibleElements()},toggleClass:function(a,b,c){if(!a)return;
if(c&&!a.className.match(b))a.className+=" "+b;
else if(!c&&a.className.match(b))a.className=a.className.replace(b,"")},browserPrefix:function(){if(this._prefix)return this._prefix;
var a=document.createElement("div");
var b=["Webkit","Moz","MS","O"];
for(var c in b){if(a.style[b[c]+"Transition"]!==undefined){this._prefix=b[c];
return this._prefix}}},trim:function(a){var a=a.replace(/^\s\s*/,""),b=/\s/,c=a.length;
while(b.test(a.charAt(--c)));
return a.slice(0,c+1)}};

var PKT_BM=function(){};
PKT_BM.prototype={init:function(){if(this.inited)return;
var a=this;
this.overlay=new PKT_BM_OVERLAY({saveTagsCallback:function(b){a.saveTags(b)}});
this.inited=true},save:function(){var a=this;
this.overlay.create();
if(ISRIL_TEST){this.overlay.displayMessage("Test successful!");
this.overlay.getReadyToHide()}else{if(!ISRIL_H){this.edit()}else{this.overlay.displayMessage("Saving to Pocket...");
this.sendRequest({u:document.location.href,t:document.title.replace(/^\s\s*/,"").replace(/\s\s*$/,"")},function(){a.overlay.wasSaved()})}}},saveTags:function(a){var b=this;
this.overlay.displayMessage("Saving Tags&#8230;
");
this.overlay.showButton(false);
this.overlay.showViewListButton(false);
this.sendRequest({u:document.location.href,tags:JSON.stringify(a)},function(){b.overlay.displayMessage("Tags Saved!");
b.overlay.showViewListButton("View List","http://"+PKT_D+"/a/?r=bookmarklet");
b.overlay.getReadyToHide()})},sendRequest:function(a,b){var c=function(){if(f.checkImage()&&b)b()};
var d="";
if(a){for(var e in a){d+="&"+e+"="+encodeURIComponent(a[e])}}this.img=new Image;
this.img.onload=c;
this.img.src="http://"+PKT_D+"/v2/r.gif?v=1&h="+ISRIL_H+"&rand="+Math.random()+d;
document.body.appendChild(this.img);
var f=this;
this.imageInt=setInterval(c,250)},checkImage:function(){if(this.img&&this.img.complete){clearInterval(this.imageInt);
this.complete=true;
var a=this.img.width;
var b=a==1;
if(!b){if(a==2){this.overlay.hidesOnClick=true;
this.overlay.displayMessage("Please login.");
this.overlay.showButton("Login",this.overlay.isMobile?"http://"+PKT_D+"/bl/login/?url=http://"+PKT_D+"/bloggedin":"http://"+PKT_D+"/l")}else if(a==3){this.overlay.displayMessage("Error saving");
this.overlay.showButton("Get Help","http://help.getpocket.com/customer/portal/articles/480486-bookmarklet-error---wrong-account");
this.overlay.showViewListButton("View List","http://"+PKT_D+"/a/?r=bookmarklet")}}this.img.style.display="none";
return b}}};
var thePKT_BM=new PKT_BM;
thePKT_BM.init();
thePKT_BM.save()}void 0



  / #PKT_BM_OVERLAY      {       visibility:hidden;        position:fixed;       top:0px;        left:0px;       width:100%;       height:80px;        -webkit-box-shadow:0px 0px 20px rgba(0,0,0,0.4);        -moz-box-shadow:0px 0px 20px rgba(0,0,0,0.4);       -o-box-shadow:0px 0px 20px rgba(0,0,0,0.4);       box-shadow:0px 0px 20px rgba(0,0,0,0.4);        z-index:2147483647;       background: rgb(239,239,239);       background: -moz-linear-gradient(top, rgba(239,239,239,0.98) 0%, rgba(253,253,253,0.98) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(239,239,239,0.98)), color-stop(100%,rgba(253,253,253,0.98)));        background: -webkit-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        background: -o-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);       background: -ms-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        background: linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#efefef', endColorstr='#fdfdfd',GradientType=0 );        border-bottom:1px solid white;        font-size:20px !important;        font-family:HelveticaNeue,Helvetica,Arial !important;       line-height:80px !important;        text-align: left;       color: #4b4b4b !important;        -webkit-transform:translate3d(0px,0px,0px);     }     #PKT_BM_OVERLAY { visibility: hidden; }     #PKT_BM_OVERLAY.PKT_VISIBLE { visibility: visible; }      #PKT_BM_OVERLAY.PKT_VISIBLE .PKT_BM_BTN.PKT_VISIBLE { visibility: visible; }            #PKT_BM_RAINBOWDASH     {       width: 100%;        height: 6%;     }           #PKT_BM_RAINBOWDASH div     {       float: left;        width: 25%;       height: 100%;     }           #PKT_BM_OVERLAY_LOGO      {       display: block;       width: 200px;       height: 100%;       text-indent: -789em;        float: left;        background: url(https://getpocket.com/i/v3/pocket_logo.png) left center no-repeat;      }     .PKT_mobile #PKT_BM_OVERLAY_LOGO      {       display: none;      }     .PKT_desktop #PKT_BM_OVERLAY_LABEL      {       position: absolute;       top: 0px;       left: 0px;        text-align:center;        width: 100%;        padding: 0px;       font-weight: bold;      }           #PKT_BM_OVERLAY_WRAPPER     {       padding-left:7%;        padding-right: 7%;        height: 100%;     }           .PKT_BM_BTN     {       float: right;       margin-top: 22px;       margin-left: 20px;        width: 80px;        height: 30px;       line-height: 30px;        visibility:hidden;        border:1px solid #a4a4a4;       text-shadow: 0px 1px 0px rgba(255, 255, 255, 0.7);        -webkit-box-shadow: 0px 1px 0px white;        -moz-box-shadow: 0px 1px 0px white;       -o-box-shadow: 0px 1px 0px white;       box-shadow: 0px 1px 0px white;        -webkit-border-radius: 6px;       -moz-border-radius: 6px;        -o-border-radius: 6px;        border-radius: 6px;       text-align:center !important;       font-size:0.7em !important;       color:black !important;       font-weight:bold !important;        background: rgb(250,213,64);        background: -moz-linear-gradient(top, rgba(250,213,64,1) 0%, rgba(251,182,74,1) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(250,213,64,1)), color-stop(100%,rgba(251,182,74,1)));        background: -webkit-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        background: -o-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);       background: -ms-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        background: linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fad540', endColorstr='#fbb64a',GradientType=0 );        text-decoration: none !important;       -moz-transform:translate3d(0px,0px,0px);        -o-transform:translate3d(0px,0px,0px);        -webkit-transform:translate3d(0px,0px,0px);       -ms-transform:translate3d(0px,0px,0px);       transform:translate3d(0px,0px,0px);     }     .PKT_BM_BTN:hover     {       background: rgb(251,182,74);        background: -moz-linear-gradient(top, rgba(251,182,74,1) 0%, rgba(250,213,64,1) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(251,182,74,1)), color-stop(100%,rgba(250,213,64,1)));        background: -webkit-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        background: -o-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);       background: -ms-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        background: linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fbb64a', endColorstr='#fad540',GradientType=0 );      }     .PKT_BM_BTN.gray      {       background: #f9f9f9;        background: -moz-linear-gradient(top, #f9f9f9 0%, #ebecec 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f9f9f9), color-stop(100%,#ebecec));        background: -webkit-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        background: -o-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);       background: -ms-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        background: linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f9f9f9', endColorstr='#ebecec',GradientType=0 );      }     .PKT_BM_BTN.gray:hover      {       background: #ebecec;        background: -moz-linear-gradient(top, #ebecec 0%, #f9f9f9 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebecec), color-stop(100%,#f9f9f9));        background: -webkit-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        background: -o-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);       background: -ms-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        background: linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ebecec', endColorstr='#f9f9f9',GradientType=0 );      }     .PKT_BM_BTN.green     {       background: #81dbd6;        background: -moz-linear-gradient(top, #81dbd6 0%, #74c5c1 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));        background: -webkit-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        background: -o-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);       background: -ms-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        background: linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#81dbd6', endColorstr='#74c5c1',GradientType=0 );      }     .PKT_BM_BTN.green:hover     {       background: #74c5c1;        background: -moz-linear-gradient(bottom, #81dbd6 0%, #74c5c1 100%);       background: -webkit-gradient(linear, left bottom, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));       background: -webkit-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       background: -o-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);        background: -ms-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       background: linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#74c5c1', endColorstr='#81dbd6',GradientType=0 );      }     .PKT_BM_BTN div     {       display: block;     }     #PKT_FORM     {       height: 100%;       display: block !important;        visibility: visible !important;       margin: 0px !important;       padding: 0px !important;      }     .PKT_mobile #PKT_FORM{        position: absolute;       top: 0px;       right: 0.5em;       width: 86%;     }     .PKT_mobile #PKT_BM_BTN{        margin-top: 17px !important;      }     .PKT_mobile #PKT_BM_VL_BTN{       display: none;      }     #PKT_BM_OVERLAY_INPUT     {       display: none;      }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_INPUT     {       position: absolute !important;        display: block !important;        top: 19px !important;       left: 0% !important;        width: 57%;       height: 25px !important;        border: 1px solid #c9c9c9 !important;       margin: 0px !important;       padding: 0px 0px 0px 5px !important;        font-size: 15px !important;       color: #666666 !important;        background: white !important;               /* overrides */       font-family: Arial !important;        -webkit-box-shadow: none !important;        -moz-box-shadow: none !important;       box-shadow: none !important;        -webkit-border-radius: 0px !important;        -moz-border-radius: 0px !important;       border-radius: 0px !important;      }     .PKT_desktop #PKT_BM_OVERLAY_INPUT      {       float: right;       margin-top: 24px !important;        position: static !important;        width: 300px;     }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_LABEL     {       display: none;      }

/ .pkt_ext_container.pkt_ext_container_flexbox.pkt_ext_container_active.pkt_ext_container_detailactive
/   .pkt_ext_initload
/     .pkt_ext_loadingspinner
/       %div
/   .pkt_ext_finalstatedetail
/     %h2
/   .pkt_ext_detail
/     %a.pkt_ext_close{:href => "#", :title => "Close"} Close
/     %h2 Page Saved
/     %nav.pkt_ext_item_actions.pkt_ext_cf
/       %ul
/         %li
/           %a.pkt_ext_openpocket{:href => "http://www.getpocket.com/a", :target => "_blank"} Open Pocket
/         %li.pkt_ext_actions_separator
/         %li
/           %a.pkt_ext_removeitem{:href => "#"} Remove Page
/     %p.pkt_ext_edit_msg
/     %ul.pkt_ext_rainbow_separator.pkt_ext_cf
/       %li.pkt_ext_color_1
/       %li.pkt_ext_color_2
/       %li.pkt_ext_color_3
/       %li.pkt_ext_color_4
/     .pkt_ext_tag_detail.pkt_ext_cf
/       .pkt_ext_tag_input_wrapper
/         .pkt_ext_tag_input_blocker
/         %ul.token-input-list
/           %li.token-input-input-token
/             %input#token-input-{:autocomplete => "off", :placeholder => "Add Tags", :style => "outline: none; width: 200px;", :type => "text"}/
/             %tester{:style => "position: absolute; top: -9999px; left: -9999px; width: auto; font-size: 14px; font-family: proxima-nova, 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 400; letter-spacing: 0px; white-space: nowrap;"}
/         %input.pkt_ext_tag_input{:placeholder => "Add Tags", :style => "display: none;", :type => "text"}/
/       %a.pkt_ext_btn.pkt_ext_btn_disabled{:href => "#"} Save
/ %form#PKT_FORM
/   %a#PKT_BM_VL_BTN.PKT_BM_BTN.PKT_VISIBLE.green{:href => "http://getpocket.com/a/?src=bookmarklet", :style => "display: block;", :target => "_blank"} View List
/   %a#PKT_BM_BTN.PKT_BM_BTN.PKT_VISIBLE.gray{:style => "right: 13%;", :target => "_blank"} Close
/   %input#PKT_BM_OVERLAY_INPUT{:placeholder => "Add Tags (separated by commas)", :style => "", :type => "text"}/
/   %input{:name => "submit", :style => "position:absolute !important;left:-789em !important;", :type => "submit", :value => "Submit"}/

/ %style{ id: "PKT_BM_STYLE"}
/   #PKT_BM_OVERLAY     {       visibility:hidden;        position:fixed;       top:0px;        left:0px;       width:100%;       height:80px;        -webkit-box-shadow:0px 0px 20px rgba(0,0,0,0.4);        -moz-box-shadow:0px 0px 20px rgba(0,0,0,0.4);       -o-box-shadow:0px 0px 20px rgba(0,0,0,0.4);       box-shadow:0px 0px 20px rgba(0,0,0,0.4);        z-index:2147483647;       background: rgb(239,239,239);       background: -moz-linear-gradient(top, rgba(239,239,239,0.98) 0%, rgba(253,253,253,0.98) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(239,239,239,0.98)), color-stop(100%,rgba(253,253,253,0.98)));        background: -webkit-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        background: -o-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);       background: -ms-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        background: linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#efefef', endColorstr='#fdfdfd',GradientType=0 );        border-bottom:1px solid white;        font-size:20px !important;        font-family:HelveticaNeue,Helvetica,Arial !important;       line-height:80px !important;        text-align: left;       color: #4b4b4b !important;        -webkit-transform:translate3d(0px,0px,0px);     }     #PKT_BM_OVERLAY { visibility: hidden; }     #PKT_BM_OVERLAY.PKT_VISIBLE { visibility: visible; }      #PKT_BM_OVERLAY.PKT_VISIBLE .PKT_BM_BTN.PKT_VISIBLE { visibility: visible; }            #PKT_BM_RAINBOWDASH     {       width: 100%;        height: 6%;     }           #PKT_BM_RAINBOWDASH div     {       float: left;        width: 25%;       height: 100%;     }           #PKT_BM_OVERLAY_LOGO      {       display: block;       width: 200px;       height: 100%;       text-indent: -789em;        float: left;        background: url(https://getpocket.com/i/v3/pocket_logo.png) left center no-repeat;      }     .PKT_mobile #PKT_BM_OVERLAY_LOGO      {       display: none;      }     .PKT_desktop #PKT_BM_OVERLAY_LABEL      {       position: absolute;       top: 0px;       left: 0px;        text-align:center;        width: 100%;        padding: 0px;       font-weight: bold;      }           #PKT_BM_OVERLAY_WRAPPER     {       padding-left:7%;        padding-right: 7%;        height: 100%;     }           .PKT_BM_BTN     {       float: right;       margin-top: 22px;       margin-left: 20px;        width: 80px;        height: 30px;       line-height: 30px;        visibility:hidden;        border:1px solid #a4a4a4;       text-shadow: 0px 1px 0px rgba(255, 255, 255, 0.7);        -webkit-box-shadow: 0px 1px 0px white;        -moz-box-shadow: 0px 1px 0px white;       -o-box-shadow: 0px 1px 0px white;       box-shadow: 0px 1px 0px white;        -webkit-border-radius: 6px;       -moz-border-radius: 6px;        -o-border-radius: 6px;        border-radius: 6px;       text-align:center !important;       font-size:0.7em !important;       color:black !important;       font-weight:bold !important;        background: rgb(250,213,64);        background: -moz-linear-gradient(top, rgba(250,213,64,1) 0%, rgba(251,182,74,1) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(250,213,64,1)), color-stop(100%,rgba(251,182,74,1)));        background: -webkit-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        background: -o-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);       background: -ms-linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        background: linear-gradient(top, rgba(250,213,64,1) 0%,rgba(251,182,74,1) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fad540', endColorstr='#fbb64a',GradientType=0 );        text-decoration: none !important;       -moz-transform:translate3d(0px,0px,0px);        -o-transform:translate3d(0px,0px,0px);        -webkit-transform:translate3d(0px,0px,0px);       -ms-transform:translate3d(0px,0px,0px);       transform:translate3d(0px,0px,0px);     }     .PKT_BM_BTN:hover     {       background: rgb(251,182,74);        background: -moz-linear-gradient(top, rgba(251,182,74,1) 0%, rgba(250,213,64,1) 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(251,182,74,1)), color-stop(100%,rgba(250,213,64,1)));        background: -webkit-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        background: -o-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);       background: -ms-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        background: linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fbb64a', endColorstr='#fad540',GradientType=0 );      }     .PKT_BM_BTN.gray      {       background: #f9f9f9;        background: -moz-linear-gradient(top, #f9f9f9 0%, #ebecec 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f9f9f9), color-stop(100%,#ebecec));        background: -webkit-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        background: -o-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);       background: -ms-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        background: linear-gradient(top, #f9f9f9 0%,#ebecec 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f9f9f9', endColorstr='#ebecec',GradientType=0 );      }     .PKT_BM_BTN.gray:hover      {       background: #ebecec;        background: -moz-linear-gradient(top, #ebecec 0%, #f9f9f9 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebecec), color-stop(100%,#f9f9f9));        background: -webkit-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        background: -o-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);       background: -ms-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        background: linear-gradient(top, #ebecec 0%,#f9f9f9 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ebecec', endColorstr='#f9f9f9',GradientType=0 );      }     .PKT_BM_BTN.green     {       background: #81dbd6;        background: -moz-linear-gradient(top, #81dbd6 0%, #74c5c1 100%);        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));        background: -webkit-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        background: -o-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);       background: -ms-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        background: linear-gradient(top, #81dbd6 0%,#74c5c1 100%);        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#81dbd6', endColorstr='#74c5c1',GradientType=0 );      }     .PKT_BM_BTN.green:hover     {       background: #74c5c1;        background: -moz-linear-gradient(bottom, #81dbd6 0%, #74c5c1 100%);       background: -webkit-gradient(linear, left bottom, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));       background: -webkit-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       background: -o-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);        background: -ms-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       background: linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);       filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#74c5c1', endColorstr='#81dbd6',GradientType=0 );      }     .PKT_BM_BTN div     {       display: block;     }     #PKT_FORM     {       height: 100%;       display: block !important;        visibility: visible !important;       margin: 0px !important;       padding: 0px !important;      }     .PKT_mobile #PKT_FORM{        position: absolute;       top: 0px;       right: 0.5em;       width: 86%;     }     .PKT_mobile #PKT_BM_BTN{        margin-top: 17px !important;      }     .PKT_mobile #PKT_BM_VL_BTN{       display: none;      }     #PKT_BM_OVERLAY_INPUT     {       display: none;      }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_INPUT     {       position: absolute !important;        display: block !important;        top: 19px !important;       left: 0% !important;        width: 57%;       height: 25px !important;        border: 1px solid #c9c9c9 !important;       margin: 0px !important;       padding: 0px 0px 0px 5px !important;        font-size: 15px !important;       color: #666666 !important;        background: white !important;               /* overrides */       font-family: Arial !important;        -webkit-box-shadow: none !important;        -moz-box-shadow: none !important;       box-shadow: none !important;        -webkit-border-radius: 0px !important;        -moz-border-radius: 0px !important;       border-radius: 0px !important;      }     .PKT_desktop #PKT_BM_OVERLAY_INPUT      {       float: right;       margin-top: 24px !important;        position: static !important;        width: 300px;     }     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_LABEL     {       display: none;      }     
  
