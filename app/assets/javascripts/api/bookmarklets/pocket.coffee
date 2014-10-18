<div class="pkt_ext_container pkt_ext_container_flexbox pkt_ext_container_active pkt_ext_container_detailactive">
    <div class="pkt_ext_initload">
        <div class="pkt_ext_loadingspinner"><div></div></div>                    </div>
    <div class="pkt_ext_finalstatedetail">
        <h2></h2>
    </div>
    <div class="pkt_ext_detail">
        <a title="Close" class="pkt_ext_close" href="#">Close</a>                        <h2>Page Saved</h2>
        <nav class="pkt_ext_item_actions pkt_ext_cf">
            <ul>
                <li><a class="pkt_ext_openpocket" href="http://www.getpocket.com/a" target="_blank">Open Pocket</a></li>
                <li class="pkt_ext_actions_separator"></li>
                <li><a class="pkt_ext_removeitem" href="#">Remove Page</a></li>
            </ul>
        </nav>
        <p class="pkt_ext_edit_msg"></p>
        <ul class="pkt_ext_rainbow_separator pkt_ext_cf">
                            <li class="pkt_ext_color_1"></li>

                                    <li class="pkt_ext_color_2"></li>
                            <li class="pkt_ext_color_3"></li>
                            <li class="pkt_ext_color_4"></li>
                        </ul>
        <div class="pkt_ext_tag_detail pkt_ext_cf">
            <div class="pkt_ext_tag_input_wrapper">
                                <div class="pkt_ext_tag_input_blocker"></div>
                <ul class="token-input-list"><li class="token-input-input-token"><input type="text" autocomplete="off" id="token-input-" placeholder="Add Tags" style="outline: none; width: 200px;"><tester style="position: absolute; top: -9999px; left: -9999px; width: auto; font-size: 14px; font-family: proxima-nova, 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 400; letter-spacing: 0px; white-space: nowrap;"></tester></li></ul><input class="pkt_ext_tag_input" type="text" placeholder="Add Tags" style="display: none;">
            </div>
            <a href="#" class="pkt_ext_btn pkt_ext_btn_disabled">Save</a>
        </div>
    </div></div>
