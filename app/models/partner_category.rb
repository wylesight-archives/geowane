class PartnerCategory < ActiveRecord::Base
  validates_presence_of :french, :english
  has_many :categories, :through => :mappings
  has_many :mappings
  belongs_to :partner

  default_scope :order => 'french ASC'

end