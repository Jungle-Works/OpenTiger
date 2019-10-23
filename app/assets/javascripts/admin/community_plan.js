window.ST = window.ST || {};

(function (module) {

    var newSelectedPlan;
    var communityId = '';
    var currentSelectedPlan;


    function initializeChoosePlan(currentPlanDetail, planExpired) {
      $('.monthly-plan').addClass('selected');
      $('.year-wise').hide();
      $('.month-wise').show();
      currentSelectedPlan = currentPlanDetail;
      if (planExpired) {
        $('.select-plans-container')[0].style.display = 'block';
      }
      $("#choose-plan-" + currentSelectedPlan.id).text("CURRENT PLAN").attr("disabled", true);
    }


    function changePlan(id) {
      $('.select-plans-container')[0].style.display = 'block';
    }

    function selectPlan(type, planDetail, community_id) {
      if (window.ST.communityPlan.cardData) {

        newSelectedPlan = planDetail;
        if (checkForDowngradePlan(planDetail)) {
          return false;
        }
        // console.log(card);
        $("#plan-content").hide();
        $("#confirm-plan-dialog").show();
        communityId = community_id;
        if (planDetail.plan_code == "free") {
          $(".content > .body > .message").html('Please confirm that you would like to go ahead with the Free Forever plan.')
        } else if (type == 'annualy')
          $(".content > .body > .message").html('An amount of $' + ((planDetail.cost * 12).toFixed(2)) + '( $' + planDetail.cost + '* 12 ) will be charged to enable the ' + planDetail.plan_name + 'plan on your account')
        else
          $(".content > .body > .message").html('This will enable the Monthly Premium plan for your account. An amount of $ ' + planDetail.cost + ' will be charged for this month.')

      } else {
        if (planDetail.plan_code == "free") {
          newSelectedPlan = planDetail;
          $("#plan-content").hide();
          $("#confirm-plan-dialog").show();
          communityId = community_id;
          $(".content > .body > .message").html('Please confirm that you would like to go ahead with the Free Forever plan.')
        } else {

          $('.select-plans-container')[0].style.display = 'none';
          toastr.error("Kindly add your card first.")
        }

      }
    }

    function selectPlanType(plantype) {
      if (plantype == 'monthly') {
        $('.monthly-plan').addClass('selected');
        $('.annual-plan').removeClass('selected');
        $('.year-wise').hide();
        $('.month-wise').show();
      } else {
        $('.monthly-plan').removeClass('selected');
        $('.annual-plan').addClass('selected');
        $('.month-wise').hide();
        $('.year-wise').show();
      }
    }

    function showPlanTypes() {
      $("#plan-content").show();
      $("#confirm-plan-dialog").hide();
    }

    function proceedWithPlan() {
      disableSubmitButton();

      $.ajax({
        type: "POST",
        url: window.location.origin + '/admin/community_plans/' + newSelectedPlan.id + '/change_plan',
        data: {

          'community_id': communityId
        },
        success: successCallback,
        error: errorCallback,
        dataType: 'json'
      });
    }

    function errorCallback(res) {

      toastr.error(res.message, "Error");
      enableSubmitButton();
    }

    function successCallback(res) {
      if (res.status == 200) {
       
        afterPlanSelectSuccess(res);

      } else {
        if (res.data.transaction_status == 402) {
          makePayment(res["data"], newSelectedPlan.id);
          return;
        }
        errorCallback(res);
      }

    }

    function disableSubmitButton() {
      // debugger;
      $("#plan-proceed-btn").attr('disabled', 'disabled');
      var json = ST.jsonTranslations;
      $("#plan-proceed-btn").text(json.please_wait);
      $("#plan-cancel-btn").hide();
    }

    function enableSubmitButton() {
      $("#plan-proceed-btn").attr('disabled', false);
      var json = ST.jsonTranslations;
      $("#plan-proceed-btn").text("PROCEED");
      $("#plan-cancel-btn").show();
    }

    function closeSelectPlan() {
      $('.select-plans-container')[0].style.display = 'none';

    }

    function closePlanExpiration() {
      $.ajax({
        type: "GET",
        url: window.location.origin + '/admin/community_plans/warning_popup_viewed',
        success: function () {},
        error: function () {},
        dataType: 'json'
      });

      $(".plan-expiration-container").hide();
    }

    function redirectToBilling(billingPath) {
      $.ajax({
        type: "GET",
        url: window.location.origin + '/admin/community_plans/warning_popup_viewed',
        success: function () {
          window.location = window.location.origin + billingPath;
        },
        error: function () {
          window.location = window.location.origin + billingPath;

        },
        dataType: 'json'
      });
      $("#plan-expiration-btn").attr('disabled', 'disabled');
      var json = ST.jsonTranslations;
      $("#plan-expiration-btn").text(json.please_wait);


    }

    function checkForDowngradePlan() {
      if (newSelectedPlan["billing_frequency"] >= currentSelectedPlan["billing_frequency"] &&
        newSelectedPlan["plan_type"] >= currentSelectedPlan["plan_type"]) {
        return false;
      } else {
        toastr.error("Please wait we are connecting you with our support team to downgrade your plan");
        $(".select-plans-container").hide();
        message = 'Hi, Please help me get a plan for my business. Assist me with the same.';
        transaction_id = 'MonthlyPlan'
        startConversation(['MonthlyPlan'], transaction_id, message)
        return true;
      }
    }



    function startConversation(tags, plan, message) {
      newinitFugu().then(function () {
        window.startConversation({
          'tags': tags,
          'transaction_id': plan + currentUser['id'],
          'user_id': currentUser['id'],
          'defaultMessage': message
        });
      })
    }

    function contactHippo() {
      $("#chat-widgets").hide();
      $('.select-plans-container')[0].style.display = 'none';
      if (currentSelectedPlan.billing_frequency == 1) {
        startConversation(['MonthlyPlan'], 'MonthlyPlan', 'Hi, Please help me get a monthly plan for my business. Assist me with the same.');
      } else {
        startConversation(['AnnualPlan'], 'AnnualPlan', 'Hi, Please help me get a annual plan for my business. Assist me with the same.');

      }
    }

    function makePayment(intent, plan_id) {

      loadStripe().then(function () {

          stripeV3.handleCardPayment(
            intent.client_secret, {
              payment_method: intent.payment_method || intent.card_token,
            }
          ).then(function(result){
            if (result.error) {
              // this.stripePaymentAuthorize = "initial";
              enableSubmitButton();
              toastr.error(result.error.message,"Error");

            } else {
              toastr.success(result.message, "Success");
              $.ajax({
                type: "GET",
                url: window.location.origin + '/admin/community_plans/current_user_plan',
                success: function (res) {
                  afterPlanSelectSuccess(res)
                },
                error: function () {},
                dataType: 'json'
              });
              // this.getCardData(true, plan_type);
              // The payment has succeeded. Display a success message.
            }
          });
          
        });
      }

      function afterPlanSelectSuccess(res){
        toastr.success(res.message, "Success");
        $("#choose-plan-" + currentSelectedPlan.id).text("CHOOSE PLAN").attr("disabled", false);
        currentSelectedPlan = newSelectedPlan;
        $("#choose-plan-" + currentSelectedPlan.id).text("CURRENT PLAN").attr("disabled", true);
        $(".plan-name > .value").text(newSelectedPlan.plan_name);
        $(".plan-billing-date > .value").text(newSelectedPlan.plan_code == 'free' ? '-' : res.data.expiry_datetime);
        $('.select-plans-container')[0].style.display = 'none';
        $("#plan-content").show();
        $("#confirm-plan-dialog").hide();
        enableSubmitButton();
      }

      module.communityPlan = {
        initializeChoosePlan: initializeChoosePlan,
        changePlan: changePlan,
        selectPlan: selectPlan,
        selectPlanType: selectPlanType,
        showPlanTypes: showPlanTypes,
        proceedWithPlan: proceedWithPlan,
        closeSelectPlan: closeSelectPlan,
        closePlanExpiration: closePlanExpiration,
        redirectToBilling: redirectToBilling,
        contactHippo: contactHippo,
        cardData: ''

      };
    })(window.ST);