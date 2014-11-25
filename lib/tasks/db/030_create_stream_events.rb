class CreateStreamEvents < OrientDBTask::SchemaTask

  def execute
    pmodel = create_post_model
    smodel = create_stream_event_model
    create_stream_event_target_edge
  end

  private

  def create_post_model
    post_model = conn.java_connection.get_or_create_class("Post", {use_cluster: base_model })
    puts "Got post"

    Kincurrent::Utils::Database.create_property_for(post_model, "content", conn)

    puts "Created Properties for Content"
    post_model
  end
  
  def create_stream_event_model
    stream_obj_model = conn.java_connection.get_or_create_class("StreamEvent", {use_cluster: base_model })
    puts "Got stream event"

    Kincurrent::Utils::Database.create_property_for(stream_obj_model, "kind", conn)
    puts "Created Properties for StreamEvent"
    stream_obj_model
  end


  def create_stream_event_target_edge
    obj_model = conn.java_connection.get_or_create_class("stream_event_target", {use_cluster: base_edge })
    puts "Got StreamEventTarget"

    Kincurrent::Utils::Database.create_property_for(obj_model, "kind", conn)
    # Kincurrent::Utils::Database.create_link_for(obj_model, "out", conn, group, {mandatory: true})
    # Kincurrent::Utils::Database.create_link_for(obj_model, "in", conn, stream, {mandatory: true})

    puts "Created Properties for StreamEventTarget"
  end

end

