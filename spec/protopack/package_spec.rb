# -*- coding: utf-8 -*-

require File.expand_path('../../spec_helper', __FILE__)

describe Protopack::Package do

  module HasRegion
    attr_accessor :region
  end

  before {
    Protopack::PackageItem.send :include, HasRegion
    Protopack::Package.config_root = File.expand_path('../packages', __FILE__)
    Widget.destroy_all
    Wot::Zit.destroy_all
  }

  it "should find all the packages" do
    expect(Protopack::Package.all.map(&:name).join(" ")).to eq "advanced-widgets standard-widgets"
  end

  it "should find a given package" do
    p = Protopack::Package.find("standard-widgets")
    expect(p.name).to eq "standard-widgets"

    expect(p.title["en"]).to eq "Standard Widgets"
    expect(p.title["fr"]).to eq "Widgets standards"

    expect(p.description["en"]).to eq "Use these widgets for everyday widgeting"
    expect(p.description["fr"]).to eq "Ces widgets sont utilisables pour votre widgeting quotidien"

    expect(p.authors).to eq %w{ baz titi Z }

    expect(p.updated).to eq Date.parse("2013-03-15")
  end

  it "should install all items from a package" do
    p = Protopack::Package.find("standard-widgets")
    p.apply_all

    expect(Widget.all.map(&:colour)).to eq %w{ red blue yellow black green }
  end

  it "should install all items from a package, overwriting existing items, respecting #ordinal property" do
    Widget.new :colour => "blue"
    Widget.new :colour => "green"

    p = Protopack::Package.find("standard-widgets")
    p.apply_all

    expect(Widget.all.map(&:colour)).to eq %w{ blue green red yellow black }
    expect(Widget.all[0].height).to eq 'elephant'
    expect(Widget.all[1].height).to eq 'zebra'
    expect(Widget.all[2].height).to eq 'tiger'
    expect(Widget.all[3].height).to eq 'hyena'
    expect(Widget.all[4].height).to eq 'camel'

    black = Widget.all[4]
    black_desc = "<html><p>this is what a black widget looks like</p></html>"
    expect(black.description).to eq black_desc
  end

  it "should install all items from a package subject to filtering" do
    Widget.new :colour => "blue"
    Widget.new :colour => "green"

    Protopack::Package.find("standard-widgets").apply_all { |x| x.region == "Africa" }

    expect(Widget.all.map(&:colour)).to eq %w{ blue green yellow }
    expect(Widget.all[0].height).to eq 'elephant'
    expect(Widget.all[1].height).to eq 'zebra'
    expect(Widget.all[2].height).to eq 'hyena'
  end

  it "should install only missing items from a package, not overwriting existing items" do
    Widget.new :colour => "blue", :height => "not specified"
    Widget.new :colour => "green", :height => "not specified"

    p = Protopack::Package.find("standard-widgets")
    p.apply_missing

    expect(Widget.all.map(&:colour)).to eq %w{ blue green red yellow black}
    expect(Widget.all[0].height).to eq "not specified"
    expect(Widget.all[1].height).to eq "not specified"
    expect(Widget.all[2].height).to eq 'tiger'
    expect(Widget.all[3].height).to eq 'hyena'
    expect(Widget.all[4].height).to eq 'camel'
  end

  it "looks up namespaced class names" do
    p = Protopack::Package.find("advanced-widgets")
    p.apply_missing

    expect(Wot::Zit.all.map(&:colour).sort).to eq %w{ lavender magenta }
  end
end
