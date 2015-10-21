class CreateUser < OrientDBTask::SchemaTask

  def execute
    umodel = create_user_model
  end

  private

  def create_user_model
    user_model = conn.java_connection.get_or_create_class("User", {use_cluster: base_model })
    puts "Got User"

    Kincurrent::Utils::Database.create_property_for(user_model, "username", conn,  {null: false, mandatory: false, index: 'UNIQUE'})
    Kincurrent::Utils::Database.create_property_for(user_model, "email", conn,  {null: false, mandatory: false, index: 'UNIQUE'})    
    
  
    puts "Created Properties for User"
    user_model
  end

end
