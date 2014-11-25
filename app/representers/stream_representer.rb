require 'roar-sinatra'
require 'roar/decorator'
require 'roar/representer/json'


class StreamRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  [:kin_id, :created_at, :updated_at, :name].each do |v|
    property v
  end


end