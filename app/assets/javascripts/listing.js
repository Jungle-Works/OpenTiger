window.ST = window.ST || {};

(function (module) {

  module.deleteListingPopupInit = function () {
    $('#delete_listing_popup').lightbox_me({
      centered: true,
      closeSelector: '#close_x, #close_x1'
    });


  }
  module.deletelisting = function (url) {
    $("#del-save-btn").attr('disabled', 'disabled');
    var json = ST.jsonTranslations;
    $("#del-save-btn").text(json.please_wait);
    $(".del-cancel-btn").hide();
  }
  module.listing = function () {
    $('#add-to-updates-email').on('click', function () {
      var text = $(this).find('#add-to-updates-email-text');
      var actionLoading = text.data('action-loading');
      var actionSuccess = text.data('action-success');
      var actionError = text.data('action-error');
      var url = $(this).attr('href');

      text.html(actionLoading);

      $.ajax({
        url: url,
        type: "PUT",
      }).done(function () {
        text.html(actionSuccess);
      }).fail(function () {
        text.html(actionError);
      });
    });
  };

  module.initializeQuantityValidation = function (opts) {
    jQuery.validator.addMethod(
      "positiveIntegers",
      function (value) {
        return (value % 1) === 0 && value > 0;
      },
      jQuery.validator.format(opts.errorMessage)
    );

    // add rule to input
    $('#' + opts.input).rules("add", {
      positiveIntegers: true
    });
  };

  module.initializeShippingPriceTotal = function (currencyOpts, quantityInputSelector, shippingPriceSelector) {
    var $quantityInput = $(quantityInputSelector);
    var $shippingPriceElements = $(shippingPriceSelector);

    var updateShippingPrice = function () {
      $shippingPriceElements.each(function (index, shippingPriceElement) {
        var $priceEl = $(shippingPriceElement);
        var shippingPriceCents = $priceEl.data('shipping-price') || 0;
        var perAdditionalCents = $priceEl.data('per-additional') || 0;
        var quantity = parseInt($quantityInput.val() || 0);
        var additionalCount = Math.max(0, quantity - 1);

        // To avoid floating point issues, do calculations in cents
        var newShippingPrice = shippingPriceCents + perAdditionalCents * additionalCount;
        var priceForDisplay = ST.paymentMath.displayMoney(newShippingPrice,
          currencyOpts.symbol,
          currencyOpts.digits,
          currencyOpts.format,
          currencyOpts.separator,
          currencyOpts.delimiter)
        $priceEl.text(priceForDisplay);
      });
    };

    $quantityInput.on("keyup change", updateShippingPrice); // change for up and down arrows
    updateShippingPrice();
  };
  var hidePopupForDatePicker = function () {
    $(".datepicker-popup").css("display", "none");
    if (x.matches) {
      $(".book-or-listing-actions").css("display", "none");
    } else {
      $(".book-or-listing-actions").css("display", "block");
    }

  };

  var removeAppendNodes = function (targetElement, parentElement) {

    var target_node = document.getElementsByClassName(targetElement)[0];
    var parent_node = document.getElementById(parentElement);

    parent_node.appendChild(target_node);
  }

  var x = window.matchMedia("(max-width: 1024px)")
  x.addListener(hidePopupForDatePicker);



  module.switchListingActionsNode = function (targetElement, newParent, oldParent) {

    var target_node = document.getElementsByClassName(targetElement)[0];
    var new_parent_node = document.getElementById(newParent);
    var old_parent_node = document.getElementById(oldParent);

    x.addListener(function () {
      if (x.matches) {
        removeAppendNodes(targetElement, newParent)
      } else {
        if (!old_parent_node.contains(target_node)) {
          removeAppendNodes(targetElement, oldParent)
        }
      }
    });
  }
  module.switchListingActionsNodeOnLoad = function (targetElement, newParent, oldParent) {
    var target_node_a = document.getElementsByClassName(targetElement)[0];
    var new_parent_node_a = document.getElementById(newParent);
    var old_parent_node_a = document.getElementById(oldParent);
    if (x.matches) {
      removeAppendNodes(targetElement, newParent)
    } else {
      if (!old_parent_node_a.contains(target_node_a)) {
        removeAppendNodes(targetElement, oldParent)
      }
    }
  }


  module.showPopupForDatePicker = function () {
    $(".datepicker-popup").css("display", "flex");
    $(".book-or-listing-actions").css("display", "block");
  };
  module.hidePopupForDatePicker = hidePopupForDatePicker
  module.removeAppendNodes = removeAppendNodes


  module.hideFlexImageCarousel = function () {
    $(".flex-image-carousel").css("display", "none");
  }
  module.showFlexImageCarousel = function (index) {

    $(".flex-image-carousel").css("display", "flex");
    document.getElementsByClassName("listing-image-thumbnail-container")[index].click();
  }

  module.blurRestImages = function (index) {

    if (document.getElementsByClassName("two-photos")) {
      var childern1 = $("#two-photos").find(".for-hover-effect");
      for (var i = 0; i < childern1.length; i++) {
        if (childern1[i].dataset.index != index) {
          childern1[i].style.opacity = "0.6";
        }
      }
    }
    if (document.getElementsByClassName("two-photos")) {
      var childern1 = $("#five-photos").find(".for-hover-effect");
      for (var i = 0; i < childern1.length; i++) {
        if (childern1[i].dataset.index != index) {
          childern1[i].style.opacity = "0.6";
        }
      }
    }
  }
  module.removeBlurEffect = function () {
    var elements = document.getElementsByClassName("for-hover-effect");
    for (var i = 0; i < elements.length; i++) {

      elements[i].style.opacity = "1";
    }
  }
  module.closeCarouselOnClick = function (event) {
    if (event.target.contains(document.getElementById("thumbnail-stripe"))) {
      $(".flex-image-carousel").css("display", "none");
    }
  }
  $(document).ready(function () {
    $(document).keyup(function (e) {
      if (e.key === "Escape") {
        $(".flex-image-carousel").css("display", "none");
      }
    });
  })


})(window.ST);