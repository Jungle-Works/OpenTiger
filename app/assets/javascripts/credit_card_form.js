window.ST = window.ST || {};

(function (module) {

    var communityId,cardNumberEl;
    var selectedCard = {};
    var elementStyles={base:{color:"#424770",fontFamily:"Quicksand, Open Sans, Segoe UI, sans-serif",fontSize:"14px","::placeholder":{color:"#CFD7DF"},":-webkit-autofill":{color:"#e39f48"}},invalid:{color:"#E25950","::placeholder":{color:"#FFCCA5"}}};
    function checkCardNumberErrors(value) {
        // var value = e.target.value;
        if (!value) {
            $('#card-number-input').addClass('has-error');
            $('.card-no > .errors').html('Field is required');
            return true;
        } else {
            $('#card-number-input').removeClass('has-error');
            $('.card-no > .errors').html('');
            return false;
        }

    }

    function checkCardCvvErrors(value) {
        if (!value) {
            $('#card-cvv-input').addClass('has-error');
            return true;

        } else {
            $('#card-cvv-input').removeClass('has-error');
            return false;

        }
    }

    function checkDateValidation(value) {
        var now = new Date();
        var nowMonth = now.getMonth() + 1;
        var nowYear = now.getFullYear().toString().substring(2);
        var dates = value.split('/');

        if (dates[0] >= 1 && dates[0] <= 12) {
            var expired = (nowYear > dates[1]) || ((nowYear == dates[1]) && (nowMonth > dates[0]))
            if (expired) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    function checkExpDateErrors(value) {
        if (!value) {
            $('#exp-date-input').addClass('has-error');
            $('.exp-date > .errors').html('Field is required');
            return true;

        } else if (value && value.length == 5 && checkDateValidation(value)) {

            $('#exp-date-input').addClass('has-error');
            $('.exp-date > .errors').html('Enter valid expiration date');
            return true;


        } else {
            $('#exp-date-input').removeClass('has-error');
            $('.exp-date > .errors').html('');
            return false;

        }
    }

    function setBillingCardData(card){
        $("#card-no-value").text(card.last4);
        $("#exp-date-value").text(card.exp_month+'/'+card.exp_year.toString().substring(2));
        $("#cvv-value").text("XXX");

    }
    
    function initializeCreditCardForm(id,card) {
        // debugger;
        communityId = id;
        selectedCard = card;
        var form = document.getElementById('addCardForm');
        $('#addCardForm').on('submit', function ($event) {
       
            if (checkCardNumberErrors($('#card-number-input').val()) &&
                checkCardCvvErrors($('#card-cvv-input').val()) &&
                checkExpDateErrors($('#exp-date-input').val())) {

            } else {
              addCardApiHit(form);
            }

            $event.preventDefault();
        })
        $('#card-number-input').on('input blur', function ($event) {
            checkCardNumberErrors($event.target.value);

        })
        $('#card-cvv-input').on('input blur', function ($event) {
            checkCardCvvErrors($event.target.value);
        })
        $('#exp-date-input').on('input blur', function ($event) {
            checkExpDateErrors($event.target.value);
        })

        cancelButtonListener();
        changeCardBtnListener();
        if(card){
            window.ST.communityPlan.cardData = card;
            setBillingCardData(card);
            $("#billingCard").show();
        }
        else{
            $("#add-btn").show();
        }
    }

   
    function addCardApiHit(cardData){
        disableSubmitButton();
        $.ajax({
            type: "POST",
            url: window.location.origin + '/admin/community_plans/add_card',
            data: {
                'payment_method': cardData.payment_method
                // 'card': {
                //     'number': form.elements.card_number.value,
                //     'exp_month': form.elements.exp_date.value.split('/')[0],
                //     'exp_year': form.elements.exp_date.value.split('/')[1],
                //     'cvc': form.elements.cvv.value
                // },
                // 'community_id': communityId
            },
            success: successCallback,
            error: errorCallback,
            dataType: 'json'
        });
    }
    function errorCallback(res) {
     
        toastr.error(res.message,"Error");
        enableSubmitButton();
    }

    function successCallback(res) {
        if(res.status == 200){
            var newCardData = {
                last4: res.data[0].last4_digits,
                exp_month: res.data[0].expiry_date.split("-")[0],
                exp_year: res.data[0].expiry_date.split("-")[1]
            }
            toastr.success(res.message,"Success");
            selectedCard = newCardData;
            window.ST.communityPlan.cardData = JSON.parse(JSON.stringify(selectedCard));
            $("#addCardForm").resetForm();
            enableSubmitButton();
            setBillingCardData(newCardData);
            $("#addCardForm").hide();
            $("#billingCard").show();
        }
        else{
            errorCallback(res);
        }
        
    }

    function disableSubmitButton(){
        // debugger;
        $("#update-btn").attr('disabled', 'disabled');
        var json = ST.jsonTranslations;
        $("#update-btn").text(json.please_wait);
        $("#cancel-btn").hide();
    }
    function enableSubmitButton(){
        $("#update-btn").attr('disabled', false);
        var json = ST.jsonTranslations;
        $("#update-btn").text("Update Card");
        $("#cancel-btn").show();
    }

    function addCard() {
        $("#addCardForm")[0].style.display = 'block';
        $("#add-btn")[0].style.display = 'none';

    }

    function initStripeForm(id,card,access_token,name){
        loadStripe().then(function(){
            var elements = stripeV3.elements();
            cardNumberEl = elements.create('cardNumber', { style: this.elementStyles });
            cardNumberEl.mount('#card-number');
            elements.create('cardCvc', { style: this.elementStyles }).mount('#cvv');
            elements.create('cardExpiry', { style: this.elementStyles }).mount('#expiry-date');
        });
        communityId = id;
        selectedCard = card.last4||null;
        
        $('#addCardForm').on('submit', function ($event) {
            disableSubmitButton();
            $.ajax({
                type: "POST",
                url: window.location.origin + '/admin/community_plans/setup_intent',
                data: {
                    'access_token': access_token
                },
                success: function(res){
                    if(res.status == 200){

                        saveCard(res.data,name);
                    }
                    else{
                        enableSubmitButton();
                    }
                },
                error: function(){
                    enableSubmitButton();
                    
                },
                dataType: 'json'
            });
            
      
            

            $event.preventDefault();
        })


        cancelButtonListener();
        changeCardBtnListener();
        
        if(card.last4){
            window.ST.communityPlan.cardData = card;
            setBillingCardData(card);
            $("#billingCard").show();
        }
        else{
            $("#add-btn").show();
        }
    }

    function cancelButtonListener(){

        $("#cancel-btn").click(function () {
            if(selectedCard){
                $("#billingCard").show();
                $("#addCardForm").hide();
            }
            else{
                $("#addCardForm").hide();
                $("#add-btn").show();
            }
        })
    }

    function changeCardBtnListener(){
        $("#change-card-btn").click(function () {
            $("#billingCard")[0].style.display = 'none';
            $("#addCardForm")[0].style.display = 'block';
        })
    }

    function saveCard(intentData,name){
        stripeV3.handleCardSetup(intentData.id, cardNumberEl, {
            payment_method_data: {
              billing_details: { name:  name}
            }
          }
          ).then(function(response){
      
              if (response.error) { // Problem!
                toastr.error(response.error.message,"Error");
                enableSubmitButton();
                return;
              }
              addCardApiHit(response.setupIntent);
            });
    }


    module.creditCardForm = {
        initializeCreditCardForm: initializeCreditCardForm,
        addCard: addCard,
        initStripeForm: initStripeForm

    };
})(window.ST);