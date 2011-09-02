$(function () {
	
	$('.block .message').hide().append('<span class="close" title="Dismiss"></span>').fadeIn('slow');
	$('.block .message .close').hover(
		function() { $(this).addClass('hover'); },
		function() { $(this).removeClass('hover'); }
	);
		
	$('.block .message .close').click(function() {
		$(this).parent().fadeOut('slow', function() { $(this).remove(); });
	});

  // CSS tweaks
  $('#header #nav li:last').addClass('nobg');
  $('.block_head ul').each(function() { $('li:first', this).addClass('nobg'); });
  $('.block table tr:odd').css('background-color', '#fbfbfb');
  $('.block form input[type=file]').addClass('file');


  $('a[rel*=facebox]').facebox();
  $(".close-facebox").live('click', function() {
    $(document).trigger('close.facebox');
    return false;
  });

  $(document).bind('loading.facebox', function() {
    $(document).unbind('keydown.facebox');
    $('#facebox_overlay').unbind('click');
  });

  $(".close-facebox").click(function() {
    $(document).trigger("close.facebox");
    return false;
  });

});