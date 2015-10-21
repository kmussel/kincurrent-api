require 'roar-sinatra'
require 'roar/decorator'
require 'roar/json'


class StreamRepresenter < Roar::Decorator
  include Roar::JSON

  [:kin_id, :created_at, :updated_at, :name].each do |v|
    property v
  end


end