<form id="PKT_FORM">            <a id="PKT_BM_VL_BTN" class="PKT_BM_BTN PKT_VISIBLE green" target="_blank" href="http://getpocket.com/a/?src=bookmarklet" style="display: block;">View List</a>           <a id="PKT_BM_BTN" class="PKT_BM_BTN PKT_VISIBLE gray" target="_blank" style="right: 13%;">Close</a>            <input type="text" id="PKT_BM_OVERLAY_INPUT" placeholder="Add Tags (separated by commas)" style=""><input type="submit" value="Submit" name="submit" style="position:absolute !important;left:-789em !important;">          </form>

    #PKT_BM_OVERLAY
     {
       visibility:visible;
       position:fixed;
       top:0px;
        left:0px;
       width:100%;
       height:80px;
        -webkit-box-shadow:0px 0px 20px rgba(0,0,0,0.4);
        -moz-box-shadow:0px 0px 20px rgba(0,0,0,0.4);
       -o-box-shadow:0px 0px 20px rgba(0,0,0,0.4);
       box-shadow:0px 0px 20px rgba(0,0,0,0.4);
        z-index:2147483647;
       background: rgb(239,239,239);
       background: -moz-linear-gradient(top, rgba(239,239,239,0.98) 0%, rgba(253,253,253,0.98) 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(239,239,239,0.98)), color-stop(100%,rgba(253,253,253,0.98)));
        background: -webkit-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        background: -o-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
       background: -ms-linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        background: linear-gradient(top, rgba(239,239,239,0.98) 0%,rgba(253,253,253,0.98) 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#efefef', endColorstr='#fdfdfd',GradientType=0 );
        border-bottom:1px solid white;
        font-size:20px !important;
        font-family:HelveticaNeue,Helvetica,Arial !important;
       line-height:80px !important;
        text-align: left;
       color: #4b4b4b !important;
        -webkit-transform:translate3d(0px,0px,0px);
     }
     #PKT_BM_OVERLAY { visibility: hidden; }
     #PKT_BM_OVERLAY.PKT_VISIBLE { visibility: visible; }
      #PKT_BM_OVERLAY.PKT_VISIBLE .PKT_BM_BTN.PKT_VISIBLE { visibility: visible; }
     
       #PKT_BM_RAINBOWDASH
     {
       width: 100%;
        height: 6%;
     }
     
      #PKT_BM_RAINBOWDASH div
     {
       float: left;
        width: 25%;
       height: 100%;
     }
     
      #PKT_BM_OVERLAY_LOGO
      {
       display: block;
       width: 200px;
       height: 100%;
       text-indent: -789em;
        float: left;
        background: url(https://getpocket.com/i/v3/pocket_logo.png) left center no-repeat;
      }
     .PKT_mobile #PKT_BM_OVERLAY_LOGO
      {
       display: none;
      }
     .PKT_desktop #PKT_BM_OVERLAY_LABEL
      {
       position: absolute;
       top: 0px;
       left: 0px;
        text-align:center;
        width: 100%;
        padding: 0px;
       font-weight: bold;
      }
     
      #PKT_BM_OVERLAY_WRAPPER
     {
       padding-left:7%;
        padding-right: 7%;
        height: 100%;
     }
     
      .PKT_BM_BTN
     {
       float: right;
       margin-top: 22px;
       margin-left: 20px;
        width: 80px;
        height: 30px;
       line-height: 30px;
        visibility:hidden;
        border:1px solid #a4a4a4;
       text-shadow: 0px 1px 0px rgba(255, 255, 255, 0.7);
        -webkit-box-shadow: 0px 1px 0px white;
        -moz-box-shadow: 0px 1px 0px white;
       -o-box-shadow: 0px 1px 0px white;
       box-shadow: 0px 1px 0px white;
        -webkit-border-radius: 6px;
       -moz-border-radius: 6px;
        -o-border-radius: 6px;
        border-radius: 6px;
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
       -ms-transform:translate3d(0px,0px,0px);
       transform:translate3d(0px,0px,0px);
     }
     .PKT_BM_BTN:hover
     {
       background: rgb(251,182,74);
        background: -moz-linear-gradient(top, rgba(251,182,74,1) 0%, rgba(250,213,64,1) 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(251,182,74,1)), color-stop(100%,rgba(250,213,64,1)));
        background: -webkit-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        background: -o-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
       background: -ms-linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        background: linear-gradient(top, rgba(251,182,74,1) 0%,rgba(250,213,64,1) 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fbb64a', endColorstr='#fad540',GradientType=0 );
      }
     .PKT_BM_BTN.gray
      {
       background: #f9f9f9;
        background: -moz-linear-gradient(top, #f9f9f9 0%, #ebecec 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f9f9f9), color-stop(100%,#ebecec));
        background: -webkit-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        background: -o-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
       background: -ms-linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        background: linear-gradient(top, #f9f9f9 0%,#ebecec 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f9f9f9', endColorstr='#ebecec',GradientType=0 );
      }
     .PKT_BM_BTN.gray:hover
      {
       background: #ebecec;
        background: -moz-linear-gradient(top, #ebecec 0%, #f9f9f9 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebecec), color-stop(100%,#f9f9f9));
        background: -webkit-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        background: -o-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
       background: -ms-linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        background: linear-gradient(top, #ebecec 0%,#f9f9f9 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ebecec', endColorstr='#f9f9f9',GradientType=0 );
      }
     .PKT_BM_BTN.green
     {
       background: #81dbd6;
        background: -moz-linear-gradient(top, #81dbd6 0%, #74c5c1 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));
        background: -webkit-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        background: -o-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
       background: -ms-linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        background: linear-gradient(top, #81dbd6 0%,#74c5c1 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#81dbd6', endColorstr='#74c5c1',GradientType=0 );
      }
     .PKT_BM_BTN.green:hover
     {
       background: #74c5c1;
        background: -moz-linear-gradient(bottom, #81dbd6 0%, #74c5c1 100%);
       background: -webkit-gradient(linear, left bottom, left bottom, color-stop(0%,#81dbd6), color-stop(100%,#74c5c1));
       background: -webkit-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       background: -o-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
        background: -ms-linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       background: linear-gradient(bottom, #81dbd6 0%,#74c5c1 100%);
       filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#74c5c1', endColorstr='#81dbd6',GradientType=0 );
      }
     .PKT_BM_BTN div
     {
       display: block;
     }
     #PKT_FORM
     {
       height: 100%;
       display: block !important;
        visibility: visible !important;
       margin: 0px !important;
       padding: 0px !important;
      }
     .PKT_mobile #PKT_FORM{
        position: absolute;
       top: 0px;
       right: 0.5em;
       width: 86%;
     }
     .PKT_mobile #PKT_BM_BTN{
        margin-top: 17px !important;
      }
     .PKT_mobile #PKT_BM_VL_BTN{
       display: none;
      }
     #PKT_BM_OVERLAY_INPUT
     {
       display: none;
      }
     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_INPUT
     {
       position: absolute !important;
        display: block !important;
        top: 19px !important;
       left: 0% !important;
        width: 57%;
       height: 25px !important;
        border: 1px solid #c9c9c9 !important;
       margin: 0px !important;
       padding: 0px 0px 0px 5px !important;
        font-size: 15px !important;
       color: #666666 !important;
        background: white !important;
     
     
     /* overrides */
       font-family: Arial !important;
        -webkit-box-shadow: none !important;
        -moz-box-shadow: none !important;
       box-shadow: none !important;
        -webkit-border-radius: 0px !important;
        -moz-border-radius: 0px !important;
       border-radius: 0px !important;
      }
     .PKT_desktop #PKT_BM_OVERLAY_INPUT
      {
       float: right;
       margin-top: 24px !important;
        position: static !important;
        width: 300px;
     }
     .PKT_SHOW_INPUT #PKT_BM_OVERLAY_LABEL
     {
       display: none;
      }     


#pagenav_tagfilter.dropSelector.titleItem.titleSelector.innerpopover-active{:style => "display: block;"}
  %a.all.hint-item
    %span.itemtext All Items
    %span.edittag
    %span.deletetag
  .popover-new.popover-new-bottomleft.popover-active{:style => "top: 47px; left: -221px;"}
    .arrow
    %ul.scroll_mode
      %li{:val => "all"}
        %a{:href => "/a/queue/grid/"} All Items
      %li{:val => "untagged"}
        %a{:href => "/a/queue/grid/_untagged_"} Untagged Items
      %li{:val => "api"}
        %a{:href => "/a/queue/grid/api"} api
      %li{:val => "arrow"}
        %a{:href => "/a/queue/grid/arrow"} arrow
      %li{:val => "copyright"}
        %a{:href => "/a/queue/grid/copyright"} copyright
      %li{:val => "crew"}
        %a{:href => "/a/queue/grid/crew"} crew
      %li{:val => "ee"}
        %a{:href => "/a/queue/grid/ee"} ee
      %li{:val => "ef"}
        %a{:href => "/a/queue/grid/ef"} ef
      %li{:val => "eff"}
        %a{:href => "/a/queue/grid/eff"} eff
      %li{:val => "exif"}
        %a{:href => "/a/queue/grid/exif"} exif
      %li{:val => "f"}
        %a{:href => "/a/queue/grid/f"} f
      %li{:val => "fec"}
        %a{:href => "/a/queue/grid/fec"} fec
      %li{:val => "fff"}
        %a{:href => "/a/queue/grid/fff"} fff
      %li{:val => "ffff"}
        %a{:href => "/a/queue/grid/ffff"} ffff
      %li{:val => "ffffffff"}
        %a{:href => "/a/queue/grid/ffffffff"} ffffffff
      %li{:val => "js"}
        %a{:href => "/a/queue/grid/js"} js
      %li{:val => "js%20map"}
        %a{:href => "/a/queue/grid/js%20map"} js map
      %li{:val => "leaflet"}
        %a{:href => "/a/queue/grid/leaflet"} leaflet
      %li{:val => "maps"}
        %a{:href => "/a/queue/grid/maps"} maps
      %li{:val => "mobile%20map"}
        %a{:href => "/a/queue/grid/mobile%20map"} mobile map
      %li{:val => "plan"}
        %a{:href => "/a/queue/grid/plan"} plan
      %li{:val => "planit"}
        %a{:href => "/a/queue/grid/planit"} planit
      %li{:val => "planit%20comp"}
        %a{:href => "/a/queue/grid/planit%20comp"} planit comp
      %li{:val => "planit%20location"}
        %a{:href => "/a/queue/grid/planit%20location"} planit location
      %li{:val => "reading"}
        %a{:href => "/a/queue/grid/reading"} reading
      %li{:val => "ux"}
        %a{:href => "/a/queue/grid/ux"} ux