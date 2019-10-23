window.ST = window.ST || {};

(function(module) {

  var initCheckoutFieldForm = function(){
    $("#add-checkout-field-form").validate({
      rules: {
          "title": {
            required: true
          }
        }
      
    })
    
  }
  
  var createColumnOrder = function (rowSelector) {

    /**
      Fetch all custom field rows and save them to a variable
    */
    var fieldMap = $(rowSelector).map(function (id, row) {
      addColumnValidation('option-' + id);
        return {
            id: 'option-' + id,
            element: $(row),
            sortPriority: id + 1,
            up: $(".option-fields-action-up", row),
            down: $(".option-fields-action-down", row)
        };
    }).get();

    var highestSortPriority = function (fieldMap) {
        return _(fieldMap)
            .map("sortPriority")
            .max()
            .value();
    };

    var nextSortPriority = (function (startValue) {
        var i = startValue;
        return function () {
            i += 1;
            return i;
        };
    })(highestSortPriority(fieldMap));

    var nextId = (function () {
        var i = 0;
        return function () {
            i += 1;
            return i;
        };
    })();

    var orderManager = window.ST.orderManager(fieldMap);


    var newOptionTmpl = _.template($("#new-option-tmpl").html());
    var $customFieldOptions = $("#dropdown-options");


    $("#add-option-btn").click(function (e) {
        e.preventDefault();
        var id = "option-" + nextId();
        var row = $(newOptionTmpl({
            id: id,
            sortPriority: nextSortPriority()
        }));
        $customFieldOptions.append(row);
        var newField = {
            id: id,
            element: row,
            up: $(".option-fields-action-up", row),
            down: $(".option-fields-action-down", row)
        };
        newOptionAdded();
        addColumnValidation(id);
        optionOrder.add(newField);

        // Focus the new one
        row.find("input").first().focus();
    });

    return {
        remove: orderManager.remove,
        add: orderManager.add
    };
};

var removeLinkEnabledState = function (initialCount, minCount, containerSelector, linkSelector) {
    var enabled;
    var count = initialCount;
    update();
    $(containerSelector).on("click", linkSelector, function (event) {
        event.preventDefault();
        if (enabled) {

            var el = $(event.currentTarget);
            var container = el.closest(".dropdown-option-container");
            container.remove();
            optionOrder.remove(container[0].id);

            count -= 1;
            update();
        }
    });

    function update() {
        enabled = count > minCount;
        $links = $(linkSelector);
        $links.addClass(enabled ? "enabled" : "disabled");
        $links.removeClass(!enabled ? "enabled" : "disabled");
    }

    return {
        add: function () {
            count += 1;
            update();
        }
    };

};

function addColumnValidation(optionId) {
  addValidationToInput("label-" + optionId, {
      required: true
  })
  addValidationToInput("price-" + optionId , {
      required: true
  })
  restrictPriceInput("#price-"+optionId);
}

function initDropdownForm(checkoutField){
  var option_count = checkoutField.value ? checkoutField.value.length : 0;
  initCheckoutFieldForm();
  newOptionAdded = removeLinkEnabledState(option_count, 1, "#dropdown-options", ".dropdown-field-option-remove").add
  optionOrder = createColumnOrder(".dropdown-option-container");

  // initializeCategoryElements();
}
function submitDropdownForm(e){
  e.preventDefault();
  elements = document.getElementById('add-checkout-field-form').elements;
  if(!$("#add-checkout-field-form").validate().form()){
    return false;
  }
  var VALUE = [];
  var count = 0;

  for (var index = 0; index < $(".dropdown-option-container").length; index++) {
      var valueData = {}
      valueIndex = $(".dropdown-option-container")[index].id;
      valueData["id"] = count;
      valueData["label"] = elements["label-"+valueIndex].value;
      valueData["price"] = elements["price-"+valueIndex].value;
      valueData["description"] = elements["description-"+valueIndex].value;
      VALUE.push(valueData);
      count = count + 1;
    }

  var checkout_field = {
    title: elements["title"].value,
    field_type: getUrlParams(window.location.href).field_type,
    value: VALUE
  };

  var json = ST.jsonTranslations;
  $("#submit-dropdwn-data-btn").text(json.please_wait);
  $.ajax({
    'type': "GET",
    'url': window.location.origin + '/admin/checkout_settings/add_checkout_field',
    'data': checkout_field,
    success: function(data){
      if (data.status == 200){
        window.location.assign(window.location.origin + "/admin/checkout_settings");
      }
    },
    error: function()
        {
          if (data.status == 201){
            toastr.error("Error occurred in adding checkout field")
            $("#submit-dropdwn-data-btn").text('Save');
          }   
        },
    dataType: 'json'
  });            
}
function UpdateDropdownValues(e, id){
  // e.preventDefault();
  elements = document.getElementById('add-checkout-field-form').elements;
  if(!$("#add-checkout-field-form").validate().form()){
    return false;
  } 
  var VALUE = [];
  var count = 0;

  for (var index = 0; index < $(".dropdown-option-container").length; index++) {
      var valueData = {}
      valueIndex = $(".dropdown-option-container")[index].id;
      valueData["id"] = count;
      valueData["label"] = elements["label-"+valueIndex].value;
      valueData["price"] = elements["price-"+valueIndex].value;
      valueData["description"] = elements["description-"+valueIndex].value;
      VALUE.push(valueData);
      count = count + 1;
    }

  var checkout_field = {
    id: id,
    title: elements["title"].value,
    value: VALUE
  };

  
  var json = ST.jsonTranslations;
  $("#submit-dropdwn-data-edit-btn").text(json.please_wait);
  $.ajax({
    'type': "GET",
    'url': window.location.origin + '/admin/checkout_settings/update_checkout_field',
    'data': checkout_field,
    success: function(data){
      if (data.status == 200){
        window.location.assign(window.location.origin + "/admin/checkout_settings");
        $("#submit-dropdwn-data-edit-btn").text('Save');
      }
    },
    error: function()
        {
          if (data.status == 201){
            toastr.error("Error occurred in adding checkout field")
            $("#submit-dropdwn-data-edit-btn").text('Save');
          }   
        },
    dataType: 'json'
  });            
}
var imageUploadingCounter = 0;
var s3Options;

function uploadImageForVerification(id) {
  
  var fileChooser = document.getElementById(id+"-file-input");
  var fileChooserHd = document.getElementById(id+"-file-input-hd")
  var file = fileChooser.files[0];
  var bucket_url = 'https://rentals-temp.s3-us-west-2.amazonaws.com/';
  var fd = new FormData();
  for (var key in s3Options) {
    
      fd.append(key, s3Options[key]);
  }
  fd.append("key", "checkout/images/"+file.name);
  // fd.append("Content-Type",ST.utils.contentTypeByFilename(file.name));
  fd.append("file", file);
  imageUploadingCounter++;

  // if(document.getElementById("send-add-card")){
  //   document.getElementById("send-add-card").disabled = true;
  // }
  // else{
  //   document.getElementById("booking-btn").disabled = true;
  // }
  document.getElementById('upload-in-progress-'+ id).innerHTML = "File upload in progress.....";

  var checkoutImageAjax = $.ajax({
      type: "POST",
      processData: false,
      contentType: false,
      url: bucket_url,
      data: fd,
      success: function (res) {
          
          imageUploadingCounter--;
          var url = (bucket_url+encodeURIComponent("checkout/images/"+file.name));
          fileChooserHd.value = url;
        
          toastr.success("File uploaded successfully");
          document.getElementById('upload-in-progress-'+ id).innerHTML = "";

          // if (ST.checkoutSettings.checkUploadingStatus()) {
          //   if(document.getElementById("send-add-card")){
          //     document.getElementById("send-add-card").disabled = false;
          //   }
          //   else{
          //     document.getElementById("booking-btn").disabled = false;
          //   }
          //   return;
          // };
      },
      error: function (res) {
          imageUploadingCounter--;
          console.log(checkoutImageAjax.getAllResponseHeaders(),res)
          toastr.error("Some error occurred in file uploading");
           document.getElementById('upload-in-progress-'+ id).innerHTML = "";
      }
  });

}
function checkUploadingStatus(){
  return imageUploadingCounter == 0 ;
}

function initializeCheckoutS3Options(s3ImageOptions){
    s3Options = {
        "acl": s3ImageOptions.acl,
        "signature": s3ImageOptions.signature,
        "policy": s3ImageOptions.policy,
        "AWSAccessKeyID": s3ImageOptions.AWSAccessKeyId,
        "success_action_status": 200,
    };

}
function onSelectCheckoutField(dropdown,id){
  if(dropdown.value){
    $("#"+id).submit()
  }

}

module.checkoutSettings = {
  initDropdownForm: initDropdownForm,
  submitDropdownForm: submitDropdownForm,
  UpdateDropdownValues: UpdateDropdownValues,
  uploadImageForVerification: uploadImageForVerification,
  checkUploadingStatus: checkUploadingStatus,
  initializeCheckoutS3Options: initializeCheckoutS3Options,
  initCheckoutFieldForm: initCheckoutFieldForm,
  addColumnValidation: addColumnValidation,
  onSelectCheckoutField: onSelectCheckoutField
}

})(window.ST);