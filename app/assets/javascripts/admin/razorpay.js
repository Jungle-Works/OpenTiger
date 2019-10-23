window.ST = window.ST || {};

(function (module) {

  var razorPayWindow;

  function initPayment() {

    if(!$("#transaction-form").validate().form()){
      return false;
    }
    if (!ST.checkoutSettings.checkUploadingStatus()){
      return false;
    }

    openWindowInCenter('', '', 500, 600, 100);
    razorPayWindow.document.title = 'Payment Process';
    razorPayWindow.document.body.innerHTML = "<h5>Don't close or refresh the payment window .....</h5>"
    setOnCloseWinListener();
    document.getElementById("razorpay-payment-gateway").style.display = "flex";
    console.log($('#total-temp-price').val())


    $.ajax({
      'type': "POST",
      'url': window.location.origin + '/razorpay_service/checkout/order_create',
      'data': {
        price: $('#total-temp-price').val(),
        currency: "INR"
      },
      success: function (data) {
        console.log("sandeep", data)
        razorPayWindow.location.href = window.location.origin + '/razorpay_service/checkout/redirect/' + data.order_id
        if (data.status == 200) {
          console.log("hittttttttttt.............................")
        }
        if (data.status == 201) {
          console.log("errrrrrrrrrrrrrr.............................")
        }
      },
      error: function () {
        toastr.error("Oops, some error occurred");

      },
      dataType: 'json'
    });
  }

  function focusOnWindow() {
    razorPayWindow.focus();
  }

  function setOnCloseWinListener() {

    var closeWindowListener = setInterval(function () {
      if (razorPayWindow.closed) {

        document.getElementById("razorpay-payment-gateway").style.display = "none";
        clearInterval(closeWindowListener);
      }
    }, 500);

  };



  function openWindowInCenter(url, title, w, h, t) {
    // Fixes dual-screen position Most browsers Firefox 
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY;

    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var systemZoom = width / window.screen.availWidth;
    var left = (width - w) / 2 / systemZoom + dualScreenLeft
    var top = (height - h) / 2 / systemZoom + dualScreenTop + t;
    razorPayWindow = window.open(url, '', 'scrollbars=yes, width=' + w / systemZoom + ', height=' + h / systemZoom + ', top=' + top + ', left=' + left);

    // Puts focus on the newWindow 
    if (window.focus) razorPayWindow.focus();
  }

  window.onmessage = function (event) {
    if (typeof event.data == 'object') {
      if (event.data.payment_method == "razorpay") {
        if (event.data.status == 'success') {
          setTimeout(function () {
            addElementsToForm(event);
          }, 3000);
        } else {
          setTimeout(function () {
            onErrorMessage();
          }, 3000);
        }
      }
    }
  };

  function addElementsToForm(fields) {

    razorPayWindow.close();
    var form = document.getElementById("transaction-form");

    var razorpay_order_id = addInputField("razorpay_order_id", fields.data.razorpay_order_id)
    form.append(razorpay_order_id);

    var razorpay_payment_id = addInputField("razorpay_payment_id", fields.data.razorpay_payment_id);
    form.append(razorpay_payment_id);

    var razorpay_signature = addInputField("razorpay_signature", fields.data.razorpay_signature);
    form.append(razorpay_signature);

    $("#payment_type").val("razorpay");
    addCF();
    form.submit();
  }

  function addInputField(name, value) {
    var field = document.createElement("input");
    field.setAttribute("type", "hidden");
    field.setAttribute("name", name);
    field.setAttribute("value", value);
    return field;
  }

  function addCF(){
    console.log("dasdasdasd")
    var checkout_fields = [];
      elements = document.getElementById('transaction-form').elements;
      
      for (var index = 0; index < elements.length; index++){
        if (elements[index].name.includes("checkout-field-dropdown")){
          var optIndex = elements[index].selectedIndex;
          var option = JSON.parse(elements[index].options[optIndex].dataset.value);
          var objarray = []  //for future use of checkout fields......
          var obj = { "label": option.label, "value": option.price, "description": option.description}
          objarray.push(obj)
          checkout_fields.push({"type": "DropdownField", 'title':elements[index].dataset.title, 'value': objarray})      
        }
        if (elements[index].name.includes("checkout-field-text")){
          checkout_fields.push({"type": "TextField", 'title': elements[index].dataset.title, 'value': elements[index].value })
        }
        if(elements[index].type == "hidden"){
          if (elements[index].name.includes("checkout-field-file")){
            checkout_fields.push({"type": "FileUpload", 'title': elements[index].dataset.title, 'value': elements[index].value})
          
          }
        }
        
      }
     
      var checkout_fields_data = JSON.stringify(checkout_fields);
      $("#converted-checkout-fields-data").val(checkout_fields_data);
  }

  function onErrorMessage() {
    razorPayWindow.close();
  }

  var initRazorpayPayoutForm = function () {

    restrictPriceInput("#seller-account-number");

    var IFSCRegex = new RegExp(/^[A-Za-z]{4}[0-9]{6,7}$/);

    $.validator.addMethod("IFSC_code", function (value, element) {
      return this.optional(element) || IFSCRegex.test(value);
    }, "Must be a valid IFSC code");

    $("#add-seller-account-details").validate({
      
      errorPlacement: function(errorLabel, element) {
        if (( /radio|checkbox/i ).test( element[0].type )) {
          element.closest('.checkbox-container').append(errorLabel);
        } else {
          errorLabel.insertAfter( element );
        }
      },

      rules: {
        "name": {
          required: true
        },
        "business_name": {
          required: true
        },
        "account_number": {
          required: true
        },
        "ifsc_code": {
          required: true,
          "IFSC_code": true
        },
        "business_type": {
          required: true
        },
        "account_type": {
          required: true
        },
        "beneficiary_name": {
          required: true
        },
      }
    })
  }

  $("#accept-rp-tnc").on('change', function () {
    if ($(this).is(':checked')) {
      $(this).attr('value', true);
    } else {
      $(this).attr('value', false);
    }
  });

  var submitRazorpayPayouts = function () {
    if (!$("#add-seller-account-details").validate().form()) {
      return false;
    }
    console.log("submitted");
    var form = document.getElementById("add-seller-account-details");
    var element = form.elements;
    var payoutData = {
      "name": element["name"].value,
      "email": element["email"].value,
      "business_name": element["business_name"].value,
      "business_type": element["business_type"].value,
      "account_number": element["account_number"].value,
      "ifsc_code": element["ifsc_code"].value,
      "account_type": element["account_type"].value,
      "beneficiary_name": element["beneficiary_name"].value,
      "accept_rp_tnc": element["accept-rp-tnc"].value
    }
    var url = window.location.origin + "/payment_settings/razorpay_account"
    console.log(payoutData);
    var json = ST.jsonTranslations;
    $("#submit-rp-payouts").text(json.please_wait);
    $.ajax({
      'type': "POST",
      'url': url,
      'data': payoutData,
      success: function (data) {
        console.log("sandeep", data)
        if (data.status == 200) {
          console.log("hittttttttttt.............................")
          form.submit();
        }
        if (data.status == 400) {
          console.log("errrrrrrrrrrrrrr.............................")
          toastr.error(data.message);
          $("#submit-rp-payouts").text("Save details");
        }
      },
      error: function () {
        toastr.error("Oops, some error occurred");
        $("#submit-rp-payouts").text("Save");

      },
      dataType: 'json'
    });

  }

  


  module.razorpay = {
    initPayment: initPayment,
    focusOnWindow: focusOnWindow,
    initRazorpayPayoutForm: initRazorpayPayoutForm,
    submitRazorpayPayouts: submitRazorpayPayouts
  }
})(window.ST)