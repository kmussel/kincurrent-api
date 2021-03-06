require 'roar-sinatra'
require 'roar/decorator'
require 'roar/json'


class AttachmentRepresenter < Roar::Decorator
  include Roar::JSON

  [:rid, :kin_id, :created_at, :updated_at, :type].each do |v|
    property v
  end
  property :file_identifier, as: :file_name
  property :file_url, as: :url

end