require 'roar-sinatra'
require 'roar/decorator'
require 'roar/representer/json'


class PostRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  [:rid, :kin_id, :created_at, :updated_at, :content].each do |v|
    property v
  end
  
  [:creator_id, :stream_id].each do |v|
    property v, if: lambda { |args| args[:create] == true}
  end
  
  property :kind, getter: lambda{ |args| 'Post' }

  collection :attachments, extend: AttachmentRepresenter 
  # do
   #    [:kin_id, :created_at, :updated_at, :name].each do |v|
   #      property v
   #    end
   #  end

end