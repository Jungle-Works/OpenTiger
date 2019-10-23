window.ST = window.ST || {};

(function (module) {

  var selectedTheme;

    function hideCarousel(){
        $("#theme-carousel-wrapper").hide();
    }

    function initCarousel(images){

        var listingImages = [];
        listingImages = images.map(function(data){ return {"images": data}})
          $("#thumbnail-stripe").empty();
          $("#listing-image-frame").empty();
          ST.listingImages(listingImages);
          $("#theme-carousel-wrapper").show();

    }

    
  function publish(themeDetail,theme_path) {
       $("#theme-apply-btn").attr('href', theme_path);

      $("#theme-confirmation-dialog").show();
      selectedTheme = themeDetail;
      
  }

  function changeTheme(){
    disableSubmitButton();

  }


  function disableSubmitButton() {
      // debugger;
      $("#theme-apply-btn").attr('disabled', 'disabled');
      setTimeout(function(){
        $("#theme-apply-btn").removeAttr('href');
      },100)
      var json = ST.jsonTranslations;
      $("#theme-apply-btn").text(json.please_wait);
      $("#theme-cancel-btn").hide();

  }

  function enableSubmitButton() {
      $("#theme-apply-btn").attr('disabled', false);
      var json = ST.jsonTranslations;
      $("#theme-apply-btn").text("Apply");
      $("#theme-cancel-btn").show();

  }
   

  function hideConfirmationDialog(){
    $("#theme-confirmation-dialog").hide();
  }

  function closeThemesPopup(){
    $(".themes-popup").empty();
    $(".themes-popup").hide();
  }

  function hidePaidThemesDialog(){
    $("#paid-theme-confirmation-dialog").hide();

  }
  function showPaidThemesDialog(){
    $("#paid-theme-confirmation-dialog").show();

  }

    module.adminThemes = {
        hideCarousel: hideCarousel,
        initCarousel: initCarousel,
        publish: publish,
        hideConfirmationDialog: hideConfirmationDialog,
        hidePaidThemesDialog: hidePaidThemesDialog,
        showPaidThemesDialog: showPaidThemesDialog,
        changeTheme: changeTheme,
        closeThemesPopup: closeThemesPopup
    };
})(window.ST);