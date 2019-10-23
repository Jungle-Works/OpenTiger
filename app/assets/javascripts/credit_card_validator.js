window.ST = window.ST || {};

(function (module) {

    var oldValue, newValue, oldCursor, newCursorPosition;

    /**
     * To get count of spaces b/w pair of characters
     * @param position 
     * @param interval 
     */
    function checkSeparator(position, interval) {
        return Math.floor(position / (interval + 1));
    }

    function mask(value,seperator,position) {
        var output = [];
        for (var i = 0; i < value.length; i++) {
            if (i !== 0 && i % position === 0) {
                output.push(seperator); // add the separator
            }
            output.push(value[i]);
        }
        return output.join('');
    }

    function unmask(value) {
        var output = value.replace(new RegExp(/[^\d]/, 'g'), ''); // Remove every non-digit character
        return output;
    }


    function restrictCardNumberInput(id) {

        $(id).on('keydown', function (event) {
            oldValue = event.target.value;
            oldCursor = event.target.selectionEnd;
        });


        $(id).on('input', function (event) {
            var el = event.target;
            newValue = el.value;

            /**
             * Check for deletion of seperator
             */
            if (oldValue[event.target.selectionEnd] == ' ') {
                var charArray = newValue.split('');
                charArray.splice(event.target.selectionEnd - 1, 1);
                newValue = charArray.join('');
            }

            newValue = unmask(newValue);
            if (newValue.match(/^\d{0,20}$/g)) {
                newValue = mask(newValue,' ',4);
                newCursorPosition = oldCursor - checkSeparator(oldCursor, 4) +
                    checkSeparator(oldCursor + (newValue.length - oldValue.length), 4) +
                    (unmask(newValue).length - unmask(oldValue).length);
                if (newValue !== "") {
                    el.value = newValue;
                } else {
                    el.value = "";
                }
            } else {
                el.value = oldValue;
                newCursorPosition = oldCursor;
            }
            el.setSelectionRange(newCursorPosition, newCursorPosition);

        });

    }

    function setupListingCalendar(options) {

        var blockedDates = options.blockedDates || [];

        $("#avail_dates").datepicker({
            'multidate': true,
            'startDate': new Date(),
            'endDate': nextYear(),
            'format': 'yyyy-mm-dd'
        });
        $("#avail_dates").datepicker('setDate', blockedDates);
        $('#avail_dates_input').val(JSON.stringify(blockedDates));

        $('#avail_dates').on('changeDate', function () {

            var dates = $('#avail_dates').datepicker('getFormattedDate');
            var datesArray = dates ? dates.split(',') : [];
            $('#avail_dates_input').val(JSON.stringify(datesArray));
        });
    }


    function restrictExpDateInput(id) {
        // console.log(id);
        var oldValue = '';
        var newValue = '';
        var oldCursor, newCursorPosition;

        $(id).bind('keydown', function (event) {
            oldValue = event.target.value;
            oldCursor = event.target.selectionEnd;

        });

        $(id).bind('input', function (event) {
            var el = event.target;
            newValue = el.value;

            /**
             * Check for deletion of seperator
             */
            if (oldValue[event.target.selectionEnd] == '/') {
                var charArray = newValue.split('');
                charArray.splice(event.target.selectionEnd - 1, 1);
                newValue = charArray.join('');
            }

            newValue = unmask(newValue);
            if (newValue.match(/^\d{0,4}$/g)) {
                newValue = mask(newValue,'/',2);
                newCursorPosition = oldCursor - checkSeparator(oldCursor, 2) +
                    checkSeparator(oldCursor + (newValue.length - oldValue.length), 2) +
                    (unmask(newValue).length - unmask(oldValue).length);
                if (newValue !== "") {
                    el.value = newValue;
                } else {
                    el.value = "";
                }
            } else {
                el.value = oldValue;
                newCursorPosition = oldCursor;
            }
            el.setSelectionRange(newCursorPosition, newCursorPosition);
        })
    }

    function restrictCvvInput(id) {
        // console.log(id);
        var oldValue = '';
        var newValue = '';

        $(id).bind('keydown', function (event) {
            oldValue = event.target.value;
        });

        $(id).bind('input', function (event) {
            var el = event.target;
            newValue = el.value;
            if (newValue.match(/^[0-9]*$/)) {
                el.value = newValue;
            } else {
                el.value = oldValue;
            }
            
    
    
        })
    }

    function submitCardForm(event){
        // debugger;
        var form = document.getElementById('addCardForm');
        console.log(form.validity,event);
        event.preventDefault();
        return false;
    }



    module.creditCard = {
        restrictCardNumberInput: restrictCardNumberInput,
        restrictExpDateInput: restrictExpDateInput,
        restrictCvvInput: restrictCvvInput,
        submitCardForm: submitCardForm

    };
})(window.ST);