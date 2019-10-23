
var nowDate = new Date(); 
var today = new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), 0, 0, 0, 0);


$(function() {
    
    var params = getUrlParams(window.location.href);
    if(params.selected_range)
    {
        var sel_dt_rng = params.selected_range.split("+-+");
        
        sel_st_dt = sel_dt_rng[0];
        sel_ed_dt = sel_dt_rng[1];
        var new_date=sel_st_dt.split("-");
        var new_date1=sel_ed_dt.split("-");
        var year1=new_date[0];
        var month1=new_date[1];
        var day1=new_date[2];
        var year2=new_date1[0];
        var month2=new_date1[1];
        var day2=new_date1[2];
        
        var sel_start_date = month1+ '-' +day1 +'-' +year1;
        var sel_end_date = month2+ '-' +day2 +'-' +year2;
    }
    
    $('#choose-dates').daterangepicker({
        startDate: sel_start_date,
        endDate: sel_end_date,
        minDate: today,
        autoUpdateInput: true,
        locale: {
            cancelLabel: 'Clear'
        }
        
    });

    $('#choose-dates').on('apply.daterangepicker', function(ev, picker) {
    
        $('#selected-date-range').val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
        $("#homepage-filters").submit();
  
    });
  
    $('#choose-dates').on('cancel.daterangepicker', function(ev, picker) {
        
        $('#selected-date-range').val('');
        $("#homepage-filters").submit();
    });
  
  });
  