window.ST = window.ST || {};

/**
  Initialize range slider filter

  ## Params:

  - `selector`: Selector
  - `range`: [min, max] array
  - `start`: [startValueMin, startValueMax]
  - `labels`: [labelElementMin, labelElementMax]
  - `fields`: [inputFieldMin, inputFieldMax]
  - `decimals: boolean allow decimals
*/

var oldStartValues;
var customFilterRange;

window.ST.rangeFilter = function(selector, range, start, labels, fields, decimals) {
  oldStartValues = start;
  customFilterRange = range;
  function decimalPlaces(number) {
    // The ^-?\d*\. strips off any sign, integer portion, and decimal point
    // leaving only the decimal fraction.
    return ((+number).toString()).replace(/^-?\d*\.?/g, '').length;
  }

  function numberOfDecimals(){
    if(decimals){
      var num_of_decimals = Math.max.apply(null, range.map(decimalPlaces));
      return 1 / Math.pow(10, num_of_decimals);
    }else{
      return 1;
    }
  }

  function updateLabel(el) {
    return function(val) {
      el.html(val);
    };
  }


  var step = numberOfDecimals();

  $(selector).noUiSlider({
    range: range,
    step: step,
    start: [start[0], start[1]],
    connect: true,
    serialization: {
      resolution: step,
      to: [
        [$(fields[0]), updateLabel($(labels[0]))],
        [$(fields[1]), updateLabel($(labels[1]))]
      ]
    }
  });
};


window.ST.cancelPriceRangeFilter = function(selector){
  $(selector).noUiSlider({
    start: oldStartValues
  },true);
  document.body.click();
}

window.ST.clearPriceRangeFilter = function(selector,priceRange){
  $(selector).noUiSlider({
    start: priceRange
  },true);
}

window.ST.cancelNumberRangeFilter = function(selector){
  $(selector).noUiSlider({
    start: oldStartValues
  },true);
  document.body.click();
}

window.ST.clearNumberRangeFilter = function(selector){
  $(selector).noUiSlider({
    start: customFilterRange
  },true);
}

var oldValue = ''; 
var newValue = '', timeout;
window.ST.numberFilters = {};

window.ST.numberFilters.onKeyDownHandler = function(e){
  oldValue = e.target.value;
}
window.ST.numberFilters.onInputHandler = function(e,range,fields,selector,rangeSelector){
  var el = e.target; 
  newValue = Number(el.value); 

    if(selector.includes('min')){

      var maxElValue = Number($(fields[1]).val());

      if ( (newValue>= range[0]) && (newValue <= maxElValue) ) { 
        el.value = newValue; 
        } else { 
        el.value = oldValue; 
        }

      $(rangeSelector).noUiSlider({
        start: [Number(el.value), maxElValue]
      },true);
    }
    else{

      var minElValue = Number($(fields[0]).val());

      if ( (newValue>= minElValue) && (newValue <= range[1]) ) { 
        el.value = newValue; 
        } else { 
        el.value = oldValue; 
      }

      $(rangeSelector).noUiSlider({
        start: [minElValue, Number(el.value)]
      },true);
    }
 
  
}