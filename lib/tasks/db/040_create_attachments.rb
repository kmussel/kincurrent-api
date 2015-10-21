class CreateAttachments < OrientDBTask::SchemaTask

  def execute
    umodel = create_attachment_model
  end

  private

  def create_attachment_model
    attch_model = conn.java_connection.get_or_create_class("Attachment", {use_cluster: base_model })
    puts "Got Attachment"

    Kincurrent::Utils::Database.create_property_for(attch_model, "type", conn)
    Kincurrent::Utils::Database.create_property_for(attch_model, "name", conn)
    Kincurrent::Utils::Database.create_property_for(attch_model, "file", conn)    
    
  
    puts "Created Properties for Attachment"
    attch_model
  end

end
