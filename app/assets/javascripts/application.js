// This file is used in production and tests to serve generated JS assets.
//
// In development mode, we use either:
// Procfile.static: Load static assets
// Procfile.hot: Use the Webpack Dev Server to provide assets. This allows for hot reloading of
// the JS and CSS via HMR.
//
// To understand which one is used, see app/views/layouts/application.html.erb

// NOTE: See config/initializers/assets.rb for some critical configuration regarding sprockets.
// Basically, in HOT mode, we do not include this file for
// Rails.application.config.assets.precompile
//= require vendor-bundle
//= require app-bundle

// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//

//= require jquery
//= require jquery-ui-1.9.2.custom
//= require jquery.ui.touch-punch.min.js
//= require jquery_ujs
//= require jquery.form
//= require jquery.validate
//= require jquery.pageless
//= require jquery.lightbox_me
//= require jquery.transit.min
//= require jquery.ui.widget
//= require load-image.min.js
//= require canvas-to-blob.min.js
//= require jquery.fileupload
//= require jquery.fileupload-process
//= require jquery.fileupload-validate
//= require jquery.fileupload-image
//= require autosize
//= require regenerator-runtime/runtime

//= require selectize-standalone.js
//= require datepicker/bootstrap-datepicker.js

// Allow IE8-9 to post cross domain XHR (required for image upload)
//= require jquery.iframe-transport.js

//= require fastclick

// Responsive helpers
// https://github.com/edenspiekermann/minwidth-relocate
//= require relocate
//= require minwidth

//= require infobubble
//= require yelo_common
//= require Bacon
//= require Bacon.jquery.min
//= require lodash.min
//= require utils
//= require kassi
//= require googlemaps
//= require map_label
//= require homepage
//= require order_manager
//= require ajax_status
//= require admin/expiration_notice
//= require admin/custom_fields
//= require admin/categories
//= require admin/manage_members
//= require admin/topbar_menu
//= require admin/footer_menu
//= require admin/community_customizations
//= require admin/listings.js
//= require admin/listing_shapes
//= require admin/settings.js
//= require admin/emails.js
//= require admin/payment_preferences.js
//= require admin/transactions.js
//= require admin/testimonials.js
//= require admin/community_plan.js
//= require admin/landing_page.js
//= require admin/lp-category-selection.js
//= require admin/lp-location-section.js
//= require admin/lp-icons.js
//= require admin/lp-upload-image.js
//= require payment_math
//= require dropdown
//= require jquery.nouislider
//= require range_filter
//= require translations
//= require image_uploader
//= require image_carousel
//= require thumbnail_stripe
//= require listing
//= require listing_images
//= require location_search
//= require datepicker
//= require availability_calendar
//= require credit_card_validator
//= require credit_card_form
//= require toastr.min
//= require follow
//= require paypal_account_settings
//= require transaction
//= require listing_form
//= require radio_buttons
//= require new_layout
//= require stripe_form2
//= require analytics
//= require social-insurance-number
//= require stripe_payment
//= require_self
//= require moment.min
//= require daterangepicker.min
//= require date_filter
//= require order_details
//= require admin/admin_domain
//= require admin/admin_themes.js
//= require admin/checkout_settings.js
//= require admin/person_custom_fields.js
//= require admin/razorpay.js
//= require admin/content_pages.js



var adminSecretKey;

var currentUser = {};

function insertHippoCustomerScript(url) {
  return new Promise(function (resolve, reject) {
    if (!document.getElementById("hippoCustomerWidget")) {
      var script = document.createElement("script");
      script.setAttribute("type", "text/javascript");
      script.setAttribute("src", url);
      script.setAttribute("id", "hippoWidget");
      script.onload = function () {
        resolve(true);
      };
      document.head.appendChild(script);
    } else {
      resolve(true);
    }
  });
}


function insertHippoAgentScript(url) {
  return new Promise(function (resolve, reject) {
    if (!document.getElementById("hippoAgentWidget")) {
      var script = document.createElement("script");
      script.setAttribute("type", "text/javascript");
      script.setAttribute("src", url);
      script.setAttribute("id", "hippoWidget");
      script.onload = function () {
        resolve(true);
      };
      document.head.appendChild(script);
    } else {
      resolve(true);
    }
  });
}


window.ST = window.ST || {};
window.ST.updateFugu = function (id, name, color, loggedIn, secretKey, is_admin, access_token, uniqueId,hippoKey) {
  var adminCheck = Number(is_admin);


  if (environment == 'production') {
    adminSecretKey = hippoKey;
    hippoAgentWidgetUrl = 'https://chat.fuguchat.com/js/widget-agent.js';
    hippoSupportWidgetUrl = 'https://chat.fuguchat.com/js/widget.js';
  }
  else {
    adminSecretKey = hippoKey;
    hippoAgentWidgetUrl = 'https://test-chat.fuguchat.com/js/widget-agent.js';
    hippoSupportWidgetUrl = 'https://test-chat.fuguchat.com/js/widget.js';

  }

  if (adminCheck && loggedIn) {
    insertHippoAgentScript(hippoAgentWidgetUrl).then(function () {
      window.fuguInitAgentWidget({
        'access_token': access_token,
        'user_unique_keys': [],
        'color': color,
        callback: function () {
          if (adminCheck) {
            generateChatwWidget(id, color, secretKey, access_token, name);
          }
        }
      });
    })
  }
  else {
    insertHippoCustomerScript(hippoSupportWidgetUrl).then(function () {
      var initHippoObj;
   
      if(loggedIn){
        initHippoObj = {
          'appSecretKey': secretKey,
          'tags': ['yelo Rental'],
          'color': color,
          'uniqueId': uniqueId,
          'name': name
        }
       
      }
      else{
        initHippoObj = {
          'appSecretKey': secretKey,
          'tags': ['yelo Rental'],
          'color': color
        }
      }

      window.fuguInit(initHippoObj);
    })
  }


  // initFugu(id,color, secretKey, access_token, adminCheck);
  currentUser['id'] = id;
  currentUser['name'] = name;
  currentUser['color'] = color;
  


}

