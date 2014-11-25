require 'roar-sinatra'
require 'roar/decorator'
require 'roar/representer/json'

module Kincurrent
  module UserRepresenter
    include Roar::Representer::JSON

    [:kin_id, :created_at, :updated_at, :username, :email].each do |v|
      property v
    end
    
    [:api_key].each do |v|
      property v, if: lambda {|args| args[:auth] == true}
    end

    # collection :streams, class: Kincurrent::Stream do
    #   [:kin_id, :created_at, :updated_at, :name].each do |v|
    #     property v
    #   end
    # end
  end
end