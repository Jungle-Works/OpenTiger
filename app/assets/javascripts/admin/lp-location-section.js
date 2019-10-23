window.ST = window.ST || {};

(function (module) {

    var sectionIds = [];

    function initializeLocationElements() {

        var newOptionTmpl = _.template($("#new-column-tmpl").html());
        var $customFieldOptions = $("#location-container");

        var nextId = (function () {
            var i = 0;
            return function () {
                i += 1;
                return i;
            };
        })();


        $("#location-add-button").click(function (e) {
            e.preventDefault();
            var id = "jsnew-" + nextId();
            sectionIds.push({location_input: "lp-column-" + id + "-location",title_input: "lp-column-" + id + "-title",image_input: "lp-fileupload-"+id+"-image"})
            
            
            var row = $(newOptionTmpl({
                id: id
            }));
            $customFieldOptions.append(row);
            
            addValidationToLocationColumn( "lp-column-" + id + "-location","lp-column-" + id + "-title","lp-fileupload-"+id+"-input")
            newOptionAdded();
        });
    }

    var removeLinkEnabledState = function (initialCount, minCount, containerSelector, linkSelector) {
        var enabled;
        var count = initialCount;
        update();
        $(containerSelector).on("click", linkSelector, function (event) {
            event.preventDefault();

            if (enabled) {

                var el = $(event.currentTarget);
                var id = event.currentTarget.id;
                sectionIds = sectionIds.filter(function(section){ return !section.location_input.includes(id)});
                var container = el.closest(".location-image-wrapper");
                removeValidationFromLocationColumn( "lp-" + id + "-location","lp-" + id + "-title","lp-fileupload-"+id+"-input")

                // removeColumnValidation(container[0].id);
                container.remove();

                count -= 1;
                update();
            }
        });

        function update() {
            enabled = count > minCount;
            if(count == 7){
                $("#location-add-button").hide();
            }
            else{
                $("#location-add-button").show();
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

    function initLocationForm(sectionData) {
        var column_count = sectionData.locations ? sectionData.locations.length : 0;
        newOptionAdded = removeLinkEnabledState(column_count, 3, "#locations", ".location-field-option-remove").add
        initializeLocationElements();
        sectionData.locations.forEach(function(location,index){
            addValidationToLocationColumn( "lp-column-" + index + "-location","lp-column-" + index + "-title","lp-fileupload-column-"+index+"-input")
            sectionIds.push({location_input: "lp-column-" + index + "-location",title_input: "lp-column-" + index + "-title",image_input: "lp-fileupload-column-"+index+"-image"})
        })

    }
    function addValidationToLocationColumn(locationId, titleId, imageId){
        addValidationToInput(locationId,{required: true})
        addValidationToInput(titleId,{required: true})
        addValidationToInput(imageId,{required: true})
    }

    function removeValidationFromLocationColumn(locationId, titleId, imageId){
        removeValidationFromInput(locationId,"required");
        removeValidationFromInput(titleId,"required");
        removeValidationFromInput(imageId,"required");
    }

    function getSectionIds(){
        return sectionIds;
    }

    module.lpLocationSection = {
        initLocationForm: initLocationForm,
        sectionIds: getSectionIds
    };
})(window.ST);