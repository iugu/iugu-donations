$(function() {
  $('#amount').maskMoney();

  $('#payment-form').submit(function(evt) {
    evt.preventDefault();
    $('.alert').hide();
    var form = $(this);

    if (!$('#email').val().match(/\S+@\S+\.\S+/)) {
      $('.alert').show();
      return false;
    }

    if ($('#amount').maskMoney('unmasked')[0] <= 0) {
      $('.alert').show();
      return false;
    }

    var tokenResponseHandler = function(data) {

      if (data.errors) {
        $('.alert').show();
      } else {
        $("#token").val( data.id );
        $('#amount_cents').val($('#amount').maskMoney('unmasked')[0]*100);
        form.get(0).submit();
      }
    }

    Iugu.createPaymentToken(this, tokenResponseHandler);
    return false;
  });
});
