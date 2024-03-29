# -*- coding: utf-8 -*-

require File.expand_path('../../spec_helper', __FILE__)

describe Protopack::Package do

  module HasRegion
    attr_accessor :region
  end

  let(:config) { Protopack::Config.new root: File.expand_path('../packages', __FILE__) }

  before {
    Protopack::PackageItem.send :include, HasRegion
    Widget.destroy_all
    Wot::Zit.destroy_all
  }

  it "should find all the packages" do
    expect(config.all.map(&:name).join(" ")).to eq "advanced-widgets standard-widgets"
  end

  it "should find a given package" do
    p = config.find("standard-widgets")
    expect(p.name).to eq "standard-widgets"

    expect(p.title["en"]).to eq "Standard Widgets"
    expect(p.title["fr"]).to eq "Widgets standards"

    expect(p.description["en"]).to eq "Use these widgets for everyday widgeting"
    expect(p.description["fr"]).to eq "Ces widgets sont utilisables pour votre widgeting quotidien"

    expect(p.authors).to eq %w{ baz titi Z }

    expect(p.updated).to eq Date.parse("2013-03-15")
  end

  it "should install all items from a package" do
    pkg = config.find("standard-widgets")
    pkg.apply_all

    expect(Widget.all.map(&:colour).sort).to eq %w{ black blue green red yellow }
  end

  it "should install all items from a package, overwriting existing items, respecting #ordinal property" do
    Widget.new :colour => "blue"
    Widget.new :colour => "green"

    p = config.find("standard-widgets")
    p.apply_all

    widgets = Widget.all.sort_by &:colour
    expect(widgets.map(&:colour)).to eq %w{ black blue green red yellow }
    expect(widgets[0].height).to eq 'camel'
    expect(widgets[1].height).to eq 'elephant'
    expect(widgets[2].height).to eq 'zebra'
    expect(widgets[3].height).to eq 'tiger'
    expect(widgets[4].height).to eq 'hyena'

    green = widgets[2]
    expect(green.name).to eq "The green widget for obtuse African zebras"

    black = widgets[0]
    black_desc = "<html><p>this is what a black widget looks like</p></html>"
    expect(black.name).to be_nil
    expect(black.description).to eq black_desc
  end

  it "should install all items from a package subject to filtering" do
    Widget.new :colour => "blue"
    Widget.new :colour => "green"

    config.find("standard-widgets").apply_all { |x| x.region == "Africa" }

    expect(Widget.all.map(&:colour).sort).to eq %w{ blue green yellow }
    expect(Widget.all[0].height).to eq 'elephant'
    expect(Widget.all[1].height).to eq 'zebra'
    expect(Widget.all[2].height).to eq 'hyena'
  end

  it "should install only missing items from a package, not overwriting existing items" do
    Widget.new :colour => "blue", :height => "not specified"
    Widget.new :colour => "green", :height => "not specified"

    p = config.find("standard-widgets")
    p.apply_missing

    widgets = Widget.all.sort_by &:colour
    expect(widgets.map(&:colour)).to eq %w{ black blue green red yellow }
    expect(widgets[0].height).to eq "camel"
    expect(widgets[1].height).to eq "not specified"
    expect(widgets[2].height).to eq 'not specified'
    expect(widgets[3].height).to eq 'tiger'
    expect(widgets[4].height).to eq 'hyena'
  end

  it "looks up namespaced class names" do
    p = config.find("advanced-widgets")
    p.apply_missing

    expect(Wot::Zit.all.map(&:colour).sort).to eq %w{ lavender magenta }
  end
end
