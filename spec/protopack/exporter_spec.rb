# -*- coding: utf-8 -*-

require File.expand_path('../../spec_helper', __FILE__)

# from aduki
require 'core_ext/array'
require 'core_ext/hash'

describe Protopack::Package do

  it "exports a simple widget" do
    desc = <<DESC
this
is
a
multiline
description
DESC
    wz0 = { colour: 41, height: 42, density: 43 }
    wz1 = { colour: 51, height: 52, density: 53 }
    w = Widget.new colour: 1, height: 2, density: 3, name: "Park Lodge Café", newwots: [ wz0, wz1 ], description: desc

    exporter = Protopack::Exporter.new
    hsh = exporter.to_package(w)
    expected = <<YML.strip
---
id: Park Lodge Café
description: Park Lodge Café
type: Widget
attributes:
  colour: 1
  height: 2
  density: 3
  name: Park Lodge Café
  newwots:
  - colour: 41
    height: 42
    density: 43
  - colour: 51
    height: 52
    density: 53
YML

    expect(exporter.clean_yaml(hsh).strip).to eq expected
  end

  it "exports an object as a zip file" do
    desc = <<DESC
this
is
a
multiline
description
DESC
    wz0 = { colour: 41, height: 42, density: 43 }
    wz1 = { colour: 51, height: 52, density: 53 }
    w = Widget.new colour: 1, height: 2, density: 3, name: "Park Lodge Café", newwots: [ wz0, wz1 ], description: desc

    exporter = Protopack::Exporter.new

    zip = exporter.to_zip(w)

    h = { }
    Zip::InputStream.open(StringIO.new zip) do |io|
        while entry = io.get_next_entry
          h[entry.name] = io.read.force_encoding("UTF-8")
        end
    end

    expect(h["park-lodge-cafe.yml"]).to eq <<CFG
---
id: Park Lodge Café
description: Park Lodge Café
type: Widget
attributes:
  colour: 1
  height: 2
  density: 3
  name: Park Lodge Café
  newwots:
  - colour: 41
    height: 42
    density: 43
  - colour: 51
    height: 52
    density: 53
CFG

    expect(h["resources/park-lodge-cafe-description.html"]).to eq <<DESC
this
is
a
multiline
description
DESC

    expect(h.keys.sort).to eq %w{
      park-lodge-cafe.yml
      resources/park-lodge-cafe-description.html
    }
  end
end
