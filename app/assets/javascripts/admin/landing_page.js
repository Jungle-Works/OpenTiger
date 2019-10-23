window.ST = window.ST || {};

(function (module) {

    var landingPageData, newOptionAdded, optionOrder, listings, categories;
    var notificationTimeout, landingPageUrl, newLandingPageData,formValidator;

    function intialize(data) {
        landingPageData = data;
        newLandingPageData = JSON.parse(JSON.stringify(data));
        // console.log(data);
    }

    function updateLandingPageStructure(reload, showNotification,form_type) {

        disableSubmitButton();
        // console.log(JSON.stringify(newLandingPageData))
        if(showNotification){
            showUpdateNotification();
        }

        $.ajax({
            type: "POST",
            url: window.location.origin + '/admin/manage_landing_page/save_only',
            data: {
                'content': JSON.stringify(newLandingPageData)
            },
            success: successCallback,
            error: errorCallback,
            complete: function(){
                if(form_type == "add_form"|| form_type == "edit_form"){
                    window.location.assign(window.location.origin+landingPageUrl);
                }
                reload ? window.location.reload(): "";
            },
            dataType: 'json'
        });


    }


    function errorCallback(res) {

        toastr.error(res.message, "Error");
        enableSubmitButton();
    }

    function successCallback(res) {
        if (res.status == 200) {
            enableSubmitButton();
            toastr.success("Section updated","Success");

        } else {
            errorCallback(res);
        }

    }

    function disableSubmitButton() {
        // debugger;
        $("#save-btn").attr('disabled', 'disabled');
        var json = ST.jsonTranslations;
        $("#save-btn").text(json.please_wait);
        $("#cancel-btn").hide();
    }

    function enableSubmitButton() {
        $("#save-btn").attr('disabled', false);
        var json = ST.jsonTranslations;
        $("#save-btn").text("Save");
        $("#cancel-btn").show();
    }

    function edit(url, sectionId) {
        var section = landingPageData.sections.find(function (value) {
            return value.id == sectionId
        });
        window.location.assign(url + '?kind=' + section.kind + '&variation=' + section.variation);
    }

    /**
    Custom field option order manager.

    Changes `sort_priority` hidden field when order changes.
  */
    var createColumnOrder = function (rowSelector, sectionData) {

        /**
          Fetch all custom field rows and save them to a variable
        */
        var fieldMap = $(rowSelector).map(function (id, row) {
            addColumnValidation('column-' + id);
            initIconSelection('lp-column-' + id, sectionData["columns"][id]);
            return {
                id: 'column-' + id,
                element: $(row),
                sortPriority: id + 1,
                up: $(".column-fields-action-up", row),
                down: $(".column-fields-action-down", row)
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

        // orderManager.order.changes().onValue(function (changedFields) {
            // var up = changedFields.up;
            // var down = changedFields.down;

            // var upHidden = up.element.find(".custom-field-hidden-sort-priority");
            // var downHidden = down.element.find(".custom-field-hidden-sort-priority");

            // var newUpValue = downHidden.val();
            // var newDownValue = upHidden.val();

            // upHidden.val(newUpValue);
            // downHidden.val(newDownValue);
        // });

        var newOptionTmpl = _.template($("#new-column-tmpl").html());
        var $customFieldOptions = $("#columns");


        $("#column-add-button").click(function (e) {
            e.preventDefault();
            var id = "jsnew-" + nextId();
            var row = $(newOptionTmpl({
                id: id,
                sortPriority: nextSortPriority()
            }));
            $customFieldOptions.append(row);
            var newField = {
                id: id,
                element: row,
                up: $(".column-fields-action-up", row),
                down: $(".column-fields-action-down", row)
            };
            newOptionAdded();
            optionOrder.add(newField);
            addColumnValidation(id);
            initIconSelection('lp-' + id, {});
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
                var container = el.closest(".column-container");
                removeColumnValidation(container[0].id);
                container.remove();
                optionOrder.remove(container[0].id);

                count -= 1;
                update();
            }
        });

        function update() {
            enabled = count > minCount;

            if(count == 3){
                $("#column-add-button").hide();
            }
            else{
                $("#column-add-button").show();
            }

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

    function initSectionForm(sectionData, form_type) {
        var form_id = "#lp-form";
        var $form = $(form_id);
        $.validator.addMethod("invalidColor", function (value, element) {
            return this.optional(element) || (!value || (value && /^#[0-9A-F]{6}$/i.test(value)));
        }, "Enter valid hex code");
        formValidator = $form.validate({
            rules: getRules(sectionData),
            errorPlacement: function (error, element) {
                if (element.attr("name").includes("lp-fileupload")) {
                    error.insertAfter($(element).next())
                } else {
                    error.insertAfter(element);
                }
            },
            invalidHandler: function(form, validator) {
                if (!validator.numberOfInvalids())
                    return;

               $('html, body').animate({
                   scrollTop: ($(validator.errorList[0].element).offset().top-80)
               }, 200);
            },
            ignore: ":hidden, .ignore-validation",
            submitHandler: function (form, event) {

                submitForm(sectionData, form, form_type, false);

                return false;
            }
        });
    }

    function initForm(sectionData, lpData, form_type, url) {
        landingPageData = lpData;
        landingPageUrl = url;
        initColorPickerListeners(sectionData);
        initSectionForm(sectionData, form_type);
        addValidationToButtons(sectionData);
        var column_count = sectionData.columns ? sectionData.columns.length : 0;
        newOptionAdded = removeLinkEnabledState(column_count, 1, "#columns", ".column-field-option-remove").add;
        optionOrder = createColumnOrder(".column-container", sectionData);

    }

    function addValidationToButtons(sectionData){
        if(sectionData.kind == 'categories' && sectionData.enable_btn){
            window['ST']['landingPage']['enableBtn']({checked: true},"category", true);
        }
        if(sectionData.kind == 'listings' && sectionData.enable_btn){
            window['ST']['landingPage']['enableBtn']({checked: true},"listing", true);
        }
        if(sectionData.kind == 'locations' && sectionData.enable_btn){
            window['ST']['landingPage']['enableBtn']({checked: true},"location", true);
        }
        if(sectionData.kind == 'info' && sectionData.variation == 'single_column' && sectionData.enable_btn){
            window['ST']['landingPage']['enableBtn']({checked: true},"column-0", true);
        }
    }

    function initColorPickerListeners(sectionData){
        if(sectionData.kind == 'info' && sectionData.variation == 'single_column'){
            colorpickerListener("lp-column-0-button_color-picker","lp-column-0-button_color")
            colorpickerListener("lp-column-0-button_hover_color-picker","lp-column-0-button_hover_color")
        }
        if(sectionData.kind == 'categories'){
            colorpickerListener("lp-category-button_color-picker","lp-category-button_color")
            colorpickerListener("lp-category-button_hover_color-picker","lp-category-button_hover_color")
        }
        if(sectionData.kind == 'locations'){
            colorpickerListener("lp-location-button_color-picker","lp-location-button_color")
            colorpickerListener("lp-location-button_hover_color-picker","lp-location-button_hover_color")
        }
        if(sectionData.kind == 'listings'){
            colorpickerListener("lp-listing-button_color-picker","lp-listing-button_color")
            colorpickerListener("lp-listing-button_hover_color-picker","lp-listing-button_hover_color")
        }
    }

    function getRules(sectionData) {
        var rules;
        if (sectionData.kind == 'hero') {
            rules = {
                'lp-fileupload-1-image': {
                    required: true
                }
            }

        } else if (sectionData.kind == 'video') {
            rules = {
                'youtube_video_id': {
                    required: true
                },
                'height': {
                    required: true
                },
                'width': {
                    required: true
                },
                'text': {
                    required: true
                }
            }

        } else if (sectionData.kind == 'info' && sectionData.variation == 'single_column') {
            rules = {
                'title': {
                    required: true
                },
                'title-color': {
                    invalidColor: true
                },
                'paragraph': {
                    required: true
                },
                'paragraph-color': {
                    invalidColor: true
                },
                'description': {
                    required: true
                },
                'lp-fileupload-1-image': {
                    required: true
                },
                'background-color': {
                    required: true,
                    invalidColor: true
                },
                // 'background-variation': {
                //     required: true
                // },
                
            }
        } else if (sectionData.kind == 'info' && sectionData.variation == 'multi_column') {
            rules = {
                'title': {
                    required: true
                },
                'title-color': {
                    invalidColor: true
                },
                'column_title_color': {
                    invalidColor: true
                },
                'column_paragraph_color': {
                    invalidColor: true
                },
                'lp-fileupload-1-image': {
                    required: true
                },
                'background-color': {
                    required: true,
                    invalidColor: true
                },
                'button_color': {invalidColor: true},
                'button_color_hover': {invalidColor: true}
                // 'background-variation': {
                //     required: true
                // },
              
            }

        } else if (sectionData.kind == 'categories') {
            rules = {
                'title': {
                    required: true
                },
                'category_color_hover': {
                    required: true,
                    invalidColor: true
                }
            }

        } else if (sectionData.kind == 'locations') {
            rules = {
                'title': {
                    required: true
                },
                'location_color_hover': {
                    required: true,
                    invalidColor: true
                }
            }

        } else if (sectionData.kind == 'listings') {
            rules = {
                'title': {
                    required: true
                },
                'price_color': {
                    required: true,
                    invalidColor: true
                },
                'no_listing_image_text': {
                    required: true
                }
            }

        }
        return rules;
    }

    function submitForm(sectionData, form, form_type, preview) {
        var elements = form.elements;
        if (sectionData.kind == 'hero') {

            if (ST.lpImageUpload.checkUploadingStatus()) {
                toastr.info("Image uploading in progress");
                return;
            }

            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }


            section["background_image"] = {
                "src": form.elements["lp-fileupload-1-image"].value
            };
            section["background_image_variation"] = form.elements["background-variation"].value;


        } else if (sectionData.kind == 'video') {


            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["youtube_video_id"] = form.elements["youtube_video_id"].value;
            section["height"] = form.elements["height"].value;
            section["width"] = form.elements["width"].value;
            section["text"] = form.elements["text"].value;
            section["variation"] = "youtube";



        } else if (sectionData.kind == 'info' && sectionData.variation == 'single_column') {

            if (ST.lpImageUpload.checkUploadingStatus()) {
                toastr.info("Image uploading in progress");
                return;
            }
            var column = "lp-column-0";
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["title"] = elements["title"].value
            if (elements["background_type"].value == "bg-color") {
                if(elements["background-color"].value){
                    section["background_color"] = convertHexToRGB(elements["background-color"].value);
                    delete section["background_image"];
                    delete section["background_image_variation"];
                }
            } else if(elements["background_type"].value == "bg-image") {
                section["background_image"] = {
                    "src": form.elements["lp-fileupload-1-image"].value
                };
                section["background_image_variation"] = form.elements["background-variation"].value;
                delete section["background_color"];
            }
            else{
                delete section["background_image"];
                delete section["background_image_variation"];
                delete section["background_color"];

            }
            section["enable_btn"] = elements[column + "-enable_btn"].checked

            if (elements["lp-column-0-enable_btn"].checked) {
                section["button_color"] = {
                    "value": convertHexToRGB(elements[column + "-button_color"].value)
                };
                section["button_color_hover"] = {
                    "value": convertHexToRGB(elements[column + "-button_hover_color"].value)
                };
                section["button_title"] = elements[column + "-button_title"].value;
                section["button_path"] = {
                    "value": elements[column + "-button_path"].value
                };
            }
            section["paragraph"] = elements["description"].value;
            if(elements["paragraph-color"].value){
                section["paragraph_color"] = 
                {
                    "value":convertHexToRGB(elements["paragraph-color"].value)
                }
            }
            else{
                delete section["paragraph_color"];
            }
            if(elements["title-color"].value){
              section["title_color"] = {
                "value": convertHexToRGB(elements["title-color"].value)
              }
            }
            else{
                delete section["title_color"];
            }


        } else if (sectionData.kind == 'info' && sectionData.variation == 'multi_column') {
            var columnIndex;
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["title"] = elements["title"].value;
            if (elements["background_type"].value == "bg-color" ) {
                if(elements["background-color"].value){
                    section["background_color"] = convertHexToRGB(elements["background-color"].value);
                }
                delete section["background_image"];
                delete section["background_image_variation"];
            } else if(elements["background_type"].value == "bg-image") {
                section["background_image_variation"] = form.elements["background-variation"].value;
                section["background_image"] = {
                    "src": form.elements["lp-fileupload-1-image"].value
                };
                delete section["background_color"];
            }
            else{
                delete section["background_image"];
                delete section["background_image_variation"];
                delete section["background_color"];

            }
            section["columns"] = [];
            for (var index = 0; index < $(".column-container").length; index++) {
                columnIndex = "lp-" + $(".column-container")[index].id;
                section["columns"].push({});
                var columnData = section["columns"][index] = {};
                columnData["title"] = elements[columnIndex + "-title"].value;
                columnData["paragraph"] = elements[columnIndex + "-description"].value;
                columnData["icon"] = elements[columnIndex + "-icon-selection"].value;

                if (elements[columnIndex + "-enable_btn"].checked) {
                    columnData["enable_btn"] = elements[columnIndex + "-enable_btn"].checked;
                    columnData["button_title"] = elements[columnIndex + "-button_title"].value;
                    columnData["button_path"] = {
                        "value": elements[columnIndex + "-button_path"].value
                    };
                }
            }
           
            if(elements["title-color"].value){
              section["title_color"] = {"value": convertHexToRGB(elements["title-color"].value)}
            }
            else{
                delete section["title_color"];
            }
            if(elements["column_paragraph_color"].value){
                section["column_paragraph_color"] = {"value": convertHexToRGB(elements["column_paragraph_color"].value)}
            }
            else{
                delete section["column_paragraph_color"];
            }
            if(elements["column_title_color"].value){
              section["column_title_color"] = {"value": convertHexToRGB(elements["column_title_color"].value)}
            }
            else{
                delete section["column_title_color"];                
            }
            if(elements["icon_color"].value){
              section["icon_color"] = {"value": convertHexToRGB(elements["icon_color"].value)}
            }
            else{
                delete section["icon_color"];                
            }
            if(elements["button_color"].value){
                section["button_color"] = {"value": convertHexToRGB(elements["button_color"].value)}
            }
            else{
                delete section["button_color"];
            }
            if(elements["button_color_hover"].value){
                section["button_color_hover"] = {"value": convertHexToRGB(elements["button_color_hover"].value)}
            }
            else{
                delete section["button_color_hover"];
            }
            if(section["columns"].length > 3){
                toastr.error("You can add atmost 3 columns");
                return;
            }

        } else if (sectionData.kind == 'listings') {
            var column = "lp-listing";
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["title"] = elements["title"].value
            section["enable_btn"] = elements["lp-listing-enable_btn"].checked
            if (elements["lp-listing-enable_btn"].checked) {
                section["button_color"] = {
                    "value": convertHexToRGB(elements[column + "-button_color"].value)
                };
                section["button_color_hover"] = {
                    "value": convertHexToRGB(elements[column + "-button_hover_color"].value)
                };
                section["button_title"] = elements[column + "-button_title"].value;
                section["button_path"] = {
                    "value": elements[column + "-button_path"].value
                };
            }
            section["price_color"]= {"value": convertHexToRGB(elements["price_color"].value)};
            section["no_listing_image_text"]= {"value": elements["no_listing_image_text"].value};

            if (!listings || (listings && listings.length < 3)) {
                toastr.error("Kindly select exactly 3 listings");
                return;
            }
            section["listings"] = [];
            listings.forEach(function (id) {
                section["listings"].push({
                    "listing": {
                        "type": "listing",
                        "id": id
                    }
                })
            })
            if(elements["description"].value){
                section["paragraph"] = elements["description"].value;
            }
            else{
                delete section["paragraph"];
            }



        } else if (sectionData.kind == 'categories') {
            var column = "lp-category";
            if (ST.lpImageUpload.checkUploadingStatus()) {
                toastr.info("Image uploading in progress");
                return;
            }
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["title"] = elements["title"].value;
            if(elements["description"].value){
                section["paragraph"] = elements["description"].value;
            }
            else{
                delete section["paragraph"];
            }

            var categoryElements = $(".category-image-wrapper");
            if (!categoryElements || (categoryElements && categoryElements.length < 3)) {
                toastr.error("Kindly add 3 categories or more");
                return;
            }
            section["categories"] = [];
            var ids = ST.lpCategorySelection.sectionIds();
            for (var i = 0; i < ids.length; i++) {
                section["categories"].push({
                    "category": {
                        "type": "category",
                        "id": parseInt($(ids[i]["category_id"]).val(), 10)
                    },
                    "background_image": {
                        src: form.elements[ids[i]["image_input"]].value
                    }
                })
            }
            section["enable_btn"] = elements[column+"-enable_btn"].checked;
            if (elements[column+"-enable_btn"].checked) {
                section["button_color"] = {
                    "value": convertHexToRGB(elements[column + "-button_color"].value)
                };
                section["button_color_hover"] = {
                    "value": convertHexToRGB(elements[column + "-button_hover_color"].value)
                };
                section["button_title"] = elements[column + "-button_title"].value;
                section["button_path"] = {
                    "value": elements[column + "-button_path"].value
                };
            }
            if(section["categories"].length > 7){
                toastr.error("You can add atmost 7 categories");
                return;
            }
            section["category_color_hover"]= {"value": convertHexToRGB(elements["category_color_hover"].value)};


        } else if (sectionData.kind == 'locations') {
            var column = "lp-location";
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["title"] = elements["title"].value
            section["enable_btn"] = elements["lp-location-enable_btn"].checked
            if (elements["lp-location-enable_btn"].checked) {
                section["button_color"] = {
                    "value": convertHexToRGB(elements[column + "-button_color"].value)
                };
                section["button_color_hover"] = {
                    "value": convertHexToRGB(elements[column + "-button_hover_color"].value)
                };
                section["button_title"] = elements[column + "-button_title"].value;
                section["button_path"] = {
                    "value": elements[column + "-button_path"].value
                };
            }
            var locationCols = ST.lpLocationSection.sectionIds();
            if (!locationCols || (locationCols && locationCols.length < 3)) {
                toastr.error("Kindly select exactly 3 locations");
                return;
            }
            section["locations"] = [];
            locationCols.forEach(function (col) {
                section["locations"].push({
                    "location": form.elements[col["location_input"]].value,
                    "title": form.elements[col["title_input"]].value,
                    "background_image": {
                        src: form.elements[col["image_input"]].value
                    }
                })
            })
            if(elements["paragraph"].value){
                section["paragraph"] = elements["paragraph"].value;
            }
            else{
                delete section["paragraph"];
            }
            section["location_color_hover"]= {"value": convertHexToRGB(elements["location_color_hover"].value)};



        } else if (sectionData.kind == 'video') {
            // var column = "lp-location";
            if (form_type == 'edit_form') {
                var section = landingPageData.sections.find(function (value) {
                    return value.id == sectionData.id
                });
            } else {
                var section = JSON.parse(JSON.stringify(sectionData));
            }

            section["youtube_video_id"] = elements["youtube_video_id"].value
            section["height"] = elements["height"].value
            section["width"] = elements["width"].value
            section["text"] = elements["text"].value

        }

        newLandingPageData = JSON.parse(JSON.stringify(landingPageData));
        if (form_type == 'add_form') {
            newLandingPageData.sections.push(section);
            var length = newLandingPageData.composition.length;
            var footerData = JSON.parse(JSON.stringify(newLandingPageData.composition[length - 1]));
            newLandingPageData.composition[length - 1] = {
                "section": {
                    "type": "sections",
                    "id": section["id"],
                    "kind": section["kind"],
                    "title": section["title"]||""
                }
            };
            newLandingPageData.composition.push(footerData);
        }
        else if(form_type == 'edit_form'){
            var compositionrow = newLandingPageData.composition.find(function(data){
                return data["section"]["id"] == section["id"];
            })
            compositionrow["section"]["title"]= ((section["title"] && (typeof section["title"] == "string")) ? 
            section["title"] : "");
        }

        if (preview) {
            updatePreview(sectionData);
        } else {
            landingPageData = JSON.parse(JSON.stringify(newLandingPageData));
            updateLandingPageStructure(false, false, form_type)
        }

    }

    function enableBtn(value, columnId, addvalidatonToButtonColor) {
        
        if (value.checked) {

            if(addvalidatonToButtonColor){
                addValidationToInput("lp-" + columnId + "-button_color", {
                    required: true,
                    invalidColor: true
                })
                addValidationToInput("lp-" + columnId + "-button_hover_color", {
                    required: true,
                    invalidColor: true
                })
            }
           
            addValidationToInput("lp-" + columnId + "-button_title", {
                required: true
            })
            addValidationToInput("lp-" + columnId + "-button_path", {
                required: true
            })
        } else {
            
            if(addvalidatonToButtonColor){
              removeValidationFromInput("lp-" + columnId + "-button_color", "required");
              removeValidationFromInput("lp-" + columnId + "-button_color", "invalidColor");
              removeValidationFromInput("lp-" + columnId + "-button_hover_color", "required");
              removeValidationFromInput("lp-" + columnId + "-button_hover_color", "invalidColor");
              $("#lp-form").validate().element("#lp-" + columnId + "-button_color");
              $("#lp-form").validate().element("#lp-" + columnId + "-button_hover_color");
            }
            removeValidationFromInput("lp-" + columnId + "-button_title", "required");
            removeValidationFromInput("lp-" + columnId + "-button_path", "required");
           
            $("#lp-form").validate().element("#lp-" + columnId + "-button_title");
            $("#lp-form").validate().element("#lp-" + columnId + "-button_path");

        }

    }

    function addColumnValidation(columnId) {
        addValidationToInput("lp-" + columnId + "-title", {
            required: true
        })
        addValidationToInput("lp-" + columnId + "-description", {
            required: true
        })
        addValidationToInput("lp-" + columnId + "-button_color", {
            invalidColor: true
        })
        addValidationToInput("lp-" + columnId + "-button_hover_color", {
            invalidColor: true
        })
        if($("#lp-" + columnId +"-enable_btn")[0].checked){
            enableBtn({checked: true},columnId, false);
        }
    }

    function removeColumnValidation(columnId) {
        removeValidationFromInput("lp-" + columnId + "-title", "required");
        removeValidationFromInput("lp-" + columnId + "-description", "required");
    }



    function initListingSelection(selectedListing) {
        var ids = [];
        selectedListing.forEach(function (listingData) {
            ids.push(listingData["listing"]["id"])
        });
        listings = ids;
        var selectize = $('#listing-selection').selectize({
            plugins: ['remove_button'],
            maxItems: 3,
            items: ids
        })[0].selectize;
        selectize.on("change", function (value) {
            listings = value;
        });
    }

    function initIconSelection(selectId, columnData) {

        var ids = columnData["icon"] ? [columnData["icon"]] : null;
        var selectize = $('#' + selectId + "-icon-selection").selectize({
            plugins: ['remove_button'],
            maxItems: 1,
            options: window.ST.lpIcons.getIcons(),
            items: ids
        })[0].selectize;
        selectize.on("change", function (value) {
            listings = value;
        });
    }

    function addSection(e, url) {
        var section = JSON.parse(e.value);
        var ids = landingPageData.composition.map(function (section) {
            return section["section"]["id"]
        });
        var uniqueId = generateUniqueIds(ids);
        window.location.assign(url + '?kind=' + section.kind + (section.variation ? '&variation=' + section.variation : "") + '&id=' + section.kind + uniqueId);

    }

    function initList() {
        var fieldMap = $(".lp-section-row").map(function (id, row) {
            return {
                id: $(row).data("section-id"),
                element: $(row),
                up: $(".lp-action-up", row),
                down: $(".lp-action-down", row)
            };
        }).get();

        var orderManager = window.ST.orderManager(fieldMap);

        var ajaxRequest = orderManager.order.changes().debounce(1000)
            .skipDuplicates(_.isEqual)
            .onValue(function (order) {
            
                // newLandingPageData = JSON.parse(JSON.stringify(landingPageData));
                order["order"].forEach(function (section, sortIndex) {
                    var data = landingPageData.composition.find(function (sectionData) {
                        return sectionData["section"]["id"] == section;
                    })
                    newLandingPageData.composition[sortIndex + 1] = data;
                })
                landingPageData = JSON.parse(JSON.stringify(newLandingPageData));
                updateLandingPageStructure(false, false,"");
            });

    }

    function previewLandingPage(sectionData, form_type) {
        var isValid = $("#lp-form").validate().form();
        if(formValidator.numberOfInvalids()){
            $('html, body').animate({
                scrollTop: ($(formValidator.errorList[0].element).offset().top - 80)
            }, 100);
        }
       

        if (isValid) {
            submitForm(sectionData, $("#lp-form")[0], form_type, true)
        }
    }

    function updatePreview(sectionData) {
        var w = window.open();
        w.document.write("<html><head></head><body>Loading Preview.... if preview is not loaded in next 5 sec close " +
            "this window and click on button again</body><script></script></html>");
        disablePreviewButton();
        $.ajax({
            type: "POST",
            url: window.location.origin + '/admin/manage_landing_page/preview',
            data: {
                'content': JSON.stringify(newLandingPageData)
            },
            success: function (res) {
                enablePreviewButton();
                w.location.href = window.location.origin + "/_lp_preview" + (sectionData ? "#" + sectionData.kind + "__" + sectionData.id : "");

            },
            error: function () {
                enablePreviewButton();
            },
            dataType: 'json'
        });


    }

    function disablePreviewButton() {
        // debugger;
        $("#preview-btn").attr('disabled', 'disabled');
        $("#preview-btn").text("Waiting..");

    }

    function enablePreviewButton() {
        $("#preview-btn").attr('disabled', false);
        $("#preview-btn").text("Preview");
        // $("#window-btn").show();
    }

    function openPreviewWindow(sectionData) {
        $("#window-btn").hide();
        window.open(window.location.origin + "/_lp_preview#" + sectionData.kind + "__" + sectionData.id);

    }

    function enableDisableLandingPage(event) {
        var target = event.target;
        if (target.checked) {
            if (confirm("Are you sure you want to enable the landing page ?")) {
                updateStatus(event);
            } else {
                target.checked = !target.checked;
                return true;
            }

        } else {
            if (confirm("Are you sure you want to disable the landing page ?")) {
                updateStatus(event);
            } else {
                target.checked = !target.checked;
                return true;
            }

        }
    }

    function updateStatus(event) {
        clearTimeout(notificationTimeout);
        showUpdateNotification();
        $.ajax({
            'url': window.location.origin + '/admin/manage_landing_page/enable_disable_lp?time=' + new Date().getTime(),
            'type': 'GET',
            dataType: 'json',
            success: function (res) {
                showUpdateSuccess()
                notificationTimeout = setTimeout(function () {
                    showUpdateIdle();
                }, 400)
            },
            error: function (res) {
                showUpdateError();
                notificationTimeout = setTimeout(function () {
                    showUpdateIdle();
                }, 400)
            }
        })

    }

    var showUpdateNotification = function () {
        $(".ajax-update-notification").show();
        $("#landing-page-saving-enable-disable").show();
        $("#landing-page-error-enable-disable").hide();
        $("#landing-page-saved-enable-disable").hide();
    };

    var showUpdateSuccess = function () {
        $("#landing-page-saving-enable-disable").hide();
        $("#landing-page-saved-enable-disable").show();
    };

    var showUpdateError = function () {
        $("#landing-page-saving-enable-disable").hide();
        $("#landing-page-error-enable-disable").show();
    };

    var showUpdateIdle = function () {
        $(".ajax-update-notification").fadeOut();
    };

    var deleteSection = function (event,deletedSection) {
        event.preventDefault();
        if (confirm("Are you sure you want to delete this section of landingPage ?")) {
            newLandingPageData = JSON.parse(JSON.stringify(landingPageData));
            newLandingPageData.sections = newLandingPageData.sections.filter(function (section) {
                return section.id != deletedSection.section.id
            })
            newLandingPageData.composition = newLandingPageData.composition.filter(function (composition) {
                return composition["section"]["id"] != deletedSection.section.id
            })
            landingPageData = JSON.parse(JSON.stringify(newLandingPageData));
            updateLandingPageStructure(true,true,"");
        }
    }

    function editFooter(url){
        window.location.assign(window.location.origin+url);

    }
     
    function colorpickerListener(colorpickerId,inputId){
        document.getElementById(colorpickerId).addEventListener("input",function(event){
            document.getElementById(inputId).value = event.target.value;
        });
    }

    function openColorPicker(colorpickerId){
        document.getElementById(colorpickerId).click();
    }
    module.landingPage = {
        intialize: intialize,
        initForm: initForm,
        enableBtn: enableBtn,
        edit: edit,
        initListingSelection: initListingSelection,
        addSection: addSection,
        previewLandingPage: previewLandingPage,
        addColumnValidation: addColumnValidation,
        initList: initList,
        enableDisableLandingPage: enableDisableLandingPage,
        openPreviewWindow: openPreviewWindow,
        deleteSection: deleteSection,
        editFooter: editFooter,
        updatePreview: updatePreview,
        colorpickerListener: colorpickerListener,
        openColorPicker: openColorPicker
    };
})(window.ST);