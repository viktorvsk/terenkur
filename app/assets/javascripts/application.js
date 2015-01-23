// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require ckeditor/init
//= require picker
//= require_tree .


$(document).ready(function(){


  $('.dropdown-toggle').dropdown()
  $('#top-nav li a[href="'+ window.location.pathname +'"]').parent().addClass('active')

  $('.message .close').on('click', function() {
    $(this).closest('.message').fadeOut();
  });

  datepickr('#search-date');

  datepickr.prototype.l10n.months.shorthand = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
  datepickr.prototype.l10n.months.longhand = ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'];
  datepickr.prototype.l10n.weekdays.shorthand = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
  datepickr.prototype.l10n.weekdays.longhand = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];

  datepickr('#search-date', {
    dateFormat: 'Y-m-d',
    minDate: new Date().getTime() - 1000 * 60 * 60 * 24
  });

  $('.image-adder').click(function(e){
    var imagesCount = $('#images-uploader .images .image').size();
    var node = [
        '<div class="col-xs-4">',
          '<input id="event_images_attributes_'+ imagesCount +'_attachment" name="event[images_attributes]['+ imagesCount +'][attachment]" type="file">',
        '</div>'].join("\n");
    console.log(node)
    $('#images-uploader .images').append(node);
    e.preventDefault();
  });

  $('#search-submit').click(function(){
    var city    = $('#city').val(),
        type    = $('#event_type').val(),
        date    = $('#search-date').val(),
        params  = [];

    if( city !== "" && city != null){
      params.push(city);
    }
    if( date !== "" && date != null){
      params.push(date);
    }
    if( type !== "" && type != null){
      params.push(type);
    }
    url = '/' + params.join('/');
    window.location.href = url;
  });

});