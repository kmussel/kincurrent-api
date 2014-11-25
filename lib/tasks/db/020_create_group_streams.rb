class CreateGroupStreams < OrientDBTask::SchemaTask

  def execute
    gmodel = create_group_model
    smodel = create_stream_model
    create_owner_stream_edge(gmodel, smodel)
  end

  private

  def create_group_model
    group_model = conn.java_connection.get_or_create_class("Group", {use_cluster: base_model })
    puts "Got Group"

    Kincurrent::Utils::Database.create_property_for(group_model, "name", conn,  {null: false, mandatory: false, index: 'UNIQUE'})

    puts "Created Properties for Group"
    group_model
  end
  
  def create_stream_model
    stream_model = conn.java_connection.get_or_create_class("Stream", {use_cluster: base_model })
    puts "Got stream"

    Kincurrent::Utils::Database.create_property_for(stream_model, "name", conn)
    puts "Created Properties for Stream"
    stream_model
  end


  def create_owner_stream_edge(group, stream)
    obj_model = conn.java_connection.get_or_create_class("owner_stream", {use_cluster: base_edge })
    puts "Got OwnerStream"

    Kincurrent::Utils::Database.create_property_for(obj_model, "kind", conn)
    # Kincurrent::Utils::Database.create_link_for(obj_model, "out", conn, group, {mandatory: true})
    # Kincurrent::Utils::Database.create_link_for(obj_model, "in", conn, stream, {mandatory: true})

    puts "Created Properties for OwnerStream"
  end

end

