require 'roar-sinatra'
require 'roar/decorator'
require 'roar/representer/json'

module Kincurrent
  module GroupRepresenter
    include Roar::Representer::JSON

    [:kin_id, :created_at, :updated_at, :name].each do |v|
      property v
    end

    collection :streams, class: Kincurrent::Stream do
      [:kin_id, :created_at, :updated_at, :name].each do |v|
        property v
      end
    end
  end
end