window.ST.shutdownFuguWidget = function () {
  try {
    window.shutDownFugu();
  } catch (e) {
    console.log(e);
  }
}


window.ST.mobilecheck = function () {
  var check = false;
  (function (a) {
    if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true;
  })(navigator.userAgent || navigator.vendor || window.opera);
  return check;
}
var showPage = 'form';


var onChangeAdminStatus = function () {

  $('.submit-btn').show();
}

var generateChatwWidget = function (id, color, secretKey, access_token, name) {

  document.addEventListener("TotalUnreadCount", function (e) {
    if (e.detail) {
      document.getElementById('unread-count').style.display = 'flex';
      document.getElementById('unread-count').innerText = e.detail;
    } else {
      document.getElementById('unread-count').style.display = 'none';
    }
  })

  document.addEventListener("fuguWidgetCollapse", function (e) {
    setStyles('chat-widgets', 'display', 'flex');
    try {
      window.destroyHippoCustomerWidget();
    }
    catch (e) {
      console.log(e);
    }
    window.fuguInitAgentWidget({
      'access_token': access_token,
      'user_unique_keys': [],
      'color': color,
    });

  });


  setStyles('fugu-widget', 'display', 'flex');
  setStyles('chat-widgets', 'display', 'flex');

  document.getElementById('fugu-widget').addEventListener('click', function () {
    toggleClassOnElement('support-widget', 'show-widget');
    toggleClassOnElement('agent-widget', 'show-widget');
  })
  document.getElementById('support-widget').addEventListener('click', function () {
    setStyles('chat-widgets', 'display', 'none');
    toggleClassOnElement('support-widget', 'show-widget');
    toggleClassOnElement('agent-widget', 'show-widget');
    newinitFugu().then(function(){});

  })
  document.getElementById('agent-widget').addEventListener('click', function () {
    toggleClassOnElement('support-widget', 'show-widget');
    toggleClassOnElement('agent-widget', 'show-widget');
    window.fuguAgentMyConversation();

  })

}

var setStyles = function (id, propertyName, value) {
  document.getElementById(id).style[propertyName] = value;
}


var toggleClassOnElement = function (id, className) {
  document.getElementById(id).classList.toggle(className);
}



function newinitFugu() {
  var hippoSupportWidgetUrl;
  if (environment == 'production') {
    hippoSupportWidgetUrl = 'https://chat.fuguchat.com/js/widget.js';
  }
  else {
    hippoSupportWidgetUrl = 'https://test-chat.fuguchat.com/js/widget.js';

  }
  return new Promise(function(resolve,reject){
    insertHippoCustomerScript(hippoSupportWidgetUrl).then(function () {
      try {
        window.fuguDestroyAgentWidget();
      }
      catch (e) {
        console.log(e);
      }
      showFuguWidget().then(function () { 
        resolve();
      });
    });
  })
  

}

function showFuguWidget() {
  return new Promise(function (resolve, reject) {
    window.fuguInit({
      appSecretKey: adminSecretKey,
      uniqueId: currentUser['id'],
      name: currentUser['name'],
      showData: true,
      ignore_auto_msgs: true, // ignore timed how can i help u message.
      tags: ["Yelo Rental"],
      color: currentUser['color'],
      callback: function () {
        window.expandHippoWidget();
        resolve();
      },
      'collapseType': 'hide',
    });
  });


}
window.ST.setAvatarColor = function (color) {
  if (document.getElementsByClassName("_custAvatar") && document.getElementsByClassName("_custAvatar").length){
    document.getElementsByClassName("_custAvatar")[0].childNodes[0].style.backgroundColor = color;
    document.getElementsByClassName("_custAvatar")[0].childNodes[0].style["border-radius"] = '50%';
    document.getElementsByClassName("_custAvatar")[0].childNodes[0].style.backgroundImage = 'linear-gradient(-180deg,' + color + ',darken(' + color + ',-20%))'
    document.getElementsByClassName("_custAvatar")[0].childNodes[0].style.boxShadow = "0px 2px 5px rgba(0, 0, 0, 0.5)";
    document.getElementsByClassName("_sideCustAvatar")[0].childNodes[0].style.backgroundColor = color;
    document.getElementsByClassName("_sideCustAvatar")[0].childNodes[0].style["border-radius"] = '50%';
    document.getElementsByClassName("_sideCustAvatar")[0].childNodes[0].style.backgroundImage = 'linear-gradient(-180deg,' + color + ',darken(' + color + ',-20%))'
    document.getElementsByClassName("_sideCustAvatar")[0].childNodes[0].style.boxShadow = "0px 2px 5px rgba(0, 0, 0, 0.5)";
  
  }
   

};
window.ST.clearFilter = function (options) {

  for (var i = 0; i < options.length; i++) {

    document.getElementById(options[i]).checked = false;
  }
};


window.ST.cancelFilterCheckbox = function (options, menuSelector) {
  var params = getUrlParams(window.location.href);

  for (var i = 0; i < options.length; i++) {
    if (params.hasOwnProperty(options[i])) {
      document.getElementById(options[i]).checked = true;
    }
    else {
      document.getElementById(options[i]).checked = false;
    }

  }
  document.body.click();

}



// toastr.options.positionClass = 'toast-top-full-width';
toastr.options.extendedTimeOut = 0; //1000;
toastr.options.timeOut = 4000;
toastr.options.preventDuplicates = true;
