window.ST = window.ST || {};

(function (module) {

    var sectionIds = [];
    function initCategorySelection(categoryId, select_id, input_id) {
        
        var selectize = $(select_id).selectize({
            items: categoryId ? [categoryId] : []
        })[0].selectize;

    }

    function initializeCategoryElements() {

        var newOptionTmpl = _.template($("#new-column-tmpl").html());
        var $customFieldOptions = $("#category-container");

        var nextId = (function () {
            var i = 0;
            return function () {
                i += 1;
                return i;
            };
        })();


        $("#category-add-button").click(function (e) {
            e.preventDefault();
            var id = "jsnew-" + nextId();
            select_id = "#category-selection-" + id;
            input_id = "lp-fileupload-" + id + "-image";
            sectionIds.push({category_id: select_id,image_input: input_id});
            
            var row = $(newOptionTmpl({
                id: id
            }));
            $customFieldOptions.append(row);
            addValidationToInput("lp-fileupload-" + id + "-input",{required: true});
            initCategorySelection(null, "#category-selection-" + id, "lp-fileupload-"+id+"-image");
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
                sectionIds = sectionIds.filter(function(section){ return !section.category_id.includes(event.currentTarget.id)});
                var container = el.closest(".category-image-wrapper");
                // removeColumnValidation(container[0].id);
                removeValidationFromInput("lp-fileupload-"+event.currentTarget.id+"-input","required");

                container.remove();

                count -= 1;
                update();
            }
        });

        function update() {
            enabled = count > minCount;
            if(count == 7){
                $("#category-add-button").hide();
            }
            else{
                $("#category-add-button").show();
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

    function initCategoryForm(sectionData) {
        var column_count = sectionData.categories ? sectionData.categories.length : 0;
        newOptionAdded = removeLinkEnabledState(column_count, 3, "#categories", ".category-field-option-remove").add
        initializeCategoryElements();
        sectionData.categories.forEach(function (category, index) {
            var categoryId = category["category"]["id"]
            sectionIds.push({category_id: "#category-selection-column-" + index,image_input: "lp-fileupload-column-"+index+"-image"})
            addValidationToInput("lp-fileupload-column-"+index+"-input",{required: true});
            initCategorySelection(categoryId, "#category-selection-column-" + index, "lp-fileupload-column-"+index+"-image")
        })

    }


    function getSectionIds(){
        return sectionIds;
    }
    module.lpCategorySelection = {
        initCategorySelection: initCategorySelection,
        initCategoryForm: initCategoryForm,
        sectionIds: getSectionIds
    };
})(window.ST);