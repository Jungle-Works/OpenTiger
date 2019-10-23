var displaySaveCancel = function(){
    document.getElementById("domain-buttons").style.display = "flex";
}

var initAdminDomainForm = function(){
    var hostNameRegex = new RegExp(/^(?!(https:\/\/|http:\/\/|mailto:|smtp:|ftp:\/\/|ftps:\/\/))(((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,86}[a-zA-Z0-9]))\.(([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,73}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25})))|((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,162}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25}))))$/);

    $.validator.addMethod("hostRegex", function (value, element) {
        return this.optional(element) || hostNameRegex.test(value);
      }, "Must be a valid hostname");


    $("#cust_domain_form").validate({
        rules: {
            "cust_domain": {
              required: true,
              "hostRegex": true
            }
          },
      errorPlacement: function(error, element) {
        error.insertAfter(element.parent())
    }
    })

}

var checkDomainAvailability = function(event,access_token , user_id, billing_plan){

    event.preventDefault();

    
    var canUpdateDomain =  true
    if(!$("#cust_domain_form").validate().form()){
        return false;
    }
    if (canUpdateDomain){

        var json = ST.jsonTranslations;
        $("#change-domain-btn").text(json.please_wait);
        $.ajax({
            'type': "POST",
            'url': window.location.origin + '/admin/admin_domains/validate_domain',
            'data': {
            'domain' : $('#cust_domain').val()
            },
            success: function(data){
                console.log("1st hit" , data)
                if (data.status == 200){
                    updateMPdomain(access_token , user_id);
                }
                if (data.status == 201){
                    toastr.error("Oops, previous change request already in process");
                    $("#change-domain-btn").text('Save');
                }
    
            },
            error: function()
                {
                    toastr.error("Oops, some error occurred");
                    $("#change-domain-btn").text('Save');
                },
        dataType: 'json'
        });            
    }
    else
    {
        var ans = confirm("To avail these feature you have to choose a paid plan. Click 'OK' to choose.");

        if (ans == true){
            var json = ST.jsonTranslations;
            $("#change-domain-btn").text(json.please_wait);
            window.location.assign(window.location.origin + "/admin/community_plans");
        }
        else{
            console.log("denied")
            $("#change-domain-btn").text('Save');
        }

    }
    
}

var updateMPdomain = function(access_token , user_id){
    
        if(environment == 'production'){
            domain_API = 'https://rentalssl.jungleworks.com/domain/createCustomDomain'
          }
          else{
            domain_API = 'https://test-api-3033.yelo.red/domain/createCustomDomain'
          }
        $.ajax({
            type: "POST",
            url: domain_API,
            data: {
              'access_token': access_token,
              'user_id': user_id,
              'custom_domain': $('#cust_domain').val(),
              'type': 0
            },
            success: function(data){
                console.log("2nd hit" , data)
                if (data.status == 200){
                    $.ajax({
                        'type': "PUT",
                        'url': window.location.origin + '/admin/admin_domains/3',
                        'data': {
                        'domain' : $('#cust_domain').val()
                },
                    success: function(data){
                        toastr.success(data.message, "Domain Saved");
                        console.log("3rd hit" , data)
                        $("#change-domain-btn").text('Save');
    
                    },
                    error: function()
                        {
                            toastr.error("Oops, some error occurred");
                            $("#change-domain-btn").text('Save');
                        },
                    dataType: 'json'
                    });            
                }
                else
                {
                    toastr.error("Oops, some error occurred");
                    $("#change-domain-btn").text('Save');
                
                }
            },
            error: function(){
                toastr.error("Oops, some error occurred");
                $("#change-domain-btn").text('Save');
            },
            dataType: 'json'
        });
        
}
    

var closeDomainForm = function(){
    $("#cust_domain_form").validate().resetForm();
    document.getElementById("domain-buttons").style.display = "none";
    $("#change-domain-btn").text('Save');
}

window.ST = window.ST || {};

(function (module) {
    function showMapFormButtons() {
        $(".map-form-btn").css("display", "flex");
    }

    function resetMapForm() {
        $("#google_map_form").validate().resetForm();
        $("#map-buttons").hide();
    }


    function disableSubmitButton() {
        // debugger;

        var json = ST.jsonTranslations;
        $("#submit-map-form").text(json.please_wait);
        $("#reset-map-form").hide();

    }

    module.adminDomain = {
        showMapFormButtons: showMapFormButtons,
        resetMapForm: resetMapForm,
        disableSubmitButton: disableSubmitButton
    }
})(window.ST)