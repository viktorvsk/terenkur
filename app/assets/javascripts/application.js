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
//= require jquery.scrollstop
//= require jquery.lazyload
//= require jquery_ujs
//= require ckeditor/init
//= require picker
//= require bootstrap.min
//= require material.min
//= require ripples
//= require jquery.magnific-popup
//= require events
//= require users

$(document).ready(function(){
  $.material.init();
  $('img.lazy').lazyload();
  $('.dropdown-toggle').dropdown();
  $('#top-nav li a[href="'+ window.location.pathname +'"]').parent().addClass('active')
  $('.message .close').on('click', function() {
    $(this).closest('.message').fadeOut();
  });

  $('.event-main-image').magnificPopup({
    type: 'image',
    closeOnContentClick: true,
    mainClass: 'mfp-img-mobile',
    image: {
      verticalFit: true
    }
  });

  $('.gallery').magnificPopup({
    delegate: 'a',
    type: 'image',
    tLoading: 'Loading image #%curr%...',
    mainClass: 'mfp-img-mobile',
    gallery: {
      enabled: true,
      navigateByImgClick: true,
      preload: [0,1] // Will preload 0 - before current, and 1 after the current image
    },
    image: {
      tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
      titleSrc: function(item) {
        return item.el.attr('title');
      }
    }
  });

});