window.ST = window.ST || {};

(function (module) {

    var imageUploadingCounter = 0;
    var s3Options;

    function uploadImage(upload_translation,id) {

        var image = $(id+"-input")[0].files[0];
        $(id + ">.centred-text").html(upload_translation);
        var bucket_url = 'https://rentals-temp.s3-us-west-2.amazonaws.com/';
        var fd = new FormData();
        for (var key in s3Options) {

            fd.append(key, s3Options[key]);
        }
        fd.append("key", "landing/images/"+image.name);
        fd.append("Content-Type",ST.utils.contentTypeByFilename(image.name));
        fd.append("file", image);
        imageUploadingCounter++;

        var imageAjax = $.ajax({
            type: "POST",
            processData: false,
            contentType: false,
            url: bucket_url,
            data: fd,
            success: function (res) {
                
                imageUploadingCounter--;
                $("#lp-form").validate().element(id+"-input");
                $(id+"-input")[0].type = "hidden";
                var url = (bucket_url+encodeURIComponent("landing/images/"+image.name));
                window.ST.utils.loadImage(url).then(function(){
                    $(id + ">.lp-fileupload-preview-image")[0].src = url;
                    $(id+"-input")[0].value = url;
                    $(id + ">.centred-text").html("");
                    $(id + ">.fileupload-preview-remove-image").show();
                    console.log(imageAjax.getAllResponseHeaders(),res)
                })
             
            },
            error: function (res) {
                imageUploadingCounter--;
                console.log(imageAjax.getAllResponseHeaders(),res)
            }
        });

    }

    function clikcOnFileUpload(id) {
        var inputId = id+"-input";
        $(inputId).click();
    }

    function removeImage(e,id){
        e.stopPropagation();
        $(id+"-input")[0].type = "file";
        $(id+"-input")[0].value = "";
        $(id + ">.centred-text").html("Select file");
        $(id + ">.lp-fileupload-preview-image").removeAttr('src');
        $(id + ">.fileupload-preview-remove-image").hide();
    }

    function checkUploadingStatus(){
        return imageUploadingCounter != 0;
    }

    function initializeS3Options(s3ImageOptions){
        s3Options = {
            "acl": s3ImageOptions.acl,
            "signature": s3ImageOptions.signature,
            "policy": s3ImageOptions.policy,
            "AWSAccessKeyID": s3ImageOptions.AWSAccessKeyId,
            "success_action_status": 200,
        };
    
    }
    module.lpImageUpload = {
        removeImage: removeImage,
        clikcOnFileUpload: clikcOnFileUpload,
        uploadImage: uploadImage,
        checkUploadingStatus: checkUploadingStatus,
        initializeS3Options: initializeS3Options

    };
})(window.ST);