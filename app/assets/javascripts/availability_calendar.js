window.ST = window.ST || {};

(function(module) {

  var dateAtBeginningOfDay = function(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
  };

  var pad = function(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
  };

  // this ignores time zone
  var dateToString = function(date,char) {
    return date.getFullYear() + char + pad((date.getMonth() + 1), 2) + char +  pad(date.getDate(), 2);
  };

  var nextYear = function(){
      return new Date(new Date().setYear(new Date().getFullYear() + 1))
  }

  function setupListingCalendar(options){

    var blockedDates = options.blockedDates || [];

      $("#avail_dates").datepicker({
          'multidate': true,
          'startDate': new Date(),
          'endDate': nextYear(),
          'format': 'yyyy-mm-dd'
      });
      $("#avail_dates").datepicker('setDate',blockedDates);
      $('#avail_dates_input').val(JSON.stringify(blockedDates));
      
      $('#avail_dates').on('changeDate', function() {
    
        var dates = $('#avail_dates').datepicker('getFormattedDate');
        var datesArray =  dates ? dates.split(',') : [];
        $('#avail_dates_input').val(JSON.stringify(datesArray));
    });
  }

  function toggleCalendar(selectedUnit){
    var listingUnitType;
    try{
      listingUnitType = JSON.parse(selectedUnit.value).unit_type;
    }
    catch(e){
      listingUnitType = '';
    }
    if(listingUnitType == 'day' || listingUnitType == 'night'){
      $('#avail_calendar').show();
      $('#listing_min_booking_days').show();
    }
    else{
      $('#avail_calendar').hide();
      $('#listing_min_booking_days').hide();
    }


  }

  module.listingCalendar = {
    setupListingCalendar: setupListingCalendar,
    toggleCalendar: toggleCalendar
  };
})(window.ST);
