window.ST = window.ST || {};

(function(module) {

  var imageUploadingCounter = 0;
  var s3Options;

function uploadImageForVerification(id, buttonID) {
  
  var fileChooser = document.getElementById("person_custom_file_fields_"+id);
  var fileChooserHd = document.getElementById("person_custom_file_fields_"+id+ "_hd")
  var file = fileChooser.files[0];
  var bucket_url = 'https://rentals-temp.s3-us-west-2.amazonaws.com/';
  var fd = new FormData();
  for (var key in s3Options) {
    
      fd.append(key, s3Options[key]);
  }
  fd.append("key", "signup/images/"+file.name);
  // fd.append("Content-Type",ST.utils.contentTypeByFilename(file.name));
  fd.append("file", file);
  imageUploadingCounter++;
  document.getElementById(buttonID).disabled = true;

  document.getElementById('upload-in-progress-'+ id).innerHTML = "File upload in progress.....";

  var checkoutImageAjax = $.ajax({
      type: "POST",
      processData: false,
      contentType: false,
      url: bucket_url,
      data: fd,
      success: function (res) {
          
          imageUploadingCounter--;
          var url = (bucket_url+encodeURIComponent("signup/images/"+file.name));
          fileChooserHd.value = url;
          toastr.success("File uploaded successfully");
          document.getElementById('upload-in-progress-'+ id).innerHTML = "";
          if (ST.checkoutSettings.checkUploadingStatus()) {
            document.getElementById(buttonID).disabled = false;
            return;
          };

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

function initializeSignupS3Options(s3ImageOptions){
    s3Options = {
        "acl": s3ImageOptions.acl,
        "signature": s3ImageOptions.signature,
        "policy": s3ImageOptions.policy,
        "AWSAccessKeyID": s3ImageOptions.AWSAccessKeyId,
        "success_action_status": 200,
    };

}

  module.personCustomFields = {
    uploadImageForVerification : uploadImageForVerification,
    checkUploadingStatus : checkUploadingStatus,
    initializeSignupS3Options : initializeSignupS3Options,
  }
})(window.ST);