GeoCMS.Collections.Comments = Backbone.Collection.extend({

  model: GeoCMS.Models.Comment,

  initialize: function(options) {
    this.location = options.location;
  },

  url: function() {
    return "/locations/" + this.location.id + "/comments";
  }

});