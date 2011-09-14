$.Controller("ManageMap",
{
  init: function(el, options) {
    this.map = Carto.build();
    Carto.addCommonControls(this.map);
    this.layer = Carto.createLayer("Features", this.map);
    this.landmark_layer = Carto.createLayer("Landmarks", this.map);
    this.setupControls();
    this.location_id = options.location_id;
    $.getJSON("/locations/" + this.location_id, this.update.bind(this));
  },

  "a:contains('Save') click": function() {
    this.publish("geocms.location-updating");
    this.original_geometry = this.layer.getDataExtent().getCenterLonLat();
    $.ajax({
      url: "/locations/" + this.location_id,
      data: {location: {id: this.location_id, longitude: this.original_geometry.lon, latitude: this.original_geometry.lat}},
      success: function() {
        this.original_geometry = this.layer.getDataExtent().getCenterLonLat();
        this.hideActions();
      },
      context: this,
      type: "PUT",
      dataType: "json"
    });
  },

  "a:contains('Cancel') click": function() {
    this.layer.features[0].move(this.original_geometry);
    this.hideActions();
  },

  update: function(data) {
    var locations = new OpenLayers.Format.GeoJSON().read(data);
    locations[0].attributes["thumbnail"] = "/assets/icons/1.gif";
    this.layer.addFeatures(locations);
    this.original_geometry = this.layer.getDataExtent().getCenterLonLat();
    this.map.setCenter(this.original_geometry, 6);
    Carto.displayLandmarkFeatures(this.location_id, this.landmark_layer);
  },

  showActions: function() {
    this.element.find(".portlet-header span").show();
  },

  hideActions: function() {
    this.element.find(".portlet-header span").hide();
  },

  setupControls: function() {
    var self = this;
    var drag = new OpenLayers.Control.DragFeature(this.layer, {
      onStart: function() {
        Carto.hideTipsy();
      },
      onComplete: function() {
        self.showActions();
      }
    });
    var tooltip = new OpenLayers.Control.SelectFeature([this.landmark_layer, this.layer], {
      hover: true,
      multiple: false,
      highlightOnly: true,
      overFeature: function(feature) {
        Carto.showLabel(feature);
        $("body").css({cursor: "pointer"});
      },
      outFeature: function() {
        $("body").css({cursor: "default"});
        Carto.hideTipsy();
      }
    });
    var controls = [tooltip, drag];
    this.map.addControls(controls);
    $.each(controls, function (index, item) {
      item.activate();
    });
  }
});