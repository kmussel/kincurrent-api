class CreateBaseObjects < OrientDBTask::SchemaTask

  def execute
    create_base_model
    create_base_edge
  end

  private

  def create_base_model
    base_model = conn.java_connection.get_or_create_class("BaseModel", {use_cluster: v })
    puts "Got BaseModel"

    Kincurrent::Utils::Database.create_property_for(base_model, "kin_id", conn,  {null: false, mandatory: false, index: 'UNIQUE'})
    Kincurrent::Utils::Database.create_property_for(base_model, "created_at", conn,  {type: Kincurrent::Utils::Database::LONG})
    Kincurrent::Utils::Database.create_property_for(base_model, "updated_at", conn,  {type: Kincurrent::Utils::Database::LONG})

    puts "Created Properties for BaseModel"
  end


  def create_base_edge
    base_model = conn.java_connection.get_or_create_class("BaseEdge", {use_cluster: e })
    puts "Got BaseEdge"

    Kincurrent::Utils::Database.create_property_for(base_edge, "kin_id", conn,  {null: false, mandatory:false, index: 'UNIQUE'})
    Kincurrent::Utils::Database.create_property_for(base_edge, "created_at", conn,  {type: Kincurrent::Utils::Database::LONG})
    Kincurrent::Utils::Database.create_property_for(base_edge, "updated_at", conn,  {type: Kincurrent::Utils::Database::LONG})

    puts "Created Properties for BaseEdge"
  end

  def create_migration_class
    migration_class = conn.java_connection.get_or_create_class("MigrationClass")
    puts "Got Migration_class"

    Kincurrent::Utils::Database.create_property_for(migration_class, "migration_name", conn,  {null: false, mandatory:false, index: 'UNIQUE'})

    puts "Created Properties for MigrationClass"
  end
end

