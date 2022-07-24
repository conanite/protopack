# -*- coding: utf-8 -*-
require 'zip'
require 'minislug'

module Protopack
  class Exporter
    def maybe_name_methods    ; %i{ export_name full_name presentation_name name }                         ; end
    def name_method obj       ; maybe_name_methods.detect { |m| obj.respond_to?(m) && obj.send(m) }        ; end
    def array_assoc list      ; list.map { |item| to_attributes item }                                     ; end
    def clean_yaml hsh        ; YAML.dump(clean_attrs hsh)                                           ; end
    def no_name? obj_id       ; raise "no name for object: #{obj_id.inspect}" if obj_id.blank?             ; end
    def default_export_config ; { fields: [], associations: [] }                                           ; end
    def export_config     obj ; default_export_config.merge obj.protopack_export_config                    ; end
    def to_attributes     obj ; obj.slice(*export_config(obj)[:fields]).merge build_association_table obj  ; end
    def to_yaml  obj, meta={} ; clean_yaml to_package obj, meta                                            ; end
    def remove_blanks   attrs ; attrs.recursively_remove_by_value! { |v| (v != false) && v.blank? }        ; end
    def styled_literal    str ; str.is_a?(String) ? StyledYAML.literal(str) : str                          ; end
    def clean_attrs     attrs ; remove_blanks(attrs).recursively_replace_values { |k,v| styled_literal v } ; end

    def build_association_table obj
      export_config(obj)[:associations].inject({ }) { |table, name|
        if name.is_a? Hash
          build_association obj, table, name[:get], name[:set]
        else
          build_association obj, table, name, "#{name}_attributes"
        end
        table
      }
    end

    def build_association obj, table, getter, setter
      assoc = obj.send getter
      return if assoc.blank? || assoc.empty?
      attrs = (assoc.respond_to?(:each)) ? array_assoc(assoc) : to_attributes(assoc)
      table[setter] = attrs
    end

    def resource_file_name obj, id, res
      "#{id}-#{res}.#{obj.resource_extension_for(res)}"
    end

    def to_zip obj, meta={}
      Zip::OutputStream.write_buffer { |z|
        if obj.respond_to?(:each)
          array_to_zip obj, z, meta
        else
          obj_to_zip obj, z, meta
        end
      }.tap(&:rewind).read
    end

    def obj_to_zip obj, zip, meta={}
      obj_name = obj.send(name_method obj)
      obj_id   = Minislug.convert_to_slug obj_name.downcase

      h = {
        "#{obj_id}.yml" => to_yaml(obj, meta).force_encoding("UTF-8")
      }

      (export_config(obj)[:resources] || []).each { |res|
        v = obj.send res
        h["resources/#{resource_file_name obj, obj_id, res}"] = v.force_encoding("UTF-8") unless v.blank?
      }

      h.each { |k, v| zip.put_next_entry(k) ; zip.print v }
    end

    def array_to_zip objs, zip, meta={}
      objs.each { |o| obj_to_zip o, zip, meta }
    end

    def to_package obj, meta={ }
      obj_name = obj.send(name_method obj)
      obj_id   = Minislug.convert_to_slug obj_name.downcase

      no_name? obj_id

      resh = {}
      (export_config(obj)[:resources] || []).each { |res|
        v = obj.send res
        resh[res.to_s] = resource_file_name(obj, obj_id, res)
      }

      hsh = {
        description: obj_name,
        type:        obj.class.name,
        attributes:  to_attributes(obj),
      }.deep_merge(meta).recursively_stringify_keys!

      hsh["resources"] = resh unless resh.empty?
      obj.protopack_customise_export(hsh) if obj.respond_to?(:protopack_customise_export)
      hsh
    end
  end
end
