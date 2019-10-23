window.ST = window.ST || {};

window.ST.transaction = window.ST.transaction || {};

(function (module, _) {

  function toOpResult(submitResponse) {
    if (submitResponse.op_status_url) {
      return ST.utils.baconStreamFromAjaxPolling({
          url: submitResponse.op_status_url
        },
        function (pollingResult) {
          return pollingResult.completed;
        }
      ).flatMap(function (pollingResult) {
        var opResult = pollingResult.result;
        if (opResult.success) {
          return opResult;
        } else {
          return new Bacon.Error({
            errorMsg: submitResponse.op_error_msg
          });
        }
      });
    } else if (submitResponse.redirect_url) {
        return {
          success: true,
          data: submitResponse
        };
    } else {
      return new Bacon.Error({
        errorMsg: submitResponse.error_msg
      });
    }
  }


  function setupSpinner($form) {
    return $form.find(".payment-button-wrapper .paypal-button-loading-img");
  }

  function toggleSpinner($spinner, show) {
    var payment_type = $("#payment_type").val(),
      prefix = "";
    if (payment_type == 'paypal') {
      prefix = '.paypal-payment ';
    } else if (payment_type == 'stripe') {
      prefix = '.stripe-payment ';
    }
    if (show === true) {
      $(prefix + ".paypal-button-loading-img").show();
    } else {
      $(".paypal-button-loading-img").hide();
    }
  }


  function redirectFromOpResult(opResult) {
    window.location = opResult.data.redirect_url;
  }

  function showErrorFromOpResult(opResult) {
    ST.utils.showError(opResult.errorMsg, "error");
  }


  function initializePayPalBuyForm(formId, analyticsEvent, communityId,communitiesWithAddress) {
    var $form = $('#' + formId);
    var formAction = $form.attr('action');
    var $spinner = setupSpinner($form);

    var params = getUrlParams(window.location.href);
    if (params.unit_type == 'unit' && communitiesWithAddress.includes(communityId)) {

      $.validator.addMethod("invalidDeliveryAddress", function (value, element) {
        return this.optional(element) || ($("#delivery_loc_latitude").val() && $("#delivery_loc_longitude").val());
      }, "Choose valid address");

      $('#' + formId).validate({
        rules: {
          "apartment-no": {
            required: true
          },
          "delivery-address": {
            required: true,
            invalidDeliveryAddress: true
          },
          // "postal_code": {
          //   required: true
          // },
          "landmark": {
            required: true
          }
        },
      });
    }

    // EventStream of true/false
    var submitInProgress = new Bacon.Bus();

    var formSubmitWithData = $form.asEventStream('submit', function (ev) {
        ev.preventDefault();
        return $form.serialize();
      })
      .filter(submitInProgress.not().toProperty(true)); // Prevent concurrent submissions

    var opResult = formSubmitWithData
      .flatMapLatest(function (data) {
        return Bacon.$.ajaxPost(formAction, data);
      })
      .flatMapLatest(toOpResult);

    var analyticsEventSent = formSubmitWithData
      .flatMapLatest(function () {
        var timeout = Bacon.later(3000, "timeout");
        var response = Bacon.fromCallback(function (callback) {
          window.ST.analytics.logEvent(analyticsEvent[0], null, null, analyticsEvent[1]);
        });

        return timeout.merge(response).take(1);
      });

    submitInProgress.plug(formSubmitWithData.map(true));
    // Success response to operation keeps submissions blocked, error releases
    submitInProgress.plug(opResult.map(true).mapError(false));
    submitInProgress.skipDuplicates().onValue(_.partial(toggleSpinner, $spinner));

    opResult.onError(showErrorFromOpResult);

    Bacon.onValues(opResult, analyticsEventSent, redirectFromOpResult);
  }

  function initializeCreatePaymentPoller(opStatusUrl, redirectUrl) {
    ST.utils.baconStreamFromAjaxPolling({
        url: opStatusUrl
      },
      function (pollingResult) {
        return pollingResult.completed;
      }
    ).onValue(function () {
      window.location = redirectUrl;
    });
  }
  
  $("#transaction-form").on('submit', function(event){
    
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

    
  });

  function initializeFreeTransactionForm(locale, communityId,communitiesWithAddress) {
    window.auto_resize_text_areas("text_area");
    $('textarea').focus();
    var form_id = "#transaction-form";
    var params = getUrlParams(window.location.href);

    $(form_id).validate({
      rules: {
        "message": {
          required: true
        }
      },
      submitHandler: function (form) {
        if (!ST.checkoutSettings.checkUploadingStatus()){
          return false;
        }
        window.disable_and_submit(form_id, form, "false", locale);
      }

    });
    if (params.unit_type == 'unit' && communitiesWithAddress.includes(communityId)) {
      $.validator.addMethod("invalidDeliveryAddress", function (value, element) {
        return this.optional(element) || ($("#delivery_loc_latitude").val() && $("#delivery_loc_longitude").val());
      }, "Choose valid address");
      $("#apartment-no").rules("add", {
        required: true
      });
      $("#delivery-address").rules("add", {
        required: true,
        invalidDeliveryAddress: true
      });

      // $("#postal_code").rules("add", {
      //   required: true
      // });
      
      $("#landmark").rules("add", {
        required: true
      });
    }

  }
  

  function onDropdownSelect(options, id,title,currency) {
    
    var oldPrice = 0,newPrice;
    var dropdown = document.getElementById("dropdown-"+id);
    var index = dropdown.selectedIndex;
    var selectedOption = JSON.parse(dropdown.options[index].dataset.value);
    if(selectedOption.description){
      $("#dropdown-info-icon-"+id).css("display", "block");
      $("#info-text-"+id).html(selectedOption.description)
    }
    else{
      $("#dropdown-info-icon-"+id).css("display", "none");
      $("#info-text-"+id).html('')
    }
    
    if(document.getElementById('checkout-field-data-'+id)){
      oldPrice = parseFloat($("#checkout-field-data-"+id).children()[1].innerHTML.trim().substring(1));
      $("#checkout-field-data-"+id).children()[1].innerHTML = (currency+selectedOption.price);
      newPrice = parseFloat(selectedOption.price);
    }
    else{
      $(".preauthorize-section .initiate-transaction-totals").prepend(
        '<div class="initiate-transaction-sum-wrapper" id="checkout-field-data-'+ id + '">'+
        '<span class="initiate-transaction-sum-label">'+
        (title+':')                                    +
        '</span>'                                      +
        '<span class="initiate-transaction-sum-value">'+
        (currency+selectedOption.price)                +
        '</span>'                                      +
        '</div>'
      )
      newPrice = parseFloat(selectedOption.price);
    }
    var originalPrice = parseFloat($('#total-temp-price').val());
    $('#total-temp-price').val(originalPrice - oldPrice + newPrice);
    $('.initiate-transaction-total-value').html(currency + (originalPrice - oldPrice + newPrice));

    
  }

  module.initializePayPalBuyForm = initializePayPalBuyForm;
  module.initializeCreatePaymentPoller = initializeCreatePaymentPoller;
  module.initializeFreeTransactionForm = initializeFreeTransactionForm;
  module.onDropdownSelect = onDropdownSelect;
  module.toggleSpinner = toggleSpinner;

})(window.ST.transaction, _);




