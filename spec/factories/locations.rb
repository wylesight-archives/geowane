Factory.define :location, :class => Location do |f|
  f.name { Factory.next :place_name  }
  f.latitude {rand}
  f.longitude {rand}
  f.association :user, :factory => :collector
end

Factory.define :invalid_location, :class => Location do |f|
end

Factory.sequence :place_name do |n|
  "poi_#{n}"
end