require 'roar-sinatra'
require 'roar/decorator'
require 'roar/json'


class StreamEventRepresenter < Roar::Decorator
  include Roar::JSON

  [:rid, :kin_id, :created_at, :updated_at, :name].each do |v|
    property v
  end
  
  property :kind, getter: lambda{ |trg, *| target.class.to_s.split("::").last }
  
  property :target, :extend => lambda { |trg, *| 
    case trg.class.to_s
    when "Kincurrent::Post"
      PostRepresenter
    when "Kincurrent::Attachment"
      AttachmentRepresenter
    end
    
  }

end