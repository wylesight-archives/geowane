class PartnerCategory < ActiveRecord::Base
  validates_presence_of :french, :english
  has_many :categories, :through => :mappings
  has_many :mappings
  belongs_to :partner
  mount_uploader :icon, IconUploader

  default_scope :order => 'french ASC'

end