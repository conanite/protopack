# -*- coding: utf-8 -*-

require File.expand_path('../../spec_helper', __FILE__)

# from aduki
require 'core_ext/array'
require 'core_ext/hash'

describe Protopack::Package do

  it "exports a simple widget" do
    wz0 = { colour: 41, height: 42, density: 43 }
    wz1 = { colour: 51, height: 52, density: 53 }
    w = Widget.new colour: 1, height: 2, density: 3, name: "Park Lodge Café", newwots: [ wz0, wz1 ]

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

end
