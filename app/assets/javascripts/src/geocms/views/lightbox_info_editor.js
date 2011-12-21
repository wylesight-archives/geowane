GeoCMS.Views.LightboxInfoEditor = Backbone.View.extend({

  events: {
    "click .actions .blue-button": "save"
  },

  initialize: function() {
    var country = "#{@location.administrative_unit(0).try(:name)}";
    switch(country) {
      case "Côte d'Ivoire":
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          value = jQuery.trim(value);
          return value == "" || value.match(/^\+225 \d{2} \d{2} \d{2} \d{2}$/);
        }, "Not a valid Côte d'Ivoire phone number. It should be of the form +225 XX XX XX XX");
        break;
      case "Bénin":
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          value = jQuery.trim(value);
          return value == "" || value.match(/^\+229 \d{2} \d{2} \d{2} \d{2}$/);
        }, "Not a valid Bénin phone number. It should be of the form +229 XX XX XX XX");
        break;
      case "Sénégal":
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          value = jQuery.trim(value);
          return value == "" || value.match(/^\+221 \d{2} \d{3} \d{4}$/);
        }, "Not a valid Sénégal phone number. It should be of the form +221 XX XXX XXXX");
        break;
      case "Togo":
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          value = jQuery.trim(value);
          return value == "" || value.match(/^\+228 \d{3} \d{4}$/);
        }, "Not a valid Togo phone number. It should be of the form +228 XXX XXXX");
        break;
      case "Guinée":
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          value = jQuery.trim(value);
          return value == "" || value.match(/^\+224 \d{2} \d{2} \d{2}$/);
        }, "Not a valid Guinée phone number. It should be of the form +224 XX XX XX");
        break;
      default:
        jQuery.validator.addMethod("validPhoneNumber", function(value, element) {
          return true;
        }, "");
    }

    $("form.location").validate({
      debug: true,
      rules: {
        "location[email]": {
          email: true
        },
        "location[telephone]": {
          validPhoneNumber: true
        },
        "location[website]": {
          url: true
        }
      }
    });
  },

  save: function() {
    return false;
  }

});

