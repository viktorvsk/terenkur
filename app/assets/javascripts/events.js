$(document).ready(function(){
  $('.image-adder').click(function(e){
    var imagesCount = $('#images-uploader .images input[type="file"]').size();
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

  datepickr('.datepickr');

  datepickr.prototype.l10n.months.shorthand = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
  datepickr.prototype.l10n.months.longhand = ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'];
  datepickr.prototype.l10n.weekdays.shorthand = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
  datepickr.prototype.l10n.weekdays.longhand = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];

  datepickr('#search-date', {
    dateFormat: 'Y-m-d',
    minDate: new Date().getTime() - 1000 * 60 * 60 * 24
  });

  $('#register-and-order').on('show.bs.modal', function(event){
    $('#register-and-order form').append('<input type="hidden" name="event_id" value='+ eventId +' />')
  });

  $('.register-and-order').click(function(event){
    $('#register-and-order.modal form')[0].reset();
    window.eventId = $(this).data('event');
    $('#register-and-order').modal('show');
    event.preventDefault();
  });

});