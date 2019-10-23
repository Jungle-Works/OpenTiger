window.ST = window.ST || {};

(function (module){
  function openChatBox(){
    $(".flex-message-and-form").css("display", "block");
    scrollChatToBottom();
    makeTextareaScrollable();

  };
  function scrollChatToBottom(){
    console.log("sandeep");
    $(".chat-history").scrollTop($(".chat-history")[0].scrollHeight);
  }
  function closeChatBox(){
    if (x.matches){
      $(".flex-message-and-form").css("display", "none");
    }
    else{
      $(".flex-message-and-form").css("display", "block");
    }
    
  };
  function makeTextareaScrollable(){
    console.log("asdfghjkl");
    if (x.matches){
      autosize.destroy(document.getElementsByClassName("reply_form_text_area"));
    }
    else{
      auto_resize_text_areas("reply_form_text_area");
    }
    
  }
  var x = window.matchMedia("(max-width: 768px)")
  x.addListener(closeChatBox);
  x.addListener(makeTextareaScrollable);
  

  module.openChatBox = openChatBox;
  module.closeChatBox = closeChatBox;
  module.scrollChatToBottom = scrollChatToBottom;
  module.makeTextareaScrollable = makeTextareaScrollable;

})(window.ST);