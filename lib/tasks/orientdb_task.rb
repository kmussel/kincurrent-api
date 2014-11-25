require 'thor'

class OrientDBTask < Thor

  ENV['RACK_ENV'] ||= 'development'
  require File.expand_path("config/boot.rb")

  desc "create_schema", "Create the Schema"
  def create_schema
    puts "*** Begin"
    Dir.glob("./lib/tasks/db/*.rb").sort.each do |rb_file|
      require rb_file
      class_name = rb_file.match(/\/\d{3}_(.*)\./)[1].camelize
      #next if migration_class_run?(class_name)
      puts "Running #{class_name} from #{rb_file}"
      klass = Object.const_get(class_name)

      task = klass.new
      task.execute
      Oriented.graph.commit
    end
  end

  class SchemaTask

    def v
      conn.java_connection.get_or_create_class("V")
    end

    def e
      conn.java_connection.get_or_create_class("E")
    end

    def conn
      conn = Oriented.connection
      graph = conn.graph
      graph.autoStartTx=false
      graph.commit
      conn
    end

    def base_model
      conn.java_connection.get_or_create_class("BaseModel", {use_cluster: v })
    end

    def base_edge
      conn.java_connection.get_or_create_class("BaseEdge", {use_cluster: e })
    end

    def migration_class
      conn.java_connection.get_or_create_class("MigrationClass")
    end

    def migration_class_run?(class_name)
      sql = "select from MigrationClass where migration_name = '#{class_name}'"
      cmd = OrientDB::SQLCommand.new(cmd)
      res = Oriented.graph.command(cmd).execute
      res.to_a.any?
    end

    def edge_index_exists?(edge_type, index_name)
      edge_type.get_indexes.to_a.select do |ind|
        f_name = ind.name
        puts "** Existing #{f_name} index for #{edge_type}"
        return true if (f_name && ( f_name.downcase == index_name.downcase ))
      end
      false
    end

  end
end

OrientDBTask.start(ARGV)
