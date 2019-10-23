window.ST = window.ST || {};

(function (module) {
  var editor;
  

  function initContentForm(){
    var end_point_regex = new RegExp(/^[a-zA-Z0-9\-]*$/);

    $.validator.addMethod("end_point", function (value, element) {
      return this.optional(element) || end_point_regex.test(value);
    }, "Must be a valid end point");

    $("#content-page-form").validate({
      rules: {
        "title": {
          required: true
        },
        "url": {
          required: true,
          end_point: true
        }
      }
    })
  }

  function initEditor(data) {
    $('textarea').each(function () {
      editor = new Jodit(this,
        {
          height: 500
        }
      );
      if (data != "") {
        editor.value = data;
      }
    });
  };

  function updateActiveStatus(id,index) {
    var checked;
    var checkbox = document.getElementById("active-status-"+ index);
    var spinner = document.getElementById("status-spinner-"+ index);
    checkbox.style.display = "none";
    spinner.style.display = "block"

    if (checkbox.checked == true) {
      checked = true;
    } else {
      checked = false;
    }
    
    $.ajax({
      type: "POST",
      url: window.location.origin + '/admin/content_pages/' + id + '/update_active_status',
      data: {
        'id': id,
        'status': checked,
      },
      success: function (data) {
        if (data.status == 200) {
          toastr.success("Activation status updated");
          checkbox.style.display = "block";
          spinner.style.display = "none"
          
          
        } else {
          toastr.error("Oops, some error occurred");
          checkbox.style.display = "block";
          spinner.style.display = "none"
          if (checkbox.checked == true) {
            checkbox.checked = false;
          } else {
            checkbox.checked = true;
          }
          
        }
      },
      error: function(){
        toastr.error("Oops, some error occurred");
        checkbox.style.display = "block";
        spinner.style.display = "none"
        if (checkbox.checked == true) {
          checkbox.checked = false;
        } else {
          checkbox.checked = true;
        }
      },
      dataType: 'json'
    });
  };
  function addContentPage(event,id) {
    event.preventDefault();
    if(!$("#content-page-form").valid()){
      return false;
    }
    var json = ST.jsonTranslations;
    $("#save-content").text(json.please_wait);
    var content_page_data = {
      title: $('#content_page_title').val(),
      url: $('#content_page_url').val(),
      content_desc: $('#content-editor-space').val(),
    }
    console.log(content_page_data);
    $.ajax({
      'type': "POST",
      'url': window.location.origin + '/admin/content_pages/new_content_page',
      'data': content_page_data,
      success: function (data) {
        
        if (data.status == 200) {
          console.log("hittttttttttt.............................", data)
          window.location.assign(window.location.origin + "/admin/content_pages/"+ id);
        }
        else{
          toastr.error(data.message);
          $("#save-content").text("Save");
        }
      },
      error: function () {
        toastr.error("Oops, some error occurred");
        $("#save-content").text("Save");

      },
      dataType: 'json'
    });
  }

  function updateContentPage(event,id,content_id) {
    event.preventDefault();
    if(!$("#content-page-form").valid()){
      return false;
    }
    var json = ST.jsonTranslations;
    $("#save-content").text(json.please_wait);

    var content_page_data = {
      title: $('#content_page_title').val(),
      url: $('#content_page_url').val(),
      content_desc: $('#content-editor-space').val(),
    }
    console.log(content_page_data);
    $.ajax({
      'type': "POST",
      'url': window.location.origin + "/admin/content_pages/"+ content_id + "/update_content_page",
      'data': content_page_data,
      success: function (data) {
        
        if (data.status == 200) {
          console.log("hittttttttttt.............................", data)
          window.location.assign(window.location.origin + "/admin/content_pages/"+ id);
        }
        else{
          toastr.error(data.message);
          $("#save-content").text("Save");
        }
      },
      error: function () {
        toastr.error("Oops, some error occurred");
        $("#save-content").text("Save");

      },
      dataType: 'json'
    });
  }

  module.content_pages = {
    initEditor: initEditor,
    initContentForm: initContentForm,
    updateActiveStatus : updateActiveStatus,
    addContentPage : addContentPage,
    updateContentPage :updateContentPage
  }
})(window.ST);