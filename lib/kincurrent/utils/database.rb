# encoding: UTF-8
require 'orientdb'

module Kincurrent
  module Utils
    # Utilities to suppor our migrationish framework
    module Database
      STRING = OrientDB::SchemaType::STRING
      INT = OrientDB::SchemaType::INTEGER
      FLOAT = OrientDB::SchemaType::FLOAT
      LONG = OrientDB::SchemaType::LONG
      DATE = OrientDB::SchemaType::DATE
      DATETIME = OrientDB::SchemaType::DATETIME
      BOOL = OrientDB::SchemaType::BOOLEAN
      EMBEDDED_SET = OrientDB::SchemaType::EMBEDDEDSET
      EMBEDDED_MAP = OrientDB::SchemaType::EMBEDDEDMAP
      LINKLIST = OrientDB::SchemaType::LINKLIST
      LINK = OrientDB::SchemaType::LINK

      class << self
        def get_or_create_class(class_name, conn)
          conn.java_connection.get_or_create_class(class_name)
        end

        def create_property_for(vertex_or_edge_type, prop, conn, options = {})
          p = get_or_create_prop(vertex_or_edge_type, prop, options)
          p.set_not_null(options.fetch(:null, false))
          p.set_mandatory(options.fetch(:mandatory, false))
          p.set_collate(options[:collate]) if options[:collate]
          if options.fetch(:index, false)
            create_index_for(vertex_or_edge_type, prop, conn, options)
          end
        end

        def get_or_create_prop(vertex_or_edge_type, prop, options)
          p = vertex_or_edge_type.get_property(prop)
          unless p
            p = vertex_or_edge_type.create_property(
              prop,
              options.fetch(:type, STRING)
            )
          end
          p
        end

        def create_link_for(edge_type,
                            property_name, conn, linked_class, options = {})
          return if edge_type.get_property(property_name)
          p = edge_type.create_property(property_name, LINK, linked_class)
          p.set_not_null(options.fetch(:null, false))
          p.set_mandatory(options.fetch(:mandatory, false))
          if options.fetch(:index, false)
            create_index_for(edge_type, property_name, conn, options)
          end
        end

        def existing_index?(vertex_type, prop)
          vertex_type.get_indexes.to_a.select do |ind|
            puts ind
            f_name = ind.definition.fields.first
            puts "** Existing #{f_name} index for #{vertex_type.name}"
            f_name && (f_name.downcase == prop.downcase)
          end.any?
        end

        def create_index_for(vertex_type, prop, conn,  options)
          puts "index for #{vertex_type.name}:#{prop}"
          return if existing_index?(vertex_type, prop)
          param1 = OrientDB::BLUEPRINTS::Parameter.new(
            'class',
            vertex_type.name
          )
          param2 = OrientDB::BLUEPRINTS::Parameter.new(
            'type',
            options[:index]
          )
          ct = class_type(vertex_type)
          conn.graph.create_key_index(prop, ct, param1, param2)
        end

        def class_type(vertex_type)
          if vertex_type.name == 'E' || vertex_type.is_sub_class_of?('E')
            OrientDB::BLUEPRINTS::Edge.java_class
          else
            OrientDB::BLUEPRINTS::Vertex.java_class
          end
        end

        def create_composite_index(name, vertex_type, index_type, *props)
          existing_inds = vertex_type.indexes
          exists = existing_inds.to_a.select do |ind|
            if ((props & ind.definition.fields.to_a).count == props.count)
              puts "** Composite indexs exists for #{props.inspect}"
              return true
            end
            false
          end
          return if exists.any?
          vertex_type.create_index(name, index_type, *props)
        end

        def create_js_function(conn, name, code, options = {}, params = ['NA'])
          funclib = conn.java_connection.metadata.function_library
          return unless funclib.get_function(name).nil?
          func = funclib.create_function(name)
          func.set_code(code)
          # ODB Doesn't like functions w/out parameters
          puts '*** YOU NEED TO GO INTO STUDIO AND ADD PARAMETERS'
          puts '*** EVEN IF THE FUNCTION DOESN\'T TAKE ONE'
          func.set_parameters(['a'])
          func.set_language('Javascript')
          func.set_idempotent(options.fetch(:idempotent, false))

          conn.commit
        end
      end
    end
  end
end
